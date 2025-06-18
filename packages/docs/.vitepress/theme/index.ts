import DefaultTheme from "vitepress/theme";
import { h } from "vue";
import "./custom.css";

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      "home-hero-image": () =>
        h("img", {
          src: "/roadbook/hero.webp",
          alt: "Roadbook",
          style: {
            width: "100%",
            height: "100%",
          },
        }),
    });
  },
};
