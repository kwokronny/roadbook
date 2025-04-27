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

      <!-- <MazDropdown
        v-if="perm !== 'view'"
        :items="scheduleOptionDropMenu"
        position="bottom right"
      >
        <template #menuitem="{ item: menuItem }">
          <button
            tabindex="-1"
            type="button"
            :class="`menuitem ${menuItem.class} ${menuItem.itemClass}`"
            @click.stop="menuItem.action(item)"
          >
            <div class="flex-h flex-ai_c gap-s1 text-s_s">
              <MazIcon :name="menuItem.icon" size="24px" />
              <span> {{ menuItem.label }} </span>
            </div>
          </button>
        </template>
        <template #element>
          <MazIcon name="more" class="text-c_ts"></MazIcon>
        </template>
      </MazDropdown> -->
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
        <!-- <div v-if="item.screenshots">
          <h4 class="spac-mt_s0 spac-mb_s1 text-a_c">截图/票据</h4>
          <MazGallery
            :images="item.screenshots.split(',')"
            height="120px"
          ></MazGallery>
        </div> -->
        <!-- <MazBtn
          v-if="item.notes"
          right-icon="arrow-right"
          color="theme"
          outline
          @click="handleOpenNoteDrawer(item)"
          block
          size="sm"
        >
          查看攻略
        </MazBtn> -->
      </div>
    </MazCardSpotlight>
  </div>
</template>
<script setup lang="ts">
import TrafficBtn from "@/components/TrafficBtn.vue";
import DianpinBtn from "@/components/DianpinBtn.vue";
import { DateUtil } from "@/helper/util";
import { ISchedule } from "@/server/travel";
import { toRefs } from "vue";

const props = defineProps<{
  item: ISchedule;
}>();

const { item } = toRefs(props);
</script>
