<template>
  <div class="detail-page">
    <Header :back="width > 768 || !mapMode">
      <template #title>
        <h5 class="spac-mv_0 spac-mr_s2 text-o_e">{{ detail?.name }}</h5>
        <div class="text-s_s text-c_ts">{{ currentDate }}</div>
      </template>
      <template #extra>
        <template v-if="width <= 768 && mapMode">
          <MazBtn
            color="transparent"
            outline
            rounded-size="full"
            @click="mapMode = false"
            v-tooltip.bottom="'退出全览地图'"
          >
            <MazIcon name="solar/close" size="30px"></MazIcon>
          </MazBtn>
        </template>
        <template v-else>
          <MazBtn
            fab
            @click="store.toggleTheme"
            color="theme"
            :icon="theme"
            v-tooltip.bottom="'切换主题'"
          ></MazBtn>
          <MazBtn
            pastel
            color="success"
            icon="solar/perm"
            @click="travelPremShow = true"
            v-tooltip.bottom="'分享与权限设置'"
            fab
          />
          <Dropdown
            v-if="perm === 'manage'"
            :items="travelOptionDropMenu"
            position="bottom right"
          >
            <MazBtn
              pastel
              color="success"
              fab
              icon="more"
              v-tooltip.bottom="'设置'"
            ></MazBtn>
          </Dropdown>
        </template>
      </template>
    </Header>
    <div class="detail-row">
      <div class="map-section" v-if="width > 768 || mapMode">
        <div class="search-bar" v-if="perm !== 'view'">
          <MazInput
            block
            v-model="search.keyword"
            autocomplete="off"
            rounded-size="full"
            color="success"
            type="search"
            placeholder="搜索地点 ➡️ 添加行程"
            @keyup.enter="handleSearch()"
          >
            <template #left-icon>
              <select v-model="search.city">
                <option value="全国">全国</option>
                <template v-if="detail?.city">
                  <option v-for="city in detail.city" :key="city" :value="city">
                    {{ city }}
                  </option>
                </template>
              </select>
            </template>
            <template #right-icon>
              <MazIcon
                size="1.5rem"
                name="solar/search"
                @click="handleSearch()"
              />
            </template>
          </MazInput>
          <div v-if="search.keyword" class="search-tip">
            点击标注添加至待规划
          </div>
        </div>
        <AMapContainer v-if="detail && schedules" @loaded="handleMapLoaded" />
      </div>
      <div class="schedule-section" v-if="width > 768 || !mapMode">
        <div class="schedule-section__wrap">
          <div class="schedule-section__content">
            <div class="schedule-list">
              <Sketch :loading="loading" :count="3">
                <template #template>
                  <div class="schedule-item spac-mb_s2">
                    <div class="flex-h flex-ai_c gap-s1 spac-mb_s1">
                      <SketchItem type="circle" size="24px" />
                      <div class="flex-fill">
                        <SketchItem type="hn" size="60%" />
                      </div>
                    </div>
                    <SketchItem type="box" class="spac-p_s2 flex-v radius-md">
                      <div class="flex">
                        <SketchItem type="circle" size="4.4rem" />
                        <div class="spac-ml_s2" style="width: 0; flex: 1">
                          <SketchItem type="text" />
                          <SketchItem type="text" />
                        </div>
                      </div>
                      <SketchItem type="text" />
                      <SketchItem type="text" />
                    </SketchItem>
                  </div>
                </template>
                <ScheduleItem
                  v-for="item in scheduleDay[day]"
                  :key="`schedule_${item.id}`"
                  :item="item"
                  @action="handleScheduleAction($event, item)"
                />
              </Sketch>
              <div
                class="line-a_da1 radius-md spac-mt_s1 spac-p_s3 text-a_c"
                v-if="!loading && scheduleDay[day]?.length == 0"
              >
                <img
                  src="/icons/island.svg"
                  class="spac-mb_s2"
                  style="width: 80px; height: 80px"
                />
                <div class="text-c_ts spac-mv_s2">当天还没添加行程哟</div>
              </div>
              <div class="flex-v gap-s2 spac-mt_s3" v-if="perm !== 'view'">
                <MazBtn
                  v-if="width <= 768"
                  outline
                  color="success"
                  rounded-size="full"
                  left-icon="solar/add"
                  block
                  @click="handleMobileOpenMap"
                >
                  添加行程
                </MazBtn>
                <MazBtn
                  color="warning"
                  left-icon="solar/add-collection"
                  rounded-size="full"
                  outline
                  block
                  @click="collectAddShow = true"
                >
                  添加合集
                </MazBtn>
              </div>
            </div>
            <div class="options-panel">
              <div class="sticky-wrap gap-s2 flex-v">
                <div class="day-list" v-if="scheduleDay">
                  <div
                    v-for="option in dayTabs"
                    class="day-item"
                    :class="{
                      active: day === option.value,
                    }"
                    @click="day = option.value"
                  >
                    <span v-if="option.value === '-1'">{{ option.label }}</span>
                    <template v-else>
                      <div class="text-s_s">Day</div>
                      <div class="text-s_b">{{ option.label }}</div>
                    </template>
                  </div>
                </div>
                <MazBtn
                  v-if="width <= 768"
                  outline
                  color="secondary"
                  @click="handleMobileOpenMap"
                >
                  <div class="flex-v flex-ai_c gap-s1 spac-pv_s1">
                    <MazIcon name="solar/map" size="24px"></MazIcon>
                    地图
                  </div>
                </MazBtn>
                <MazBtn
                  outline
                  color="secondary"
                  @click="handleOpenEquipDrawer()"
                >
                  <div class="flex-v flex-ai_c gap-s1 spac-pv_s1">
                    <MazIcon name="solar/bag" size="24px"></MazIcon>
                    行李
                  </div>
                </MazBtn>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <template v-if="detail">
    <template v-if="perm === 'manage'">
      <!-- 编辑旅程弹窗 -->
      <EditTravelDialog
        v-if="travelEditShow"
        v-model="travelEditShow"
        :detail="detail"
        @saved="getDetail"
      />
      <!-- 管理协作者弹窗 -->
      <EditTravelPremDialog v-model="travelPremShow" :detail="detail" />
    </template>
    <template v-if="perm !== 'view'">
      <!-- 编辑行程弹窗 -->
      <EditScheduleDialog
        v-model="scheduleEditDialog.show"
        :t-id="detail.id"
        :item="scheduleEditDialog.item"
        :limit-date="limitDate"
        @saved="handleSaveSchedule"
      />
      <!-- 添加合集弹窗 -->
      <CollectAddDialog
        v-model="collectAddShow"
        :detail="detail"
        @saved="getSchedule"
      ></CollectAddDialog>
    </template>
    <!-- 行李弹窗 -->
    <EquipDrawer
      v-model="equipDrawer.show"
      :id="detail.id"
      :data="equipDrawer.data"
      :can-edit="perm !== 'view'"
    />
  </template>
