<template>
  <div class="schedule-item text-c_t">
    <h2 class="schedule-item__header">
      <div class="flex-h flex-ai_c gap-s1 drag-handle" :title="title">
        <MazIcon v-if="item.isHotel" size="30px" name="hotel"></MazIcon>
        <MazIcon v-else size="30px" name="time"></MazIcon>
        <span> {{ title }} </span>
      </div>
      <div class="flex-h gap-s1 flex-ai_c">
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
    <div class="schedule-item__content" style="gap: 16px">
      <div class="spac-p_s2 flex-v gap-s2">
        <div class="flex-h">
          <MazAvatar
            rounded-size="md"
            size="1.3rem"
            fallback-src="/logo.png"
            :src="item.cover"
          >
            <template #icon>
              <MazIcon name="more" class="text-c_w"></MazIcon>
            </template>
          </MazAvatar>
          <div class="spac-ml_s2" style="width: 0; flex: 1">
            <h3 class="text-o_e spac-mv_0 text-s_m">
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
      </div>
      <div class="line-t_do1 spac-ph_s2 spac-pv_s1">
        <MazTransitionExpand>
          <template v-if="moreShow && item.notes">
            <div class="text-s_s text-c_ts spac-mb_s1">备注</div>
            <div
              class="text-s_s text-clamp_3 spac-mb_s1"
              v-html="parseNotes(item.notes || '')"
            />
          </template>
          <template v-if="moreShow && item.screenshots">
            <div class="text-s_s text-c_ts spac-mb_s1">截图</div>
            <div class="screenshots spac-mb_s1">
              <MazAvatar
                rounded-size="xl"
                size="1.5rem"
                v-for="url in item.screenshots.split(',')"
                v-fullscreen-img="url"
                :src="url"
              />
            </div>
          </template>
        </MazTransitionExpand>
        <div
          class="text-s_s text-c_ts text-a_c curs-pointer"
          @click="moreShow = !moreShow"
        >
          {{ moreShow ? "收起" : "更多" }}
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import TrafficBtn from "@/components/TrafficBtn.vue";
import DianpinBtn from "@/components/DianpinBtn.vue";
import Dropdown from "@/components/Dropdown.vue";
import { DateUtil, parseNotes } from "@/helper/util";
import { ISchedule } from "@/server/travel";
import { computed, inject, ref, Ref, toRefs } from "vue";
import { roleType } from "@/helper/enum";

const props = defineProps<{
  item: ISchedule;
}>();

const { item } = toRefs(props);
const perm = inject<Ref<roleType>>("perm");
const canEdit = computed(() => perm?.value === "manage");

const emit = defineEmits<{
  (e: "action", actionType: "edit" | "clone" | "remove"): void;
  (e: "drag", pointerEvent: PointerEvent): void;
}>();

const title = computed(() => {
  if (item.value.isHotel) {
    return "酒店";
  }
  return item.value.startTime
    ? DateUtil.timeFm(item.value.startTime)
    : "未安排";
});
//#region 行程编辑
const dropMenu = [
  {
    label: "复制",
    icon: "solar/copy",
    class: "text-c_ts",
    action: () => emit("action", "clone"),
  },
  {
    label: "移除",
    icon: "solar/close",
    class: "text-c_danger",
    action: () => emit("action", "remove"),
  },
];

const moreShow = ref(false);

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
.schedule-item__content{
  border-radius: var(--maz-border-radius);
  // box-shadow: 0 5px 10px #0000000d;
  background: var(--maz-color-bg);
  border: 1px solid var(--maz-color-success-200);
  // padding: yoz_spacing.s2;
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
.screenshots{
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
  margin-top: 8px;
  // padding: 0 8px;
}
</style>
