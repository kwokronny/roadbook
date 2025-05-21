<template>
  <div
    class="quote radius-md spac-p_s2 text-s_s flex-h gap-s1 flex-ai_s"
    :style="{
      '--quote-bg': `var(--maz-color-${color}-100)`,
      '--quote-color': `var(--maz-color-${color}-800)`,
    }"
  >
    <MazIcon :name="icon" size="36px" class="quote-icon"></MazIcon>
    <div><slot></slot></div>
  </div>
</template>
<script setup lang="ts">
withDefaults(
  defineProps<{
    color:
      | "success"
      | "warning"
      | "danger"
      | "info"
      | "primary"
      | "secondary"
      | "theme";
    icon?: string;
  }>(),
  {
    icon: "solar/help-sequare",
  }
);
</script>
<style lang="stylus" scoped>
.quote{
  background-color: var(--quote-bg)
  color: var(--quote-color)
}
.quote-icon{
  flex-shrink: 0;
}
</style>
