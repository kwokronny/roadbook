<template>
  <header class="flex-h flex-ai_c flex-jc_sb">
    <div class="flex-h flex-ai_c text-c_t flex-fill" style="gap: 8px">
      <MazBtn
        fab
        icon="back"
        no-elevation
        color="transparent"
        v-if="props.back"
        @click="router.push('/travel')"
      ></MazBtn>
      <h2 class="spac-mv_0 flex-fill" style="width: 0">
        <slot name="title">小肥路书</slot>
      </h2>
    </div>
    <div class="flex-h shrink-0" style="gap: 8px">
      <slot name="extra"></slot>
    </div>
  </header>
</template>
<script setup lang="ts">
import { useRouter } from "vue-router";

const router = useRouter();
interface IProp {
  back?: boolean;
}
const props = defineProps<IProp>();
</script>
<style lang="stylus">
header{
  padding: 16px 16px;
}
</style>
