# Roadbook MCP Server Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable AI assistants (Claude Desktop/Code) to manage roadbook itineraries via MCP protocol, backed by a new API Key authentication mechanism.

**Architecture:** Two-part implementation: (1) Add API Key model + auth middleware + CRUD routes to `roadbook-api`, (2) Create standalone `packages/roadbook-mcp` Node.js CLI that connects to the API via HTTP and exposes 8 MCP tools over stdio transport.

**Tech Stack:** Sequelize (model + migration), Koa middleware, `@modelcontextprotocol/sdk`, Node 18 native `fetch`, `crypto.randomBytes` for key generation.

---

## File Structure

### Backend changes (`packages/roadbook-api`)

| File | Action | Responsibility |
|------|--------|---------------|
| `models/apikey.js` | Create | ApiKey Sequelize model |
| `migrations/YYYYMMDD-create-apikeys.js` | Create | Database migration for ApiKeys table |
| `service/apikey.js` | Create | API Key CRUD business logic |
| `controller/apikey.js` | Create | API Key route handlers |
| `app.js` | Modify | Insert API Key auth middleware before JWT |

### MCP package (`packages/roadbook-mcp`)

| File | Action | Responsibility |
|------|--------|---------------|
| `package.json` | Create | Package manifest + dependencies |
| `index.js` | Create | MCP Server entry point, tool registration, stdio transport |
| `client.js` | Create | HTTP client wrapping roadbook-api calls |
| `tools/travel.js` | Create | 4 travel tools: list, create, update, get_detail |
| `tools/schedule.js` | Create | 4 schedule tools: list, add, update, remove |

---

### Task 1: ApiKey model and migration

**Files:**
- Create: `packages/roadbook-api/models/apikey.js`
- Create: `packages/roadbook-api/migrations/20260330000001-create-apikeys.js`

- [ ] **Step 1: Create migration file**

```javascript
// packages/roadbook-api/migrations/20260330000001-create-apikeys.js
'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('ApiKeys', {
      id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
      },
      uId: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      key: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true,
      },
      name: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      lastUsedAt: Sequelize.DATE,
      createdAt: Sequelize.DATE,
    });
  },
  async down(queryInterface) {
    await queryInterface.dropTable('ApiKeys');
  },
};
```

- [ ] **Step 2: Create ApiKey model**

```javascript
// packages/roadbook-api/models/apikey.js
'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class ApiKey extends Model {
    static associate(models) {
      this.belongsTo(models.User, { foreignKey: 'uId' });
    }
  }
  ApiKey.init({
    id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      autoIncrement: true,
      primaryKey: true,
    },
    uId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    key: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    lastUsedAt: DataTypes.DATE,
    createdAt: DataTypes.DATE,
  }, {
    sequelize,
    timestamps: false,
    modelName: 'ApiKey',
  });
  return ApiKey;
};
```

- [ ] **Step 3: Run migration**

Run: `cd packages/roadbook-api && npx sequelize-cli db:migrate`
Expected: Migration runs successfully, `ApiKeys` table created.

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-api/models/apikey.js packages/roadbook-api/migrations/20260330000001-create-apikeys.js
git commit -m "feat(api): add ApiKey model and migration"
```

---

### Task 2: ApiKey service

**Files:**
- Create: `packages/roadbook-api/service/apikey.js`

- [ ] **Step 1: Create ApiKey service**

```javascript
// packages/roadbook-api/service/apikey.js
const crypto = require('crypto');
const db = require('../models');

class ApiKeyService {
  generateKey() {
    return 'rb_' + crypto.randomBytes(24).toString('hex').slice(0, 32);
  }

  async create(uid, data) {
    try {
      const key = this.generateKey();
      const apiKey = await db.ApiKey.create({
        uId: uid,
        key,
        name: data.name,
        createdAt: new Date(),
      });
      return { id: apiKey.id, key, name: apiKey.name, createdAt: apiKey.createdAt };
    } catch (e) {
      throw '创建 API Key 失败';
    }
  }