</template>
<script lang="ts" setup>
import EditTravelDialog from "./components/EditTravelDialog.vue";
import EditTravelPremDialog from "./components/EditTravelPremDialog.vue";
import EditScheduleDialog from "./components/EditScheduleDialog.vue";
import CollectAddDialog from "./components/CollectAddDialog.vue";
import EquipDrawer from "./components/EquipDrawer.vue";
import ScheduleItem from "./components/ScheduleItem.vue";
import { ISchedule, ITravel, travelApi } from "@/server/travel";
import { computed, onMounted, provide, reactive, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useToast, useWindowSize, throttle, useDialog, debounce } from "maz-ui";
import dayjs from "dayjs";
import { createScheduleMarkerIcon, MapUtil } from "@/helper/amap";
import { DateUtil } from "@/helper/util";
import { useStore } from "@/store";
import { roleType } from "@/helper/enum";
import { storeToRefs } from "pinia";

const loading = ref(true);
const toast = useToast();
const dialog = useDialog();
const route = useRoute();
const router = useRouter();
const store = useStore();
const { userInfo } = store;

const { theme } = storeToRefs(store);
const { width } = useWindowSize();

onMounted(() => {
  getDetail();
  getSchedule();
});

const perm = computed<roleType>(() => {
  if (detail.value) {
    let userRole = detail.value.Users.find((u) => u.id === userInfo?.id);
    if (userRole) {
      return userRole.UserTravel.role;
    }
  }
  return "view";
});

provide("perm", perm);

