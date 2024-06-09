<template>
  <div
    class="bg-c_bg radius-b shadow-ph spac-m_a text-a_c spac-p_s4"
    style="width: 400px"
  >
    <MazIcon name="accept" size="80px"></MazIcon>
    <h2 class="text-c_t">接受邀请</h2>
    <div class="text-c_ts">当前未登录，请先登录/注册</div>
    <div class="spac-mt_s5 flex-v gap-s2">
      <MazBtn
        block
        @click="router.push(`/signin?inviteToken=${query.inviteToken}`)"
        color="success"
      >
        登录
      </MazBtn>
      <MazBtn
        block
        @click="router.push(`/signup?inviteToken=${query.inviteToken}`)"
        color="info"
        pastel
      >
        注册
      </MazBtn>
    </div>
  </div>
</template>
<script setup lang="ts">
import { travelApi } from "@/server/travel";
import { useStore } from "@/store";
import { onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
const router = useRouter();
const { query } = useRoute();
const { token } = useStore();

onMounted(async () => {
  if (token && query.inviteToken) {
    const res = await travelApi.accept(query.inviteToken as string);
    if (res.code === 200) {
      router.push(`/travel/${res.data}`);
    }
  }
});
</script>
