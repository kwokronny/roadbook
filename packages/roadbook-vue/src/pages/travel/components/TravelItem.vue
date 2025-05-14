<template>
  <router-link :to="`/travel/${data.id}`" class="travel-item">
    <div class="flex-fill spac-p_s2 flex-v flex-jc_sb">
      <div class="flex-h gap-s1">
        <MazIcon name="solar/travel" size="20px" class="spac-mt_s0"></MazIcon>
        <div>
          <h3 class="text-c_t text-o_e spac-mv_0">{{ data.name }}</h3>
          <div class="text-c_ts text-s_s text-o_e">
            {{ DateUtil.travelDate(data.startDate, data.endDate) }}
          </div>
        </div>
      </div>
      <div class="user flex-h flex-ai_c">
        <MazAvatar
          v-for="user in data.Users?.slice(0, 3)"
          :src="user.avatar"
          fallback-src="/logo.png"
          size="0.5rem"
        ></MazAvatar>
        <div class="text-c_ts spac-ml_s1 text-s_s text-c_ts">
          共{{ data.Users?.length }}名成员
        </div>
      </div>
    </div>
    <div class="stub spac-p_s2 flex-v flex-jc_sb" :style="{'--stub-bg': trafficStatusEnum.get(data.status).color}">
      <div class="text-c_ts text-s_s text-a_r">
        <MazIcon name="solar/city" size="16px"></MazIcon>
        <div class="text-c_t text-o_e">
          {{ data.city }}
        </div>
      </div>
      <div class="text-c_ts text-s_s text-a_r">
        <strong>共 {{ data.duration }} 天</strong>
      </div>
    </div>
  </router-link>
</template>
<script setup lang="ts">
import { trafficStatusEnum } from "@/helper/enum";
import { DateUtil } from "@/helper/util";
import { ITravel } from "@/server/travel";
defineProps<{
  data: ITravel & { status: string; duration: number };
}>();
</script>
<style lang="stylus" scoped>
.travel-item{
  display: flex;
  flex-direction: row;
  height: 130px;
  border: 1px solid var(--maz-color-border);
  border-radius: var(--maz-border-radius);
  overflow: hidden;
  .stub{
    flex-shrink: 0;
    width: 120px;
    background-color: var(--stub-bg);
    border-left: 1px dashed var(--maz-color-border);
  }
  .user {
    .m-avatar + .m-avatar{
      margin-inline-start: -0.4rem;
    }
  }
}
</style>