const travelOptionDropMenu = [
  {
    label: "编辑旅程",
    icon: "solar/edit",
    class: "text-c_t",
    action: () => (travelEditShow.value = true),
  },
  // {
  //   label: "管理协作者",
  //   icon: "solar/perm",
  //   class: "text-c_t",
  //   action: () => (travelPremShow.value = true),
  // },
  {
    label: "删除旅程",
    icon: "solar/close",
    action: handleRemoveTravel,
    class: "text-c_danger",
  },
];

// async function handleShare() {
//   try {
//     await share({ title: detail.value?.name || "", url: window.location.href });
//   } catch {
//     copy(window.location.href).then(() => toast.success("分享链接复制成功"));
//   }
// }

//#region 旅程信息
const id: number = parseInt(route.params.id as string);
const detail = ref<Required<ITravel>>();
const schedules = ref<ISchedule[]>();

// 当前日期显示
const currentDate = computed(() => {
  if (!detail.value) return "";
  const { startDate, endDate } = detail.value;
  if (day.value === "-1") {
    return DateUtil.dateRangeFm(startDate, endDate);
  } else {
    return DateUtil.dateWeekFm(
      dayjs(startDate).add(parseInt(day.value) - 1, "day")
    );
  }
});

const limitDate = computed<[string, string]>(() => {
  if (!detail.value) return ["", ""];
  const { startDate, endDate } = detail.value;
  return [startDate, endDate];
});

async function getDetail() {
  try {
    loading.value = true;
    if (id) {
      let res = await travelApi.detail(id);
      detail.value = res.data;
      detail.value.city = res.data.city?.split(",") || [];
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
    }
    loading.value = false;
  } catch {
    loading.value = false;
    router.push("/travel");
  }
}

async function handleRemoveTravel() {
  if (!detail.value) return;

  dialog.open({
    title: "温馨提示",
    message: `确认删除旅程 "${detail.value.name}" 吗？`,
    buttons: [
      {
        text: "取消",
        type: "reject",
        color: "transparent",
      },
      {
        text: "确认",
        color: "danger",
        action: async () => {
          try {
            await travelApi.remove(detail.value!.id);
            router.replace("/travel");
          } catch (e) {
            console.error(e);
          }
        },
      },
    ],
  });
}

//#endregion

//#region 行程数据展示处理
const day = ref<string>("");
const dayTabs = computed(() =>
  Object.keys(scheduleDay.value).map((key) => ({
    label: key === "-1" ? "待规划" : key,
    value: key,
  }))
);

const scheduleDay = computed(() => {
  if (detail.value) {
    let { startDate, endDate } = detail.value;
    let schedule: Record<string, ISchedule[]> = {};
    let diffDay = dayjs(endDate).diff(startDate, "day") + 1;
    for (let i = 0; i < diffDay; i++) {
      schedule[`${i + 1}`] = [];
    }
    if (schedules.value?.length) {
      schedules.value.forEach((item: ISchedule) => {
        let day: string = "-1";
        if (item.isHotel && item.startTime && item.endTime) {
          // 酒店行程将在住店时间内显示行程
          let duration = dayjs(item.endTime).diff(item.startTime, "day") + 1;
          let diffDay = dayjs(item.startTime).diff(startDate, "day");
          for (let i = 0; i <= duration; i++) {
            diffDay++;
            day = diffDay.toString();
            if (schedule[day]) {
              let startTime = item.startTime;
              if (i > 0) {
                startTime = dayjs(item.startTime)
                  .add(i, "day")
                  .format("YYYY-MM-DD 00:00:00");
              }
              schedule[day].push(Object.assign({}, item, { startTime }));
            }
          }
        } else if (item && item.startTime) {
          let diffDay = dayjs(item.startTime).diff(startDate, "day") + 1;
          day = diffDay.toString();
          if (schedule[day]) {
            schedule[day].push(Object.assign({}, item));
          } else {
            if (!schedule["-1"]) {
              schedule["-1"] = [];
            }
            schedule["-1"].push(Object.assign({}, item));
          }
        }
        if (day === "-1") {
          if (!schedule[day]) {
            schedule[day] = [];
          }
          schedule[day].push(Object.assign({}, item));
        }
      });
    }
    // 对行程按时间排序
    Object.keys(schedule).forEach((key) => {
      if (key !== "-1") {
        schedule[key].sort(
          (a, b) =>
            new Date(a.startTime || "").getTime() -
            new Date(b.startTime || "").getTime()
        );
      }
    });
    if (day.value === "") {
      let currentDay = dayjs().diff(dayjs(startDate), "day") + 1;
      day.value = `${
        schedule[currentDay] ? currentDay : schedule["-1"]?.length ? -1 : 1
      }`;
    }
    return schedule;
  }
  return {};
});
//#endregion

