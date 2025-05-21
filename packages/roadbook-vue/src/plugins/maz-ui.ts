import { App } from "vue";
import "maz-ui/styles";
import { installToaster, installDialog } from "maz-ui";

// DEFAULT OPTIONS
export default (app: App) => {
  app.provide("mazIconPath", "/icons");
  app.use(installToaster, {
    position: "bottom-right",
    timeout: 1000,
    persistent: false,
  });
  app.use(installDialog);
};
