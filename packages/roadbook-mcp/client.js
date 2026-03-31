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
