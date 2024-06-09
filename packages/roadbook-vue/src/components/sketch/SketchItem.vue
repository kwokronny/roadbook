<template>
  <div class="sketch-item" :data-type="type" :style="{ width: size || '100%' }">
    <slot></slot>
  </div>
</template>
<script setup lang="ts">
interface IProp {
  type: "hn" | "text" | "circle" | "box";
  size?: string;
}
const { type } = defineProps<IProp>();
</script>
<style lang="stylus">
.sketch-item {
  opacity 0.6;
  background: linear-gradient(120deg,  #cccccc 25%,  #f2f2f2 37%,  #cccccc 63%);
  background-size: 400% 100%;
  animation: sketchBg 1.4s ease infinite;
  border-radius: 8px;
  margin-bottom: 16px;
  &[data-type=hn]{
    min-height: 30px;
  }
  &[data-type=text]{
    min-height: 20px;
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
@keyframes sketchBg {
  0% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0 50%;
  }
}
</style>
