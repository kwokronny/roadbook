<template>
  <div class="amap-container" ref="AMapContainer"></div>
</template>
<script lang="ts" setup>
import { MapUtil } from "@/helper/amap";
import { useStore } from "@/store";
import { storeToRefs } from "pinia";
import { onMounted, ref, watch, nextTick } from "vue";

const { theme } = storeToRefs(useStore());

interface IEmits {
  (e: "loaded", map: AMap.Map): void;
  (e: "resize"): void;
}
const emit = defineEmits<IEmits>();

const map = ref<AMap.Map>();
const AMapContainer = ref<HTMLElement>();

watch(
  () => theme.value,
  () => {
    map.value?.setMapStyle(
      `amap://styles/${theme.value == "light" ? "fresh" : "grey"}`
    );
  },
  { immediate: true }
);

onMounted(async () => {
  if (AMapContainer.value) {
    await nextTick();
    await MapUtil.getAMap();
    map.value = new window.AMap.Map(AMapContainer.value, {
      viewMode: "2D",
      mapStyle: `amap://styles/${theme.value == "light" ? "fresh" : "grey"}`,
      zoom: 13,
    });
    emit("loaded", map.value);
  }
});
</script>
<style lang="stylus">
.amap-container{
  l-wh 100% 100%;
}
</style>
