import { IUser, userApi } from "@/server/user";
import { defineStore } from "pinia";
import { ref } from "vue";
import { useThemeHandler, type ThemeHandlerOptions } from "maz-ui";

export const useStore = defineStore(
  "main",
  () => {
    const token = ref("");
    const userInfo = ref<IUser>();

    function setToken(val: string) {
      token.value = val;
    }
    async function getCurrentInfo() {
      const res = await userApi.detail();
      userInfo.value = res.data;
    }

    // optional
    const options: ThemeHandlerOptions = {
      darkClass: "dark",
      lightClass: "light",
    };

    const { autoSetTheme, toggleTheme, theme } = useThemeHandler(options);
    autoSetTheme();
    return { token, userInfo, setToken, getCurrentInfo, theme, toggleTheme };
  },
  {
    persist: {
      key: "xf-roadbook",
      paths: ["token", "userInfo"],
    },
  }
);
