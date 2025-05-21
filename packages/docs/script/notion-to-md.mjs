import { Client } from '@notionhq/client';
import { NotionConverter } from "notion-to-md";
import { CustomMDXRenderer, FileSystemExporter } from './custom-render.mjs'
import path from 'path';
import { loadEnv } from 'vitepress';
const env = loadEnv("", process.cwd(), "");

const NOTION_API_TOKEN = env.NOTION_API_TOKEN;

const notion = new Client({ auth: NOTION_API_TOKEN });

const databaseId = env.NOTION_DATABASE_ID;
const response = await notion.databases.query({
  database_id: databaseId,
})
const data = response.results

async function convertPage(pageId) {
  const n2m = new NotionConverter(notion);

  n2m
    .downloadMediaTo({
      outputDir: './src/public/images',
      transformPath: (localPath) => `/images/${path.basename(localPath)}`
    })
    .withRenderer(new CustomMDXRenderer())
    .withExporter(new FileSystemExporter({
      outputDir: './src'
    }))

  await n2m.convert(pageId);
}

for (const page of data) {
  await convertPage(page.id)
}