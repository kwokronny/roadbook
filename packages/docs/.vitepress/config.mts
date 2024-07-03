import { defineConfig } from "vitepress";
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
    nav: [{ text: "作者", link: "https://kwokronny.com" }],

    sidebar: [
      { text: "📝 更新日志", link: "/CHANGELOG" },
      {
        text: "使用教程",
        items: [
          { text: "🗺️ 旅程计划", link: "/l-cheng-ji-hua" },
          { text: "🤝 协作者管理", link: "/xie-zuo-zhe-guan-li" },
          { text: "🧳 行李清点", link: "/xing-li-qing-dian" },
        ],
      },
      { text: "🐳 自建服务", link: "/zi-jian-fu-wu" },
    ],

    socialLinks: [
      { icon: "github", link: "https://github.com/kwokronny/roadbook" },
      {
        icon: {
          svg: `
<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="M11.984 0A12 12 0 0 0 0 12a12 12 0 0 0 12 12a12 12 0 0 0 12-12A12 12 0 0 0 12 0zm6.09 5.333c.328 0 .593.266.592.593v1.482a.594.594 0 0 1-.593.592H9.777c-.982 0-1.778.796-1.778 1.778v5.63c0 .327.266.592.593.592h5.63c.982 0 1.778-.796 1.778-1.778v-.296a.593.593 0 0 0-.592-.593h-4.15a.59.59 0 0 1-.592-.592v-1.482a.593.593 0 0 1 .593-.592h6.815c.327 0 .593.265.593.592v3.408a4 4 0 0 1-4 4H5.926a.593.593 0 0 1-.593-.593V9.778a4.444 4.444 0 0 1 4.445-4.444h8.296Z"/></svg>`,
        },
        link: "https://gitee.com/kwokronny/roadbook",
      },
    ],
  },
});
