<template>
  <div class="radius-md line-a_so1 input-wrap">
    <div class="input-label">{{ label }}</div>
    <div class="day-wrap">
      <div
        v-for="day in days"
        :key="day.num"
        :class="dayCls(day.num)"
        @click="handleClick(day.num)"
        @mouseenter="handleMouseEnter(day.num)"
      >
        <span class="number">{{ day.num }} </span>
        <i class="week">{{ day.week }}</i>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import dayjs from "dayjs";
import { reactive, toRefs, computed } from "vue";

const props = defineProps<{
  modelValue: [number, number] | number;
  label: string;
  limitDate: [string, string];
  isRange: boolean;
}>();
const { isRange, modelValue } = toRefs(props);

const emit = defineEmits<{
  (e: "update:modelValue", value: [number, number] | number): void;
}>();

const dayCls = (num: number) => {
  let cls = ["day"];
  if (isRange.value) {
    if (range.start && range.end) {
      if (num === range.start || num === range.end) {
        cls.push("active");
      } else if (
        range.start < range.end &&
        num > range.start &&
        num < range.end
      ) {
        cls.push("between");
      } else if (
        range.start > range.end &&
        num > range.start &&
        num < range.end
      ) {
        cls.push("between");
      }
    } else if (range.start) {
      num === range.start && cls.push("active");
    } else if (Array.isArray(modelValue.value)) {
      if (num === modelValue.value[0] || num === modelValue.value[1]) {
        cls.push("active");
      } else if (num > modelValue.value[0] && num < modelValue.value[1]) {
        cls.push("between");
      }
    }
  } else if (num === modelValue.value) {
    cls.push("active");
  }
  return cls;
};
const range = reactive<{
  start?: number;
  end?: number;
}>({});

const handleMouseEnter = (num: number) => {
  if (isRange.value && range.start) {
    range.end = num;
  }
};

const handleClick = (num: number) => {
  if (isRange.value) {
    if (range.start === undefined) {
      range.start = num;
    } else {
      range.end = num;
      let [start, end] = Object.values(range).sort((a, b) => a - b);
      console.log(start, end);
      emit("update:modelValue", [start, end]);
      range.start = undefined;
      range.end = undefined;
    }
  } else {
    emit("update:modelValue", num);
  }
};

const days = computed(() => {
  let days = [];
  let start = dayjs(props.limitDate[0]);
  let end = dayjs(props.limitDate[1]);
  let idx = 1;
  while (start.isBefore(end)) {
    days.push({ num: idx++, week: start.format("ddd") });
    start = start.add(1, "day");
  }
  return days;
});
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
.day-wrap{
  padding: 6px 0;
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px
}
.day {
  l-flex: v c c;
  border-radius: 8px;
  // padding-top: 8px;
  cursor: pointer;
  color: var(--maz-color-text);
  position: relative;
  height: 60px;
  transition: background-color 0.3s ease;
  &:hover{
    background-color: var(--maz-color-primary-50);
  }
  &.between{
    background-color: var(--maz-color-primary-50);
    color: black;
    .number:before{
      color: black;
    }
  }
  &.active {
    background-color: var(--maz-color-primary);
    color: white;
    .number:before,.week{
      color: white;
    }
  }
  .number {
    text-align: center;
    t-fl: 24px 24px;
    &:before {
      content: "Day";
      display: block;
      t-fl: 12px 12px;
      color: var(--maz-color-muted);
    }
  }
  .week{
    t-fl: 12px 16px;
    text-align: center;
    position: absolute;
    font-style: normal;
    top: -3px;
    right: -3px;
    width: 32px;
    height: 16px;
    background-color: var(--maz-color-warning);
    color: white;
    padding: 0 4px;
    border-radius: 4px;
    text-align: center;
  }
}
</style>