//#region 旅程编辑弹窗与管理协作者弹窗
const travelEditShow = ref<boolean>(false);
const travelPremShow = ref<boolean>(false);
const collectAddShow = ref<boolean>(false);
//#endregion

//#region 行程编辑

function handleScheduleAction(
  actionType: "edit" | "clone" | "remove",
  item: ISchedule
) {
  if (actionType === "edit") {
    handleEditSchedule(item);
  } else if (actionType === "clone") {
    handleCloneSchedule(item);
  } else if (actionType === "remove") {
    handleRemoveSchedule(item);
  }
}

const scheduleEditDialog = reactive<{
  show: boolean;
  item?: ISchedule;
}>({
  show: false,
});

function handleEditSchedule(item?: ISchedule) {
  if (perm.value === "view") return;
  if (item) {
    let data = schedules.value?.find((i) => i.id === item.id);
    scheduleEditDialog.item = Object.assign({}, data);
  } else {
    scheduleEditDialog.item = undefined;
  }
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
    renderScheduleMarkder(false);
  }
}

async function handleCloneSchedule(item: ISchedule) {
  try {
    if (!item?.id) return;
    const res = await travelApi.cloneSchedule(item.id);
    schedules.value?.push(res.data);
    renderScheduleMarkder();
  } catch (e) {
    console.error(e);
  }
}

async function handleRemoveSchedule(item: ISchedule) {
  if (!item?.id) return;
  dialog.open({
    title: "温馨提示",
    message: `确认删除${item.name}行程吗？`,
    buttons: [
      {
        text: "取消",
        type: "reject",
        color: "transparent",
      },
      {
        text: "确认",
        color: "danger",
        action: async () => {
          try {
            await travelApi.removeSchedule(item.id!);
            let index = schedules.value?.findIndex((i) => i.id === item.id);
            if (index !== undefined && index > -1) {
              schedules.value?.splice(index, 1);
              renderScheduleMarkder();
            }
          } catch (e) {
            console.error(e);
          }
        },
      },
    ],
  });
}

// #endregion

// #region 行李清单
const equipDrawer = reactive<{
  show: boolean;
  data: string;
}>({
  show: false,
  data: "",
});
async function handleOpenEquipDrawer() {
  equipDrawer.show = true;
  equipDrawer.data = detail.value?.equip || "";
}

// #endregion

//#region 地图渲染
let mapInstance: AMap.Map | null = null;
let markers: AMap.Marker[] = [];
const mapMode = ref(false);

function handleMapLoaded(map: AMap.Map) {
  mapInstance = map;
  renderScheduleMarkder();
}
watch(
  () => day.value,
  async () => {
    if (width.value > 768) {
      renderScheduleMarkder();
    }
  }
);

const dayColor = [
  "#1f8fff",
  "#5425c6",
  "#c625c2",
  "#c6255a",
  "#348e0e",
  "#1599a6",
];

function createScheduleMarker(item: ISchedule, idx: number, day?: string) {
  if (!mapInstance || search.keyword) return false;
  let position: AMap.LngLat = MapUtil.LngLat(item.coordinate || "");
  // const dayLabel = day !== "-1" ? `D${day}` : "NA";
  let icon = createScheduleMarkerIcon("H", "#544380");
  if (!item.isHotel) {
    if (!item.startTime) {
      icon = createScheduleMarkerIcon("?", "#c38a1b");
    } else {
      icon = createScheduleMarkerIcon(
        `${idx}`,
        day ? dayColor[parseInt(day)] : "#1f8fff"
      );
    }
  }
  const styles = [
    {
      icon: {
        img: icon,
        size: [20, 20],
        anchor: "bottom-center",
        scaleFactor: 0.5,
        minScale: 2,
        maxScale: 4,
      },
    },
    {
      icon: {
        img: icon,
        size: [20, 20],
        anchor: "bottom-center",
        scaleFactor: 0.5,
        minScale: 2,
        maxScale: 4,
      },
      label: {
        position: "BM",
        content: item.name,
      },
    },
  ];
  if (day) {
    styles[0].label = {
      position: "BM",
      content: day === "-1" ? "待规划" : `Day ${day}`,
    };
    styles[1].label = {
      position: "BM",
      content: `${day === "-1" ? "" : `Day ${day}：`}${item.name}`,
    };
  }
  let zoomStyleMapping: Record<number, number> = {};
  for (let i = 2; i < 26; i++) {
    zoomStyleMapping[i] = i > 13 ? 1 : 0;
  }
  let instance = new AMap.ElasticMarker({
    position,
    zooms: [2, 26],
    styles,
    zoomStyleMapping,
  });
  instance.on("click", () => {
    handleEditSchedule(item);
  });
  return instance;
}

