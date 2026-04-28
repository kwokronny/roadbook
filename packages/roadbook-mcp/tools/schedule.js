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
    const data = await request('/api/travel/schedule/list', { id: params.travelId });
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
