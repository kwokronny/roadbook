import { createApp } from "vue";
import { createPinia } from "pinia";
import piniaPluginPersistedstate from "pinia-plugin-persistedstate";
import App from "./App.vue";

const app = createApp(App);
const pinia = createPinia();
pinia.use(piniaPluginPersistedstate);
app.use(pinia);

import MazUI from "./plugins/maz-ui";
import "./plugins/dayjs";
MazUI(app);

import Header from "./components/Header.vue";
import Sketch from "./components/sketch/Sketch.vue";
import SketchItem from "./components/sketch/SketchItem.vue";

app.component("Header", Header);
app.component("Sketch", Sketch);
app.component("SketchItem", SketchItem);

import "stylus-shortcut/src/shortcut.styl";
import "./style/index.styl";

window._AMapSecurityConfig = {
  serviceHost: "/_AMapService",
};

if (import.meta.env.DEV) {
  window._AMapSecurityConfig = {
    securityJsCode: import.meta.env.VITE_AMAP_SECRET,
  };
}

import router from "./plugins/router";
app.use(router);

app.mount("#app");
