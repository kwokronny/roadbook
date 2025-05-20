import { Client } from '@notionhq/client';
import { NotionConverter } from "notion-to-md";
import { CustomMDXRenderer, FileSystemExporter } from './custom-render.mjs'
import path from 'path';

const NOTION_API_TOKEN = "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";

const notion = new Client({ auth: NOTION_API_TOKEN });

const databaseId = '1f884f1f41868012ac23ebc2fb6f5813';
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