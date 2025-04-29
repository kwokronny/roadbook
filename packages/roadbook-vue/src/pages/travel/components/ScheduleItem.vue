<template>
  <div class="schedule-item text-c_t">
    <h2 class="schedule-item__header">
      <div class="flex-h flex-ai_c gap-s1">
        <template v-if="item.isHotel">
          <MazIcon size="30px" name="hotel"></MazIcon>
          <span>酒店</span>
        </template>
        <template v-else>
          <MazIcon size="30px" name="time"></MazIcon>
          <span>
            {{ item.startTime ? DateUtil.timeFm(item.startTime) : "未安排" }}
          </span>
        </template>
      </div>
      <div class="flex-h gap-s1 align-center">
        <MazIcon
          name="solar/edit"
          @click="emit('action', 'edit')"
          class="text-c_ts curs-pointer"
        ></MazIcon>
        <Dropdown v-if="canEdit" :items="dropMenu">
          <MazIcon name="more" class="text-c_ts curs-pointer"></MazIcon>
        </Dropdown>
      </div>
    </h2>
    <MazCardSpotlight
      :color="item.isHotel ? 'warning' : 'info'"
      style="width: 100%; display: block"
    >
      <div class="spac-p_s2 flex-v" style="gap: 16px">
        <div class="flex-h">
          <MazAvatar
            rounded-size="lg"
            fallback-src="/logo.png"
            :src="item.cover"
          >
            <template #icon>
              <MazIcon name="more" class="text-c_w"></MazIcon>
            </template>
          </MazAvatar>
          <div class="spac-ml_s2" style="width: 0; flex: 1">
            <h3 class="text-o_e spac-mv_s0 text-s_m">
              {{ item.name }}
            </h3>
            <div class="text-clamp_2 text-s_s text-c_ts">
              {{ item.address }}
            </div>
          </div>
        </div>
        <div class="flex-h gap-s1">
          <TrafficBtn
            :coordinate="item.coordinate"
            :traffic="item.traffic || 'car'"
            :name="item.name"
            style="flex: 1; width: 0"
          ></TrafficBtn>
          <DianpinBtn
            v-if="item.dianpingUUID"
            :uuid="item.dianpingUUID"
          ></DianpinBtn>
        </div>
        <details class="notes">
          <summary>备注：</summary>
          <div class="text-s_s">
            {{ item.notes }}
          </div>
        </details>
        <template v-if="item.screenshots">
          <MazLazyImg v-for="url in item.screenshots.split(',')" :src="url" />
        </template>
      </div>
    </MazCardSpotlight>
  </div>
</template>
<script setup lang="ts">
import TrafficBtn from "@/components/TrafficBtn.vue";
import DianpinBtn from "@/components/DianpinBtn.vue";
import Dropdown from "@/components/Dropdown.vue";
import { DateUtil } from "@/helper/util";
import { ISchedule } from "@/server/travel";
import { toRefs } from "vue";

const props = defineProps<{
  item: ISchedule;
  canEdit: boolean;
}>();

const { item, canEdit } = toRefs(props);

const emit = defineEmits<{
  (e: "action", actionType: "edit" | "clone" | "remove"): void;
}>();

//#region 行程编辑
const dropMenu = [
  {
    label: "克隆",
    icon: "solar/copy",
    itemClass: "text-c_ts",
    action: () => emit("action", "clone"),
  },
  {
    label: "移除",
    icon: "solar/close",
    itemClass: "text-c_danger",
    action: () => emit("action", "remove"),
  },
];

// #endregion
</script>
<style lang="stylus" scoped>

.schedule-item{
  width: 100%;
  margin-bottom: 24px;
  .m-avatar .m-avatar__wrapper{
    width: 65px;
    height: 65px;
    background-image: var(--bg-gradient);
  }
  &__header{
    l-flex: h sb c;
    margin: yoz_spacing.s1
    // svg{
    //   cursor pointer
    // }
  }
}
.notes{
  summary{
    font-size: 14px;
    cursor: pointer;
  }
  white-space: pre-wrap;
  word-break: break-all;
  color: #666
}
</style>