async function renderScheduleMarkder(fitView: boolean = true) {
  if (!mapInstance || search.keyword) return false;
  mapInstance.clearMap?.();
  let markers: AMap.ElasticMarker[] = [];
  if (mapMode.value) {
    Object.keys(scheduleDay.value).forEach((key) => {
      let idx = 1;
      scheduleDay.value[key]?.forEach((item: ISchedule) => {
        idx = item.isHotel ? 0 : idx + 1;
        const instance = createScheduleMarker(item, idx, key);
        if (instance) {
          markers.push(instance);
        }
      });
    });
  } else {
    let idx = 1;
    scheduleDay.value[day.value]?.forEach((item: ISchedule) => {
      idx = item.isHotel ? 0 : idx + 1;
      const instance = createScheduleMarker(item, idx);
      if (instance) {
        markers.push(instance);
      }
    });
  }
  mapInstance.add(markers);
  if (markers.length && fitView) {
    mapInstance?.setFitView(
      markers,
      true,
      [150, 60, 60, 160] // 周围边距，上、下、左、右
    );
  }
  // }
}

//#endregion

//#region 搜索
const search = reactive({
  keyword: "",
  city: "全国",
});

function handleMobileOpenMap() {
  if (width.value <= 768) {
    mapMode.value = true;
    search.keyword = "";
  }
}

const handleSearch = throttle(async () => {
  if (!mapInstance) return;
  if (search.keyword === "") {
    renderScheduleMarkder();
    return;
  }
  mapInstance.clearMap?.();
  let markers: AMap.Marker[] = [];
  const res = await MapUtil.searchPleace(search.keyword, {
    city: search.city,
    extensions: "all",
  });
  if (res) {
    res.poiList?.pois?.forEach((item) =>
      createPOIMarker(item as AMap.PlaceSearch.PoiExt)
    );
    if (markers.length) {
      mapInstance.add(markers);
    }
  }
}, 500);

function createPOIMarker(poi: AMap.PlaceSearch.PoiExt) {
  if (!mapInstance || !poi.location) return;
  const marker = new AMap.Marker({
    icon: createScheduleMarkerIcon("+", "#c38a1b"),
    position: poi.location,
    anchor: "bottom-left",
    label: {
      offset: new AMap.Pixel(5, 0),
      content: `${poi.name}`,
    },
  });
  marker.on(
    "click",
    debounce(() => {
      handleAddSchedule(poi);
    }, 1000)
  );
  markers.push(marker);
  mapInstance?.add(marker);

  mapInstance.setFitView(
    markers,
    true,
    [150, 60, 60, 150] // 周围边距，上、下、左、右
  );
}

