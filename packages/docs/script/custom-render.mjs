import { MDXRenderer } from 'notion-to-md/plugins/renderer';
import * as fs from 'fs/promises';
import * as path from 'path';

export class FileSystemExporter {
  // You can define custom configurations for your plugin, allowing users to tailor it to their needs.
  outputDir = './src';
  constructor(options) {
    this.outputDir = options.outputDir;
  }

  async export(data) {
    // Create output directory if it doesn't exist
    await fs.mkdir(this.outputDir, { recursive: true });
    const properties = data.blockTree.properties;

    // Generate filename from page properties or ID
    const slug = properties?.slug?.rich_text?.[0]?.plain_text || '';
    const title = properties?.title?.title?.[0]?.plain_text || 'Untitled';
    const filename = `${slug}.md`;
    await fs.writeFile(path.join(this.outputDir, `${slug}.json`), JSON.stringify(data), 'utf-8');
    if (slug === 'index') {
      data.content = data.content.substring(2)
    } else {
      data.content = `# ${title}\n${data.content.substring(2)}`
    }

    // Full path for the file
    const filepath = path.join(this.outputDir, filename);

    // Write content to file
    await fs.writeFile(filepath, data.content, 'utf-8');

    console.log(`✓ Exported page to ${filepath}`);
  }
}

export class CustomMDXRenderer extends MDXRenderer {
  constructor(config = {}) {
    super(config);
    this.setTemplate(`{{{imports}}}{{{content}}}`)
    this.createBlockTransformer("column_list", {
      transform: async ({ block, utils }) => {
        if (!block.children?.length) return '';

        const columnContent = await Promise.all(
          block.children.map((child) => utils.processBlock(child)),
        );

        return `::: column ${columnContent.length}\n${columnContent.join('\n')}\n:::\n`;
      }
    })
    this.createBlockTransformer("callout", {
      transform: async ({ block, utils }) => {
        const text = await utils.transformRichText(block.callout.rich_text);

        // Process children and maintain callout formatting
        const childContent = block.children?.length
          ? await Promise.all(
            block.children.map(child => utils.processBlock(child))
          ).then(content =>
            content
              .join('\n')
              .split('\n')
              .map(line => `> ${line}`)
              .join('\n')
          )
          : '';

        return `> 💡 ${text}\n${childContent}\n\n`;
      }
    })

    this.createBlockTransformer("code", {
      transform: async ({ block, utils }) => {
        const text = await utils.transformRichText(block.code.rich_text);
        const caption = block.code.caption?.[0]?.plain_text || '';
        const language = block.code.language || '';
        if (caption.trim() === 'hexo') {
          return `---\n${text}\n---\n`;
        }
        return `\`\`\`${language} ${caption}\n${text}\n\`\`\`\n\n`;
      }
    })
  }
}
