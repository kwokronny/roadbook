<template>
  <div class="batch-page">
    <Header back>
      <template #title>
        <div>
          <h5 class="spac-mv_s0">行程安排</h5>
        </div>
      </template>
    </Header>
    <div class="map-section">
      <div class="tip text-o_e">可双击行程编辑</div>
      <AMapComponent
        class="flex-fill"
        @loaded="handleMapLoaded"
      ></AMapComponent>
    </div>
  </div>
  <template v-if="detail">
    <EditScheduleDialog
      v-model="scheduleEditDialog.show"
      :t-id="detail.id"
      :item="scheduleEditDialog.item"
      :limit-date="limitDate"
      @saved="handleSaveSchedule"
    ></EditScheduleDialog>
  </template>
</template>
<script setup lang="ts">
import AMapComponent from "@/components/AMapContainer.vue";
import EditScheduleDialog from "./components/EditScheduleDialog.vue";
import { MapUtil } from "@/helper/amap";
import { ISchedule, ITravel, travelApi } from "@/server/travel";
import dayjs from "dayjs";
import { sleep, useToast } from "maz-ui";
import { computed, onMounted, reactive, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { DateUtil } from "@/helper/util";

const route = useRoute();
const router = useRouter();
const toast = useToast();

const limitDate = computed<[string, string]>(() => {
  if (!detail.value) return ["", ""];
  const { startDate, endDate } = detail.value;
  return [
    dayjs(startDate).format("YYYY-MM-DD 00:00:00"),
    dayjs(endDate).format("YYYY-MM-DD 23:59:59"),
  ];
});

const id: number = parseInt(route.params.id as string);
const loading = ref(false);
const detail = ref<Required<ITravel>>();
const schedules = ref<ISchedule[]>();

async function getDetail() {
  try {
    loading.value = true;
    if (id) {
      let res = await travelApi.detail(id);
      detail.value = res.data;
    }
    loading.value = false;
  } catch {
    loading.value = false;
    router.push("/travel");
  }
}
async function getSchedule() {
  try {
    loading.value = true;
    if (id) {
      let scheduleRes = await travelApi.schedule(id);
      schedules.value = scheduleRes.data;
      sleep(1000).then(renderMap);
    }
    loading.value = false;
  } catch {
    loading.value = false;
    router.push("/travel");
  }
}

onMounted(() => {
  getDetail();
  getSchedule();
});

let mapInstance: AMap.Map | null = null;
function handleMapLoaded(map: AMap.Map) {
  mapInstance = map;
  sleep(1000).then(renderMap);
}
async function renderMap() {
  if (!mapInstance) return false;
  mapInstance.clearMap?.();
  let markers: AMap.Marker[] = [];
  const startDate = detail.value?.startDate;
  schedules.value?.forEach((item: ISchedule) => {
    if (item) {
      let position: AMap.LngLat = MapUtil.LngLat(item.coordinate);
      let markText = "未安排";
      if (item.isHotel) {
        let inday = dayjs(item.startTime).diff(startDate, "day") + 1;
        let outday = dayjs(item.endTime).diff(startDate, "day") + 1;
        markText = `🏨 第${inday}~${outday}天`;
      } else if (item.startTime) {
        let day = dayjs(item.startTime).diff(startDate, "day") + 1;
        markText = `🏞️ 第${day}天 ${DateUtil.timeFm(item.startTime)}`;
      }
      markText = `<div class="text-c_ts">${markText}</div>${item.name}`;
      let instance = new AMap.Marker({
        icon: "/icons/marker.svg",
        position,
        anchor: "center",
        label: {
          offset: new AMap.Pixel(5, 0),
          content: markText,
        },
      });
      instance.on("dblclick", () => {
        handleEditSchedule(item);
      });
      markers.push(instance);
    }
  });
  mapInstance.add(markers);
  if (markers.length) {
    let fitView = mapInstance.setFitView(
      markers,
      true,
      [120, 120, 120, 120],
      10
    );
    if (fitView) {
      mapInstance.setCenter(fitView.getCenter());
    }
  }
  // }
}

const scheduleEditDialog = reactive<{
  show: boolean;
  item?: ISchedule;
}>({
  show: false,
});
function handleEditSchedule(item?: ISchedule) {
  scheduleEditDialog.item = Object.assign({}, item);
  scheduleEditDialog.show = true;
}

async function handleSaveSchedule(data: ISchedule) {
  scheduleEditDialog.show = false;
  if (schedules.value && data) {
    let schedule = schedules.value.find((i) => i.id === data.id);
    if (schedule) {
      schedule = Object.assign(schedule, data);
      toast.success("保存行程成功", { position: "top" });
    } else {
      schedules.value.push(data);
      toast.success("添加行程成功", { position: "top" });
    }
    await sleep(1000);
    renderMap();
  }
}
</script>

<style lang="stylus">
.batch-page{
  width: 100%;
  display: flex;
  flex-direction: column;
  padding-bottom: 0;
  flex: 1;

  .map-section{
    l-wh: 100% 100%;
    flex: 1;
    display: flex;
    flex-direction: column;
    position relative
    overflow: hidden;
    border-top-left-radius: var(--maz-border-radius-lg);
    border-top-right-radius: var(--maz-border-radius-lg);
    background: var(--maz-color-bg);
    box-shadow: yoz_shadow.ph;
    .tip{
      l-abs 50% 20px 'lt';
      transform: translateX(-50%)
      background: var(--maz-color-bg-lighter)
      l-wh auto 40px;
      l-ph: 40px;
      t-fl: 14px 40px;
      border-radius: var(--maz-border-radius)
      z-index 1;
      text-align: center;
      overflow: hidden;
      color: var(--maz-color-muted)
    }
  }
}
</style>
