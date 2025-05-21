<template>
  <MazDropdown
    :items="items"
    position="bottom right"
    trigger="click"
    :class="[{ 'is-fit': fit }]"
  >
    <template #menuitem="{ item: menuItem }">
      <component
        :is="menuItem.href ? 'a' : 'div'"
        tabindex="-1"
        :href="menuItem.href"
        target="_blank"
        rel="noreferrer noopener"
        :class="[
          'menuitem',
          menuItem.class,
          'flex-h flex-ai_c gap-s1 text-s_s',
        ]"
        v-on="{
          click: menuItem.action,
        }"
      >
        <MazIcon v-if="menuItem.icon" :name="menuItem.icon || ''" size="18px" />
        <span> {{ menuItem.label }} </span>
      </component>
    </template>
    <template #element>
      <slot></slot>
    </template>
  </MazDropdown>
</template>
<script setup lang="ts">
import { toRefs } from "vue";
import { type MenuItem } from "maz-ui/components/MazDropdown";
const props = defineProps<{
  items: Array<MenuItem & { icon?: string }>;
  fit?: boolean;
}>();

const { items, fit } = toRefs(props);
</script>
<style lang="stylus" scoped>
.is-fit {
  :deep(.menu) {
    width: 100%;
  }
}
</style>
