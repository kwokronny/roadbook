<template>
  <MazDropdown :items="items" position="bottom right" trigger="click">
    <template #menuitem="{ item: menuItem }">
      <button
        tabindex="-1"
        type="button"
        :class="`menuitem ${menuItem.class} ${menuItem.itemClass}`"
        @click.stop="menuItem.action()"
      >
        <div class="flex-h flex-ai_c gap-s1 text-s_s">
          <MazIcon :name="menuItem.icon" size="18px" />
          <span> {{ menuItem.label }} </span>
        </div>
      </button>
    </template>
    <template #element>
      <slot></slot>
    </template>
  </MazDropdown>
</template>
<script setup lang="ts">
import { toRefs } from "vue";

const props = defineProps<{
  items: any[];
}>();

const { items } = toRefs(props);
</script>
