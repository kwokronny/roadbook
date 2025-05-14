<template>
  <div class="sketch-item" :data-type="type" :style="sty">
    <slot></slot>
  </div>
</template>
<script setup lang="ts">
import { computed } from "vue";

interface IProp {
  type: "hn" | "text" | "circle" | "box";
  size?: string;
}
const { type, size } = defineProps<IProp>();
const sty = computed(() => {
  if (type === "circle") {
    return {
      width: size || "100%",
      height: size || "100%",
    };
  } else {
    return {
      width: size || "100%",
    };
  }
});
</script>
<style lang="stylus" scoped>
.sketch-item {
  opacity 0.6;
  background: linear-gradient(120deg,  #cccccc 25%,  #f2f2f2 37%,  #cccccc 63%);
  background-size: 400% 100%;
  animation: sketchBg 1.4s ease infinite;
  display: inline-block;
  // margin-bottom: 16px;
  &[data-type=hn]{
    min-height: 24px;
    border-radius: 4px;
  }
  &[data-type=text]{
    min-height: 14px;
    border-radius: 4px;
  }
  &[data-type=circle]{
    aspect-ratio: 1;
    border-radius: 100%;
  }
  &[data-type=box]{
    background none;
    border: yoz_line.do1
    border-color: #cccccc;
  }
}
.sketch-item +.sketch-item:not([data-type=circle]){
  margin-top: 8px;
}
@keyframes sketchBg {
  0% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0 50%;
  }
}
</style>