  async list(uid) {
    try {
      const keys = await db.ApiKey.findAll({
        where: { uId: uid },
        attributes: ['id', 'key', 'name', 'lastUsedAt', 'createdAt'],
        order: [['createdAt', 'DESC']],
      });
      return keys.map(k => {
        const plain = k.get({ plain: true });
        plain.key = plain.key.slice(0, 7) + '...';
        return plain;
      });
    } catch (e) {
      throw '获取 API Key 列表失败';
    }
  }

  async remove(uid, id) {
    try {
      const count = await db.ApiKey.destroy({ where: { id, uId: uid } });
      if (count === 0) throw 'API Key 不存在';
    } catch (e) {
      throw e || '删除 API Key 失败';
    }
  }

  async findByKey(key) {
    const apiKey = await db.ApiKey.findOne({
      where: { key },
      include: [{ model: db.User, attributes: ['id', 'username', 'name', 'avatar'] }],
    });
    return apiKey;
  }
}

module.exports = new ApiKeyService();
```

- [ ] **Step 2: Commit**

```bash
git add packages/roadbook-api/service/apikey.js
git commit -m "feat(api): add ApiKey service with CRUD and key generation"
```

---

### Task 3: ApiKey controller and routes

**Files:**
- Create: `packages/roadbook-api/controller/apikey.js`

- [ ] **Step 1: Create ApiKey controller**

```javascript
// packages/roadbook-api/controller/apikey.js
const Router = require('koa-router');
const ApiKeyService = require('../service/apikey');
const { ajaxReturn } = require('../helper/util');

