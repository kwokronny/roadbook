import { defineConfig } from "vite";
import Components from "unplugin-vue-components/vite";
import {
  UnpluginVueComponentsResolver,
  UnpluginDirectivesResolver,
  UnpluginModulesResolver,
} from "maz-ui/resolvers";
import vue from "@vitejs/plugin-vue";
import path from "path";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    Components({
      dts: true,
      resolvers: [
        UnpluginVueComponentsResolver(),
        UnpluginDirectivesResolver(),
        UnpluginModulesResolver(),
      ],
    }),
  ],
  server: {
    host: "0.0.0.0",
    port: 6847,
  },
  resolve: {
    alias: {
      "@": path.join(__dirname, "src"),
    },
  },
  css: {
    preprocessorOptions: {
      stylus: {
        additionalData: `@import "${path.join(
          __dirname,
          "src"
        )}/style/variable.styl"; @import "stylus-shortcut/src/mixin.styl"`,
      },
      styl: {
        additionalData: `@import "${path.join(
          __dirname,
          "src"
        )}/style/variable.styl"; @import "stylus-shortcut/src/mixin.styl"`,
      },
    },
  },
});
