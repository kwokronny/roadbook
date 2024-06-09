<template>
  <slot></slot>
  <template v-if="loading">
    <slot v-for="_num in count" name="template" class="sketch-template"></slot>
  </template>
</template>
<script setup lang="ts">
interface IProp {
  loading: boolean;
  count: number;
}
const { loading } = defineProps<IProp>();
</script>
