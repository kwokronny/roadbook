import { defineConfig } from "vitepress";
import markdownItContainer from "markdown-it-container";
// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "小肥路书",
  description: "小肥路书 帮助文档",
  outDir: "./dist",
  srcDir: "./src",
  base: "/roadbook",
  head: [
    [
      "link",
      {
        rel: "icon",
        href: "/favicon.ico",
      },
    ],
    [
      "link",
      {
        rel: "icon",
        type: "image/png",
        href: "/favicon-32x32.png",
      },
    ],
    [
      "link",
      {
        rel: "icon",
        type: "image/png",
        href: "/favicon-16x16.png",
      },
    ],
  ],
  themeConfig: {
    siteTitle: "小肥路书",
    // https://vitepress.dev/reference/default-theme-config
    nav: [{ text: "作者", link: "https://kwokronny.com" }],

    sidebar: [
      { text: "📝 更新日志", link: "/CHANGELOG" },
      { text: "🐳 自建服务", link: "/docker-self-hosted" },
      {
        text: "使用教程",
        items: [
          { text: "🗺️ 旅程计划", link: "/travel-planning" },
          { text: "🤝 协作者管理", link: "/user-perm-manage" },
          { text: "🧳 行李清点", link: "/luggage-check" },
        ],
      },
    ],
    outline: {
      level: [2, 3],
    },

    search: {
      provider: "local",
    },

    socialLinks: [
      { icon: "github", link: "https://github.com/kwokronny/roadbook" },
    ],
  },
  markdown: {
    config: (md) => {
      md.use(markdownItContainer as any, "column", {
        validate: function (params: string) {
          return params.trim().match(/^column\s+(.*)$/);
        },
        render: function (tokens: any, idx: number) {
          const m = tokens[idx].info.trim().match(/^column\s+(.*)$/);
          if (tokens[idx].nesting === 1) {
            const columnCount = md.utils.escapeHtml(m[1]);
            return `<div class="column" style="--markdown-columns: ${
              columnCount || 1
            }">`;
          } else {
            return "</div>";
          }
        },
      });
    },
  },
});
