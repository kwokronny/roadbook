<template>
  <MazBtn
    fab
    rounded
    outline
    size="sm"
    icon="dianping"
    color="warning"
    :href="dianpingUrl"
    target="_blank"
    v-tooltip.bottom="'跳到点评链接'"
  >
  </MazBtn>
</template>
<script lang="ts" setup>
import { type Platform, getPlatform } from "@/helper/util";
import { computed } from "vue";
const { uuid } = defineProps<{
  uuid: string;
}>();

const platform: Platform = getPlatform();

const dianpingUrl = computed(() => {
  if (platform === "ios" || platform === "android") {
    return `dianping://shopinfo?shopuuid=${uuid}`;
  } else {
    return `https://www.dianping.com/shop/${uuid}`;
  }
});
</script>
