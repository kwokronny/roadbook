import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from "path"

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    host: "0.0.0.0",
    port: 6847,
    proxy: {
      "/be": {
        target: "http://localhost:3000",
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/be/, ""),
      },
    },
  },
  resolve: {
    alias: {
      "@": path.join(__dirname, "src")
    },
  },
  css: {
    preprocessorOptions: {
      stylus: {
        additionalData: `@import "${path.join(__dirname, "src")}/style/variable.styl"; @import "stylus-shortcut/src/mixin.styl"`,
      },
      styl: {
        additionalData: `@import "${path.join(__dirname, "src")}/style/variable.styl"; @import "stylus-shortcut/src/mixin.styl"`,
      },
    }
  }
})
