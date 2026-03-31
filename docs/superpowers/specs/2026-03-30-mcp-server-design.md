# Roadbook MCP Server 设计文档

## 概述

将路书 API 暴露为 MCP (Model Context Protocol) 工具，让 Claude Desktop / Claude Code 等 AI 助手可以直接连接路书 API，在完成行程规划后自动添加和管理行程。

## 设计决策

| 决策项 | 选择 | 理由 |
|--------|------|------|
| 方案 | 独立 MCP 包 | MCP 在本地运行，不能直连服务器数据库；独立包符合 monorepo 架构 |
| 部署形态 | Stdio 本地进程 | MCP 生态最成熟的方式，Claude Desktop/Code 原生支持 |
| 认证方式 | API Key | JWT 30 天过期对 MCP 不友好，OAuth 过于复杂 |
| 功能范围 | 完整行程管理（CRUD） | AI 需要查询现有行程才能做更好的规划决策 |
| 数据来源 | 纯 CRUD，不集成高德/点评 | 职责单一，POI 搜索交给其他 MCP 或 AI 自身能力 |

---

## 一、API Key 认证机制

### 数据模型

新增 `ApiKey` 模型（roadbook-api）：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INTEGER, PK | 主键 |
| `uId` | INTEGER, FK → User | 关联用户 |
| `key` | STRING, unique | `rb_` 前缀 + 32 位随机字符串 |
| `name` | STRING | 用户自定义名称（如"我的 Claude"） |
| `lastUsedAt` | DATE | 最后使用时间 |
| `createdAt` | DATE | 创建时间 |

### 认证流程

请求头格式：`Authorization: Bearer rb_xxx...`

在 JWT 中间件之前新增检测层：
1. 检测 token 是否以 `rb_` 开头
2. 是 → 查数据库找到对应 User，注入 `ctx.state.user`（与 JWT 行为一致），更新 `lastUsedAt`
3. 否 → 走原有 JWT 流程

API Key 无过期时间，用户可手动创建和删除。

### 新增路由

| 路由 | 说明 |
|------|------|
| `POST /api/user/apikey/create` | 创建 API Key，需要参数 `name`。返回完整 key（仅此一次可见） |
| `POST /api/user/apikey/list` | 列出用户的 API Key（key 脱敏显示，只显示前 7 位） |
| `POST /api/user/apikey/remove` | 删除 API Key，需要参数 `id` |

这三个路由需要 JWT 认证（用户通过前端登录后管理自己的 API Key）。

---

## 二、MCP Server 工具设计

### 包配置

包名：`packages/roadbook-mcp`

用户在 Claude Desktop 的 MCP 配置中添加：

```json
{
  "mcpServers": {
    "roadbook": {
      "command": "node",
      "args": ["path/to/packages/roadbook-mcp/index.js"],
      "env": {
        "ROADBOOK_API_URL": "https://your-server.com",
        "ROADBOOK_API_KEY": "rb_xxx..."
      }
    }
  }
}
```

### 工具清单（8 个）

| 工具名 | 描述 | 关键参数 |
|--------|------|---------|
| `list_travels` | 查询用户的行程列表 | `page`, `pageSize`, `name?`（搜索） |
| `create_travel` | 创建新行程 | `name`, `startDate`, `endDate`, `city?`, `public?` |
| `update_travel` | 更新行程信息 | `id`, `name?`, `startDate?`, `endDate?`, `city?` |
| `get_travel_detail` | 获取行程详情（含所有日程） | `id` |
| `list_schedules` | 获取某行程的日程列表 | `travelId` |
| `add_schedule` | 添加日程项 | `tId`, `name`, `coordinate`, `isHotel`, `startTime?`, `endTime?`, `traffic?`, `address?`, `notes?` |
| `update_schedule` | 修改日程项 | `id`, 各可选字段 |
| `remove_schedule` | 删除日程项 | `id` |

不包含 `clone_schedule`——AI 可以通过读取原日程 + `add_schedule` 实现相同效果。

每个工具提供详细的中文描述，包含字段说明和使用场景提示（如 traffic 枚举值 `car|taxi|walk|bus|train|ship|ride|plane`，coordinate 格式 `"lng,lat"`）。

---

## 三、MCP Server 内部架构

### 技术栈

- `@modelcontextprotocol/sdk` — MCP 协议实现
- `stdio` transport — 标准输入输出通信
- 原生 `fetch`（Node 18 内置）— 调用 roadbook-api

### 模块结构

```
packages/roadbook-mcp/
├── package.json
├── index.js          # 入口：初始化 MCP Server + stdio transport
├── client.js         # HTTP 客户端：封装 API 调用、认证、错误处理
└── tools/
    ├── travel.js     # list_travels, create_travel, update_travel, get_travel_detail
    └── schedule.js   # list_schedules, add_schedule, update_schedule, remove_schedule
```

### HTTP 客户端（client.js）

- 从环境变量读取 `ROADBOOK_API_URL` 和 `ROADBOOK_API_KEY`
- 启动时校验两个环境变量是否存在，缺失则报错退出
- 统一 POST 请求，请求头 `Authorization: Bearer rb_xxx`
- 统一错误处理：检查响应 `code !== 200` 时返回可读的错误信息给 AI

### 工具注册模式

- 每个工具文件导出 `{ definition, handler }`
- `definition` 包含 name、description、inputSchema（JSON Schema）
- `handler` 接收参数，调用 client，返回结果
- `index.js` 汇总注册所有工具

### 返回值设计

- 成功时返回结构化的文本内容（非原始 JSON），方便 AI 理解
- 例如 `add_schedule` 返回：`"已添加日程「故宫博物院」(ID: 42) 到行程中"`
- 列表类工具返回格式化的摘要文本

---

## 四、错误处理与安全边界

### 错误场景

| 场景 | 处理方式 |
|------|---------|
| API Key 无效/缺失 | 首次调用失败时返回："API Key 无效，请检查配置" |
| API 服务不可达 | 返回："无法连接到路书服务器，请检查 ROADBOOK_API_URL 配置" |
| 权限不足 | 透传 API 返回的错误信息 |
| 参数校验失败 | MCP JSON Schema 前置校验 + API 端二次校验，透传错误 |

### 安全边界

- API Key 权限等同于对应用户，复用现有角色体系，不做额外工具级权限限制
- MCP Server 不缓存任何数据，每次实时调用 API
- 环境变量中的 API Key 由用户自行管理，MCP Server 不持久化存储

### 不做的事情

- 不做 rate limiting（交给 API 端统一处理）
- 不做请求日志持久化（stdio 环境无意义）
- 不做 API Key 自动刷新（无过期时间）
