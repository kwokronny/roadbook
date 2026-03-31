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
  server.registerTool(
    tool.definition.name,
    {
      description: tool.definition.description,
      inputSchema: undefined,
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