async function handleAddSchedule(poi: AMap.PlaceSearch.PoiExt) {
  try {
    const isHotel = poi.type.indexOf("住宿服务") > -1;
    const data: ISchedule = {
      tId: id,
      name: poi.name,
      coordinate: poi.location?.toString() || "",
      address: `${poi.pname || ""} ${poi.cityname || ""} ${poi.adname || ""} ${
        poi.address || ""
      }`,
      cover: poi.photos?.[0]?.url || "",
      isHotel,
      notes: `====高德店铺信息====\n联系电话：${poi.tel || "无"}`,
    };
    if (isHotel) {
      data.startTime = dayjs(limitDate.value[0]).format("YYYY-MM-DD 12:00:00");
      data.endTime = dayjs(limitDate.value[1]).format("YYYY-MM-DD 12:00:00");
    }
    const res = await travelApi.addSchedule(data);
    day.value = "-1";
    toast.success("添加行程成功", { position: "top" });
    schedules.value?.push(res.data);
  } catch (e) {
    console.error(e);
  }
}
//#endregion
</script>
<style lang="stylus">
.detail-page{
  width: 90vw;
  max-width: 1440px;
  // max-height: calc(1440px/(16/9));
  l-mh: auto;
  padding-bottom: 50px;

  .detail-row{
    l-wh: 100% calc(90vw/(16/9));
    l-flex: h;
    gap: 24px;
  }
  .schedule-section{
    transform: translateZ(0)
    l-wh: 430px 100% var(--maz-border-radius);
    position: relative;
    background: var(--maz-color-bg);
    display: flex;
    flex-direction: column;
    overflow: hidden;
    &:before,&:after{
      content: " ";
      display: block;
      l-wh: 100% 60px;
      position absolute;
      z-index: 5;
      pointer-events: none;
    }
    &:before{
      top: 0;
      background-image: linear-gradient(to top, rgba(255,255,255,0) 0%, var(--maz-color-bg) 100%);
    }
    &:after{
      bottom: 0;
      background-image: linear-gradient(to bottom, rgba(255,255,255,0) 0%, var(--maz-color-bg) 100%);
    }
    &__wrap{
      flex-grow: 1;
      padding: 50px 15px;
      overflow: hidden scroll;
    }
    &__content{
      display: flex;
      gap: 10px;
      flex-direction: row;
    }
    .schedule-list{
      flex-grow: 1;
      width: 0;
    }
    .options-panel{
      // position: relative;
      width: 100px;
      flex-shrink: 0;
    }
    .sticky-wrap{
      position: sticky;
      top: 0;
      z-index: 1;
    }
    .day-list{
      width: 100px;
      padding: 10px;
      max-height: 50vh;
      background: var(--maz-color-bg-lighter);
      border-radius: var(--maz-border-radius);
      overflow: hidden auto;
      display: flex;
      flex-direction: column;
      gap: 5px;
      .day-item{
        padding: 0.5rem 0.2rem;
        text-align: center;
        color: var(--maz-color-text);
        border-radius: var(--maz-border-radius);
        border: 2px dashed transparent;
        cursor: pointer;
        &:hover{
          background: var(--maz-color-success-alpha-20);
        }
        &.active{
          background: var(--maz-color-success);
          color: var(--maz-color-white);
        }
        &.drop-area{
          background: transparent;
          color: var(--maz-color-muted);
          border: 2px dashed rgb(229,231,235);
          &.hover{
            background: var(--maz-color-success-alpha-20);
          }
        }
      }
    }
  }


  .map-section{
    transform: translateZ(0)
    position relative
    l-wh: 0 100% var(--maz-border-radius);
    background: var(--maz-color-bg);
    flex: 1;
    overflow: hidden;

    .search-bar {
      position: absolute;
      top: 20px;
      left: 50%;
      width: 50%;
      min-width: 250px;
      transform: translateX(-50%);
      z-index: 2;
      l-flex: v c c;
      gap: 8px;
      .m-input{
        select{
          appearance: none;
          background: transparent;
          padding-left: 10px;
          padding-right: 15px;
          height: 24px;
          line-height: 24px;
          cursor: pointer;
          outline: none;
          position: relative;
        }
        .m-input-wrapper-left:after{
          content: url("/icons/solar/arrow.svg");
          display: block;
          l-wh: 15px 15px 15px;
          position: absolute;
          right: 0;
          pointer-events: none;
        }

      }
    }
    .search-tip{
      color: white;
      font-size: 14px;
      height: 30px;
      line-height: 30px;
      display: inline-flex;
      text-align: center;
      margin-top: 5px;
      border-radius: var(--maz-border-radius);
      background: rgba(0,0,0,.8);
      padding: 0 20px;
    }
  }
}

@media screen and (max-width: 768px) {
  .detail-page{
    width: 100%;
    flex: 1;
    display: flex;
    flex-direction: column;
    padding-bottom: 0;
    height: 100%;
    .detail-row{
      l-wh: auto 0;
      flex-direction: column;
      flex: 1;
    }

    .map-section{
      width: auto;
      border-bottom-left-radius: 0;
      border-bottom-right-radius: 0;
      // position: fixed;

      .search-bar{
        width: 90%;
      }
    }

    .schedule-section{
      padding:30px 0 0;
      l-wh: auto 100%;
      border-bottom-left-radius: 0;
      border-bottom-right-radius: 0;
      box-shadow: none;
      flex: 1;

      &:before,&:after{
        content: none;
      }
      &__wrap{
        padding:0 15px 50px;
      }
    }
  }
}
</style>
