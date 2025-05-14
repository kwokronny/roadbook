<template>
  <div class="radius-md line-a_so1 input-wrap">
    <div class="input-label">{{ label }}</div>
    <div class="hour-wrap">
      <div
        v-for="idx in 24"
        :key="idx"
        :class="hourCls(idx)"
        @click="emit('update:modelValue', idx)"
      >
        <span>{{ idx - 1 }}</span>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { toRefs } from "vue";

const props = defineProps<{
  modelValue: number;
  label: string;
}>();
const { modelValue } = toRefs(props);

const emit = defineEmits<{
  (e: "update:modelValue", value: number): void;
}>();

const hourCls = (num: number) => {
  let cls = ["hour"];
  if (num === modelValue.value) {
    cls.push("active");
  }
  return cls;
};
</script>
<style lang="stylus" scoped>
.input-wrap{
  padding: 4px 12px;
}
.input-label{
  font-size: 13px;
  color: var(--maz-color-muted);
  margin-bottom: 8px;
}
.hour-wrap{
  display: grid;
  grid-template-columns: repeat(12, 1fr);
}
.hour {
  l-flex: v c c;
  flex: 0 0 30px;
  cursor: pointer;
  height: 30px;
  border-radius: 8px;
  &:hover{
    background-color: var(--maz-color-primary-50);
  }
  &.active {
    background-color: var(--maz-color-primary);
    color: white;
  }
}
</style>
