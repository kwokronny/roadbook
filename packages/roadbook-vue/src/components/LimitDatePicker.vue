<template>
  <div class="radius-sm day-wrap line-a_so1">
    <div
      v-for="day in days"
      :key="day.num"
      :class="[
        'day',
        {
          active:
            isRange && Array.isArray(modelValue)
              ? day.num >= modelValue[0] && day.num <= modelValue[1]
              : day.num === modelValue,
        },
      ]"
      @click="handleClick(day.num)"
    >
      <span class="number">{{ day.num }} </span>
      <i class="week">{{ day.week }}</i>
    </div>
  </div>
  <!-- <div class="radius-sm hour-wrap line-a_so1">
    <div v-for="idx in 24" :key="idx" class="hour">
      <span>{{ idx }}</span>
    </div>
  </div> -->
</template>
<script setup lang="ts">
import dayjs from "dayjs";
import { computed } from "vue";

const props = defineProps<{
  modelValue: [number, number] | number;
  limitDate: [string, string];
  isRange: boolean;
}>();

const emit = defineEmits<{
  (e: "update:modelValue", value: [number, number] | number): void;
}>();

// const;

const handleClick = (num: number) => {
  emit("update:modelValue", num);
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
.day-wrap{
  border-radius: var(--maz-border-radius);
  overflow: auto hidden;
  display: grid;
  grid-template-columns: repeat(7, 1fr);
}
.day {
  l-flex: v c c;
  padding-top: 14px;
  cursor: pointer;
  color: var(--maz-color-text);
  position: relative;
  height: 65px;
  &:hover{
    background-color: var(--maz-color-bg-lighter);
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
    t-fl: 12px 14px;
    text-align: center;
    position: absolute;
    font-style: normal;
    top: 3px;
    right: 3px;
    width: 28px;
    height: 14px;
    background-color: var(--maz-color-warning);
    color: white;
    border-radius: 2px;
    text-align: center;
  }
}
// .hour-wrap{
//   border-radius: var(--maz-border-radius);
//   overflow: auto hidden;
//   display: grid;
//   grid-template-columns: repeat(6, 1fr);
// }
// .hour {
//   l-flex: v c c;
//   flex: 1 0 10px;
//   cursor: pointer;
//   height: 40px;
//   border-radius: var(--maz-border-radius);
//   &:hover{
//     background-color: var(--maz-color-bg-lighter);
//   }
// }
</style>
