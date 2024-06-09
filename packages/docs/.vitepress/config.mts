import { defineConfig } from "vitepress";
// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "小肥路书",
  description: "小肥路书 帮助文档",
  outDir: './dist',
  srcDir: "./src",
  base: "/docs",
  head: [
    [
      "link",
      {
        rel: "icon",
        href: "https://asset.chatbooster.ai/chart-smart/prod/statics/favicon.ico",
      },
    ],
    [
      "link",
      {
        rel: "icon",
        type: "image/png",
        href: "https://asset.chatbooster.ai/chart-smart/prod/statics/favicon-32x32.png",
      },
    ],
    [
      "link",
      {
        rel: "icon",
        type: "image/png",
        href: "https://asset.chatbooster.ai/chart-smart/prod/statics/favicon-16x16.png",
      },
    ],
  ],
  themeConfig: {
    siteTitle: "小肥路书",
    // https://vitepress.dev/reference/default-theme-config
    // nav: [{ text: "Home", link: "/" }],

    sidebar: [
      { text: "🗺️ 旅程计划", link: "/l-cheng-ji-hua" },
      { text: "🤝 协作者管理", link: "/xie-zuo-zhe-guan-li" },
      { text: "🧳 行李清点", link: "/xing-li-qing-dian" },
      { text: "🐳 自建服务", link: "/zi-jian-fu-wu" },
    ],

    socialLinks: [
      { icon: "github", link: "https://github.com/kwokronny/roadbook" },
    ],
  },
});
