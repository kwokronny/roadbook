// packages/roadbook-mcp/tools/travel.js
const { request } = require('../client');

// API validates startDate/endDate as dateTime — append time if only date given
function toDateTime(dateStr) {
  if (!dateStr) return dateStr;
  return dateStr.length === 10 ? dateStr + ' 00:00:00' : dateStr;
}

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
      name: params.name || '',
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
      startDate: toDateTime(params.startDate),
      endDate: toDateTime(params.endDate),
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
    // Fetch current travel to fill required fields for controller validation
    const current = await request('/api/travel/detail', { id: params.id });
    const body = {
      id: params.id,
      name: params.name !== undefined ? params.name : current.name,
      startDate: toDateTime(params.startDate !== undefined ? params.startDate : current.startDate),
      endDate: toDateTime(params.endDate !== undefined ? params.endDate : current.endDate),
      city: params.city !== undefined ? params.city : (current.city || ''),
      public: current.public || false,
    };
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
    // Schedules are not included in detail response — fetch separately
    const schedules = await request('/api/travel/schedule/list', { id: params.id });
    let result = `行程「${data.name}」(ID: ${data.id})\n日期: ${data.startDate} ~ ${data.endDate}`;
    if (data.city) result += `\n城市: ${data.city}`;
    if (schedules && schedules.length > 0) {
      result += `\n\n共 ${schedules.length} 个日程项:`;
      schedules.forEach(s => {
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