class ApiKeyController {
  async create(ctx) {
    try {
      await ctx.verifyParams({
        name: { type: 'string', max: 50 },
      });
      ctx.body = ajaxReturn(await ApiKeyService.create(ctx.state.user.id, ctx.request.body));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async list(ctx) {
    try {
      ctx.body = ajaxReturn(await ApiKeyService.list(ctx.state.user.id));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async remove(ctx) {
    try {
      await ctx.verifyParams({
        id: { type: 'int' },
      });
      await ApiKeyService.remove(ctx.state.user.id, ctx.request.body.id);
      ctx.body = ajaxReturn(null);
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }
}

module.exports = (router) => {
  let route = new Router();
  let controller = new ApiKeyController();
  route.post('/apikey/create', controller.create);
  route.post('/apikey/list', controller.list);
  route.post('/apikey/remove', controller.remove);

  router.use('/user', route.routes(), route.allowedMethods());
};
```

- [ ] **Step 2: Commit**

```bash
git add packages/roadbook-api/controller/apikey.js
git commit -m "feat(api): add ApiKey controller with create/list/remove routes"
```

---

### Task 4: API Key auth middleware

**Files:**
- Modify: `packages/roadbook-api/app.js`

This task inserts API Key detection **before** the JWT middleware in `app.js`. The middleware intercepts `Authorization: Bearer rb_...` tokens and resolves them to a user, so the rest of the app works identically.

- [ ] **Step 1: Add API Key middleware to app.js**

In `packages/roadbook-api/app.js`, find the existing `apiRouter` setup block:

```javascript
apiRouter
  .use(bodyparser({ enableTypes: ["json"] }))
  .use(jwt({ secret: config.sercet, passthrough: true }))
  .use(function (ctx, next) {
```

Replace with:

```javascript
apiRouter
  .use(bodyparser({ enableTypes: ["json"] }))
  .use(async function (ctx, next) {
    const auth = ctx.headers['authorization'];
    if (auth && auth.startsWith('Bearer rb_')) {
      const key = auth.slice(7);
      const ApiKeyService = require('./service/apikey');
      const apiKey = await ApiKeyService.findByKey(key);
      if (apiKey && apiKey.User) {
        ctx.state.user = {
          id: apiKey.User.id,
          username: apiKey.User.username,
          name: apiKey.User.name,
          avatar: apiKey.User.avatar,
        };
        apiKey.lastUsedAt = new Date();
        await apiKey.save();
        return next();
      }
    }
    return next();
  })
  .use(jwt({ secret: config.sercet, passthrough: true }))
  .use(function (ctx, next) {
```

- [ ] **Step 2: Test manually**

Start the dev server: `cd packages/roadbook-api && npm run dev`

1. Login to get a JWT token
2. Create an API Key via `POST /api/user/apikey/create` with `{ "name": "test" }` (using JWT auth)
3. Use the returned API Key to call `POST /api/travel/page` with `Authorization: Bearer rb_xxx`
4. Verify it returns the user's travel list

- [ ] **Step 3: Commit**

```bash
git add packages/roadbook-api/app.js
git commit -m "feat(api): add API Key auth middleware before JWT"
```

---

### Task 5: MCP package setup and HTTP client

**Files:**
- Create: `packages/roadbook-mcp/package.json`
- Create: `packages/roadbook-mcp/client.js`

- [ ] **Step 1: Create package.json**

```json
{
  "name": "roadbook-mcp",
  "version": "1.0.0",
  "description": "MCP server for Roadbook itinerary management",
  "main": "index.js",
  "bin": {
    "roadbook-mcp": "./index.js"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.12.1"
  }
}
```

- [ ] **Step 2: Install dependencies**

Run: `cd packages/roadbook-mcp && npm install`

- [ ] **Step 3: Create HTTP client**

```javascript
// packages/roadbook-mcp/client.js
const apiUrl = process.env.ROADBOOK_API_URL;
const apiKey = process.env.ROADBOOK_API_KEY;

if (!apiUrl) {
  console.error('错误：未设置 ROADBOOK_API_URL 环境变量');
  process.exit(1);
}
if (!apiKey) {
  console.error('错误：未设置 ROADBOOK_API_KEY 环境变量');
  process.exit(1);
}

const baseUrl = apiUrl.replace(/\/$/, '');

async function request(path, body = {}) {
  let res;
  try {
    res = await fetch(`${baseUrl}${path}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify(body),
    });
  } catch (e) {
    throw new Error(`无法连接到路书服务器，请检查 ROADBOOK_API_URL 配置 (${e.message})`);
  }

  const json = await res.json();

  if (json.code === 401) {
    throw new Error('API Key 无效，请检查 ROADBOOK_API_KEY 配置');
  }
  if (json.code !== 200) {
    throw new Error(json.msg || '请求失败');
  }

  return json.data;
}

module.exports = { request };
```

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-mcp/package.json packages/roadbook-mcp/client.js
git commit -m "feat(mcp): init package with HTTP client"
```

---

### Task 6: Travel tools

**Files:**
- Create: `packages/roadbook-mcp/tools/travel.js`

- [ ] **Step 1: Create travel tools**

```javascript
// packages/roadbook-mcp/tools/travel.js
const { request } = require('../client');

const listTravels = {
  definition: {
    name: 'list_travels',
    description: '查询用户的行程列表。返回行程名称、日期、城市等基本信息。用于了解用户已有的行程，以便在已有行程上添加日程或创建新行程。',
    inputSchema: {
      type: 'object',
      properties: {
        page: { type: 'number', description: '页码，默认 1', default: 1 },
        pageSize: { type: 'number', description: '每页数量，默认 20', default: 20 },
        name: { type: 'string', description: '按行程名称搜索（可选）' },
      },
    },
  },
  async handler(params) {
    const data = await request('/api/travel/page', {
      page: params.page || 1,
      pageSize: params.pageSize || 20,
      name: params.name,
    });
    if (!data.record || data.record.length === 0) {
      return '当前没有行程。';
    }
    const lines = data.record.map(t =>
      `- 「${t.name}」(ID: ${t.id}) ${t.startDate} ~ ${t.endDate}${t.city ? ' | 城市: ' + t.city : ''}`
    );
    return `共 ${data.total} 个行程（第 ${data.page} 页）:\n${lines.join('\n')}`;
  },
};

const createTravel = {
  definition: {
    name: 'create_travel',
    description: '创建新行程。需要提供行程名称、开始日期、结束日期。创建后可通过 add_schedule 向行程中添加日程项。',
    inputSchema: {
      type: 'object',
      properties: {
        name: { type: 'string', description: '行程名称' },
        startDate: { type: 'string', description: '开始日期，格式 YYYY-MM-DD' },
        endDate: { type: 'string', description: '结束日期，格式 YYYY-MM-DD' },
        city: { type: 'string', description: '目的地城市（可选）' },
        public: { type: 'boolean', description: '是否公开，默认 false' },
      },
      required: ['name', 'startDate', 'endDate'],
    },
  },
  async handler(params) {
    const data = await request('/api/travel/save', {
      name: params.name,
      startDate: params.startDate,
      endDate: params.endDate,
      city: params.city,
      public: params.public || false,
    });
    return `已创建行程「${params.name}」(ID: ${data.id})，日期 ${params.startDate} ~ ${params.endDate}。`;
  },
};

const updateTravel = {
  definition: {
    name: 'update_travel',
    description: '更新已有行程的信息（名称、日期、城市等）。需要提供行程 ID。',
    inputSchema: {
      type: 'object',
      properties: {
        id: { type: 'number', description: '行程 ID' },
        name: { type: 'string', description: '行程名称' },
        startDate: { type: 'string', description: '开始日期，格式 YYYY-MM-DD' },
        endDate: { type: 'string', description: '结束日期，格式 YYYY-MM-DD' },
        city: { type: 'string', description: '目的地城市' },
      },
      required: ['id'],
    },
  },
  async handler(params) {
    const body = { id: params.id };
    if (params.name !== undefined) body.name = params.name;
    if (params.startDate !== undefined) body.startDate = params.startDate;
    if (params.endDate !== undefined) body.endDate = params.endDate;
    if (params.city !== undefined) body.city = params.city;
    await request('/api/travel/save', body);
    return `已更新行程 (ID: ${params.id})。`;
  },
};

const getTravelDetail = {
  definition: {
    name: 'get_travel_detail',
    description: '获取行程详情，包含所有日程项。用于查看行程的完整信息和已有日程安排。',
    inputSchema: {
      type: 'object',
      properties: {
        id: { type: 'number', description: '行程 ID' },
      },
      required: ['id'],
    },
  },
  async handler(params) {
    const data = await request('/api/travel/detail', { id: params.id });
    let result = `行程「${data.name}」(ID: ${data.id})\n日期: ${data.startDate} ~ ${data.endDate}`;
    if (data.city) result += `\n城市: ${data.city}`;
    if (data.Schedules && data.Schedules.length > 0) {
      result += `\n\n共 ${data.Schedules.length} 个日程项:`;
      data.Schedules.forEach(s => {
        result += `\n- 「${s.name}」(ID: ${s.id})`;
        if (s.startTime) result += ` | ${s.startTime}`;
        if (s.endTime) result += ` ~ ${s.endTime}`;
        if (s.address) result += ` | ${s.address}`;
        if (s.traffic) result += ` | 交通: ${s.traffic}`;
        if (s.isHotel) result += ' | 🏨 住宿';
        if (s.notes) result += `\n  备注: ${s.notes}`;
      });
    } else {
      result += '\n\n暂无日程项。';
    }
    return result;
  },
};

module.exports = [listTravels, createTravel, updateTravel, getTravelDetail];
```

- [ ] **Step 2: Commit**

```bash
git add packages/roadbook-mcp/tools/travel.js
git commit -m "feat(mcp): add travel tools (list, create, update, detail)"
```

---

### Task 7: Schedule tools

**Files:**
- Create: `packages/roadbook-mcp/tools/schedule.js`

- [ ] **Step 1: Create schedule tools**

```javascript
// packages/roadbook-mcp/tools/schedule.js
const { request } = require('../client');

const listSchedules = {
  definition: {
    name: 'list_schedules',
    description: '获取某个行程的所有日程项列表，按时间排序。用于查看行程中已有的安排。',
    inputSchema: {
      type: 'object',
      properties: {
        travelId: { type: 'number', description: '行程 ID' },
      },
      required: ['travelId'],
    },
  },
  async handler(params) {
    const data = await request('/api/travel/schedule/list', { tId: params.travelId });
    if (!data || data.length === 0) {
      return '该行程暂无日程项。';
    }
    const lines = data.map(s => {
      let line = `- 「${s.name}」(ID: ${s.id})`;
      if (s.startTime) line += ` | ${s.startTime}`;
      if (s.endTime) line += ` ~ ${s.endTime}`;
      if (s.address) line += ` | ${s.address}`;
      if (s.traffic) line += ` | 交通: ${s.traffic}`;
      if (s.isHotel) line += ' | 住宿';
      return line;
    });
    return `共 ${data.length} 个日程项:\n${lines.join('\n')}`;
  },
};

const addSchedule = {
  definition: {
    name: 'add_schedule',
    description: '向行程中添加一个日程项（景点、餐厅、酒店等）。coordinate 格式为 "经度,纬度"（如 "116.397428,39.90923"）。traffic 可选值: car, taxi, walk, bus, train, ship, ride, plane。startTime/endTime 格式为 "YYYY-MM-DD HH:mm:ss"。',
    inputSchema: {
      type: 'object',
      properties: {
        tId: { type: 'number', description: '行程 ID' },
        name: { type: 'string', description: '地点/活动名称' },
        coordinate: { type: 'string', description: '坐标，格式 "经度,纬度"' },
        isHotel: { type: 'boolean', description: '是否为住宿' },
        address: { type: 'string', description: '详细地址（可选）' },
        startTime: { type: 'string', description: '开始时间 YYYY-MM-DD HH:mm:ss（可选）' },
        endTime: { type: 'string', description: '结束时间 YYYY-MM-DD HH:mm:ss（可选，住宿类建议填写退房时间）' },
        traffic: { type: 'string', description: '到达此地点的交通方式（可选）: car, taxi, walk, bus, train, ship, ride, plane', enum: ['car', 'taxi', 'walk', 'bus', 'train', 'ship', 'ride', 'plane'] },
        notes: { type: 'string', description: '备注信息（可选）' },
      },
      required: ['tId', 'name', 'coordinate', 'isHotel'],
    },
  },
  async handler(params) {
    const body = {
      tId: params.tId,
      name: params.name,
      coordinate: params.coordinate,
      isHotel: params.isHotel,
    };
    if (params.address !== undefined) body.address = params.address;
    if (params.startTime !== undefined) body.startTime = params.startTime;
    if (params.endTime !== undefined) body.endTime = params.endTime;
    if (params.traffic !== undefined) body.traffic = params.traffic;
    if (params.notes !== undefined) body.notes = params.notes;

    const data = await request('/api/travel/schedule/add', body);
    return `已添加日程「${params.name}」(ID: ${data.id}) 到行程中。`;
  },
};

const updateSchedule = {
  definition: {
    name: 'update_schedule',
    description: '修改已有的日程项信息。只需传入要修改的字段，未传入的字段保持不变。将字段设为 null 可清除该字段的值。',
    inputSchema: {
      type: 'object',
      properties: {
        id: { type: 'number', description: '日程项 ID' },
        name: { type: 'string', description: '地点/活动名称' },
        coordinate: { type: 'string', description: '坐标，格式 "经度,纬度"' },
        isHotel: { type: 'boolean', description: '是否为住宿' },
        address: { type: ['string', 'null'], description: '详细地址' },
        startTime: { type: ['string', 'null'], description: '开始时间 YYYY-MM-DD HH:mm:ss' },
        endTime: { type: ['string', 'null'], description: '结束时间 YYYY-MM-DD HH:mm:ss' },
        traffic: { type: ['string', 'null'], description: '交通方式: car, taxi, walk, bus, train, ship, ride, plane' },
        notes: { type: ['string', 'null'], description: '备注信息' },
      },
      required: ['id'],
    },
  },
  async handler(params) {
    const body = { id: params.id };
    const fields = ['name', 'coordinate', 'isHotel', 'address', 'startTime', 'endTime', 'traffic', 'notes'];
    for (const field of fields) {
      if (params[field] !== undefined) body[field] = params[field];
    }
    await request('/api/travel/schedule/update', body);
    return `已更新日程项 (ID: ${params.id})。`;
  },
};

const removeSchedule = {
  definition: {
    name: 'remove_schedule',
    description: '删除一个日程项。此操作不可撤销。',
    inputSchema: {
      type: 'object',
      properties: {
        id: { type: 'number', description: '日程项 ID' },
      },
      required: ['id'],
    },
  },
  async handler(params) {
    await request('/api/travel/schedule/remove', { id: params.id });
    return `已删除日程项 (ID: ${params.id})。`;
  },
};

module.exports = [listSchedules, addSchedule, updateSchedule, removeSchedule];
```

- [ ] **Step 2: Commit**

```bash
git add packages/roadbook-mcp/tools/schedule.js
git commit -m "feat(mcp): add schedule tools (list, add, update, remove)"
```

---

### Task 8: MCP Server entry point

**Files:**
- Create: `packages/roadbook-mcp/index.js`

- [ ] **Step 1: Create MCP server entry point**

```javascript
#!/usr/bin/env node
// packages/roadbook-mcp/index.js
const { McpServer } = require('@modelcontextprotocol/sdk/server/mcp.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');

const travelTools = require('./tools/travel');
const scheduleTools = require('./tools/schedule');

const server = new McpServer({
  name: 'roadbook',
  version: '1.0.0',
});

const allTools = [...travelTools, ...scheduleTools];

for (const tool of allTools) {
  server.tool(
    tool.definition.name,
    tool.definition.description,
    tool.definition.inputSchema.properties,
    async (params) => {
      try {
        const text = await tool.handler(params);
        return { content: [{ type: 'text', text }] };
      } catch (e) {
        return { content: [{ type: 'text', text: `错误: ${e.message}` }], isError: true };
      }
    }
  );
}

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((e) => {
  console.error('MCP Server 启动失败:', e);
  process.exit(1);
});
```

- [ ] **Step 2: Make entry point executable**

Run: `chmod +x packages/roadbook-mcp/index.js`

- [ ] **Step 3: Verify MCP server starts**

Run: `cd packages/roadbook-mcp && ROADBOOK_API_URL=http://localhost:3000 ROADBOOK_API_KEY=test node index.js`

Expected: Process starts and waits for stdio input (no crash). Press Ctrl+C to exit.

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-mcp/index.js
git commit -m "feat(mcp): add server entry point with stdio transport"
```

---

### Task 9: End-to-end verification

**Files:** None (testing only)

- [ ] **Step 1: Start the API dev server**

Run: `cd packages/roadbook-api && npm run dev`

- [ ] **Step 2: Run the database migration**

Run (in another terminal): `cd packages/roadbook-api && npx sequelize-cli db:migrate`

- [ ] **Step 3: Create a test API Key**

Use an existing user's JWT token to call:
```bash
curl -X POST http://localhost:3000/api/user/apikey/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your-jwt-token>" \
  -d '{"name": "MCP Test"}'
```
Save the returned `key` value.

- [ ] **Step 4: Test MCP with Claude Code**

Add to Claude Code MCP config (`~/.claude/settings.json` or project `.mcp.json`):
```json
{
  "mcpServers": {
    "roadbook": {
      "command": "node",
      "args": ["/absolute/path/to/packages/roadbook-mcp/index.js"],
      "env": {
        "ROADBOOK_API_URL": "http://localhost:3000",
        "ROADBOOK_API_KEY": "rb_xxx..."
      }
    }
  }
}
```

Verify in Claude Code that `list_travels`, `create_travel`, `add_schedule` etc. tools appear and can be called.

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat: roadbook MCP server with API Key auth - complete implementation"
```
