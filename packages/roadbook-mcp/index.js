#!/usr/bin/env node
// packages/roadbook-mcp/index.js
const { McpServer } = require('@modelcontextprotocol/sdk/server/mcp.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const { z } = require('zod');

const travelTools = require('./tools/travel');
const scheduleTools = require('./tools/schedule');

const server = new McpServer({
  name: 'roadbook',
  version: '1.0.0',
});

// Convert JSON Schema property to Zod schema
function toZod(prop) {
  const type = Array.isArray(prop.type) ? prop.type[0] : prop.type;
  const nullable = Array.isArray(prop.type) && prop.type.includes('null');
  let schema;
  if (type === 'number') schema = z.number();
  else if (type === 'boolean') schema = z.boolean();
  else schema = z.string();
  if (prop.enum) schema = z.enum(prop.enum);
  if (prop.description) schema = schema.describe(prop.description);
  if (nullable) schema = schema.nullable();
  return schema;
}

// Convert JSON Schema properties to Zod raw shape
function toZodShape(inputSchema) {
  const shape = {};
  const required = inputSchema.required || [];
  for (const [key, prop] of Object.entries(inputSchema.properties || {})) {
    let schema = toZod(prop);
    if (!required.includes(key)) schema = schema.optional();
    shape[key] = schema;
  }
  return shape;
}

const allTools = [...travelTools, ...scheduleTools];

for (const tool of allTools) {
  const zodShape = toZodShape(tool.definition.inputSchema);
  server.registerTool(
    tool.definition.name,
    {
      description: tool.definition.description,
      inputSchema: zodShape,
    },
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
