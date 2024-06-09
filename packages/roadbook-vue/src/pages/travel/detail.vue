<template>
  <div class="detail-page">
    <Header back>
      <template #title>
        <div>
          <h5 class="spac-mv_s0 spac-mr_s2 text-clamp_1">{{ detail?.name }}</h5>
          <div class="text-s_s text-c_ts">{{ currentDate }}</div>
        </div>
      </template>
      <template #extra>
        <MazBtn
          color="secondary"
          pastel
          fab
          icon="solar/share"
          @click="handleShare"
        ></MazBtn>
        <MazDropdown
          v-if="perm === 'manage'"
          :items="travelOptionDropMenu"
          position="bottom right"
        >
          <template #menuitem-label="{ item }">
            <div class="flex-h flex-ai_c gap-s1">
              <MazIcon :name="item.icon" size="24px" />
              <span>
                {{ item.label }}
              </span>
            </div>
          </template>
          <template #element>
            <MazBtn color="info" fab icon="solar/setting"></MazBtn>
          </template>
        </MazDropdown>
      </template>
    </Header>
    <div class="detail-row">
      <div class="map-section" v-if="width > 768">
        <div class="tip text-o_e">可双击行程编辑</div>
        <AMapComponent @loaded="handleMapLoaded"></AMapComponent>
      </div>
      <div class="schedule-section">
        <div class="schedule-section__wrap">
          <div class="schedule-list">
            <Sketch :loading="loading" :count="3">
              <template #template>
                <div class="schedule-item">
                  <SketchItem type="hn"></SketchItem>
                  <SketchItem type="box" class="spac-p_s2 flex-v radius-b">
                    <div class="flex-h">
                      <SketchItem type="circle" size="4.4rem"></SketchItem>
                      <div class="spac-ml_s2" style="width: 0; flex: 1">
                        <SketchItem type="text"></SketchItem>
                        <SketchItem type="text"></SketchItem>
                      </div>
                    </div>
                    <SketchItem type="text"></SketchItem>
                  </SketchItem>
                </div>
              </template>
              <MazTransitionExpand>
                <template
                  v-for="item in scheduleDay[day]"
                  :key="`schedule_${item.id}`"
                >
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
                            {{
                              item.startTime
                                ? DateUtil.timeFm(item.startTime)
                                : "未安排"
                            }}
                          </span>
                        </template>
                      </div>

                      <MazDropdown
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
                      </MazDropdown>
                    </h2>
                    <MazCardSpotlight
                      :color="item.isHotel ? 'warning' : 'info'"
                      style="width: 100%; display: block"
                    >
                      <div class="spac-p_s2 flex-v" style="gap: 16px">
                        <div class="flex-h">
                          <MazAvatar
                            rounded-size="lg"
                            :caption="item.name"
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
                        <div v-if="item.screenshots">
                          <h4 class="spac-mt_s0 spac-mb_s1 text-a_c">
                            截图/票据
                          </h4>
                          <MazGallery
                            :images="item.screenshots.split(',')"
                            height="120px"
                          ></MazGallery>
                        </div>
                        <MazBtn
                          v-if="item.notes"
                          right-icon="arrow-right"
                          color="theme"
                          outline
                          @click="handleOpenNoteDrawer(item)"
                          block
                          size="sm"
                        >
                          查看攻略
                        </MazBtn>
                      </div>
                    </MazCardSpotlight>
                  </div>
                </template>
              </MazTransitionExpand>
            </Sketch>
            <div
              class="line-a_da1 radius-b spac-mt_s1"
              v-if="!loading && scheduleDay[day]?.length == 0"
            >
              <div class="spac-p_s3 text-a_c">
                <MazIcon name="island" size="80px"></MazIcon>
                <div class="text-c_ts spac-mv_s2">当天还没添加行程哟</div>
              </div>
            </div>
            <div class="flex-v gap-s2 spac-mt_s3" v-if="perm !== 'view'">
              <MazBtn
                outline
                color="info"
                left-icon="solar/add"
                block
                @click="handleEditSchedule()"
              >
                添加行程
              </MazBtn>
              <MazBtn
                outline
                color="success"
                left-icon="solar/add-collection"
                block
                @click="handleOpenBatchDrawer"
              >
                添加合集
              </MazBtn>
            </div>
          </div>
          <div class="options-panel gap-s2 flex-v">
            <div class="day-list" v-if="scheduleDay">
              <MazRadioButtons
                v-model="day"
                color="primary"
                :options="dayTabs"
                orientation="col"
              >
                <template #default="{ option, selected }">
                  <div class="text-a_c" :class="{ 'text-c_t': !selected }">
                    {{ option.label }}
                  </div>
                </template>
              </MazRadioButtons>
            </div>
            <MazBtn
              v-if="width <= 768"
              outline
              color="secondary"
              :to="`/travel/${id}/batch`"
            >
              <div class="flex-v flex-ai_c gap-s1">
                <MazIcon name="solar/map" size="24px"></MazIcon>
                地图
              </div>
            </MazBtn>
            <MazBtn outline color="info" @click="handleOpenEquipDrawer()">
              <div class="flex-v flex-ai_c gap-s1">
                <MazIcon name="solar/luggage" size="24px"></MazIcon>
                行李
              </div>
            </MazBtn>
          </div>
        </div>
      </div>
    </div>
  </div>
  <!-- #region 攻略弹窗 -->
  <MazDialog v-model="noteDialog.show" max-height="50vh" scrollable>
    <template #title>
      <div class="spac-pv_s2 flex-h flex-ai_c">
        <MazIcon
          name="red-book"
          size="24px"
          class="spac-mr_s1 flex-shrink"
        ></MazIcon>
        <span class="flex-fill text-clamp_1">{{ noteDialog.title }}</span>
      </div>
    </template>
    <div
      class="text-s_m note-content"
      style="word-wrap: break-word"
      v-html="noteDialog.content"
    ></div>
    <template #footer>
      <div class="spac-pb_s3"></div>
    </template>
  </MazDialog>
  <!-- #endregion -->
  <!-- #region 拉取合集弹窗 -->
  <MazDialog v-model="pullCollectDialog.show" max-height="50vh" scrollable>
    <template #title>
      <div class="spac-pt_s2 flex-h flex-ai_c">
        <MazIcon name="island" size="24px" class="spac-mr_s1"></MazIcon>
        添加点评合集
      </div>
    </template>
    <MazTextarea
      v-model="pullCollectDialog.url"
      placeholder="请输入大众点评合集链接"
    ></MazTextarea>
    <div class="spac-mt_s2">
      <MazCheckbox v-model="pullCollectDialog.skip" color="info">
        跳过已添加的行程
      </MazCheckbox>
    </div>
    <template #footer>
      <MazBtn
        block
        class="spac-mb_s2"
        :loading="pullCollectDialog.loading"
        @click="handleBatch"
      >
        添加点评合集
      </MazBtn>
    </template>
  </MazDialog>
  <!-- #endregion -->
  <!-- 确认弹窗 -->
  <MazDialogPromise
    :data="confirmData"
    :buttons="confirmData.buttons"
    identifier="confirm"
  />
  <template v-if="detail">
    <!-- 编辑旅程弹窗 -->
    <EditTravelDialog
      v-if="perm === 'manage'"
      v-model="travelEditShow"
      :item="detail"
      @saved="getDetail"
    ></EditTravelDialog>
    <!-- 管理协作者弹窗 -->
    <EditTravelPremDialog
      v-if="perm === 'manage'"
      v-model="travelPremShow"
      :row="detail"
    ></EditTravelPremDialog>
    <!-- 编辑行程弹窗 -->
    <EditScheduleDialog
      v-if="perm !== 'view'"
      v-model="scheduleEditDialog.show"
      :t-id="detail.id"
      :item="scheduleEditDialog.item"
      :limit-date="limitDate"
      @saved="handleSaveSchedule"
    ></EditScheduleDialog>
    <!-- 行李弹窗 -->
    <EquipDrawer
      v-model="equipDrawer.show"
      :id="detail.id"
      :data="equipDrawer.data"
      :can-edit="perm !== 'view'"
      @close="getDetail"
    ></EquipDrawer>
  </template>
</template>
<script lang="ts" setup>
import {
  useMazDialogPromise,
  DialogButton,
  type DialogData,
} from "maz-ui/components/MazDialogPromise";
import AMapComponent from "@/components/AMapContainer.vue";
import TrafficBtn from "@/components/TrafficBtn.vue";
import DianpinBtn from "@/components/DianpinBtn.vue";
import EditTravelDialog from "./components/EditTravelDialog.vue";
import EditTravelPremDialog from "./components/EditTravelPremDialog.vue";
import EditScheduleDialog from "./components/EditScheduleDialog.vue";
import EquipDrawer from "./components/EquipDrawer.vue";
import { ISchedule, ITravel, travelApi } from "@/server/travel";
import { computed, onMounted, onUnmounted, reactive, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import dayjs from "dayjs";
import { MapUtil } from "@/helper/amap";
import { DateUtil, copy, share } from "@/helper/util";
import { useToast, useWindowSize, sleep } from "maz-ui";
import { useStore } from "@/store";
import { roleType } from "@/helper/enum";

const loading = ref(true);
const toast = useToast();
const route = useRoute();
const router = useRouter();
const { width } = useWindowSize();
const { userInfo } = useStore();

onMounted(() => {
  window.addEventListener("scroll", handleScroll);
  getDetail();
  getSchedule();
});

onUnmounted(() => {
  window.removeEventListener("scroll", handleScroll);
});

function handleScroll() {
  if (width.value <= 768) {
    // 移动端屏幕固定右边栏
    const option = document.querySelector(".options-panel");
    const scrollTop = document.documentElement.scrollTop;
    if (option) {
      if (scrollTop >= option.getBoundingClientRect().y) {
        option.classList.add("fixed");
      } else {
        option.classList.remove("fixed");
      }
    }
  }
}

const perm = computed<roleType>(() => {
  if (detail.value) {
    let userRole = detail.value.Users.find((u) => u.id === userInfo?.id);
    if (userRole) {
      return userRole.UserTravel.role;
    }
  }
  return "view";
});

const travelOptionDropMenu = [
  {
    label: "编辑旅程",
    icon: "solar/edit",
    class: "text-c_t",
    action: () => (travelEditShow.value = true),
  },
  {
    label: "管理协作者",
    icon: "solar/perm",
    class: "text-c_t",
    action: () => (travelPremShow.value = true),
  },
  {
    label: "删除旅程",
    icon: "solar/close",
    action: handleRemoveTravel,
    class: "text-c_danger",
  },
];

async function handleShare() {
  try {
    await share({ title: detail.value?.name || "", url: window.location.href });
  } catch {
    copy(window.location.href).then(() => toast.success("分享链接复制成功"));
  }
}

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

//#endregion

//#region 行程数据展示处理
const day = ref<string>("");
const dayTabs = computed(() =>
  Object.keys(scheduleDay.value).map((value) => ({
    label: value == "-1" ? "待安排" : `第${value}天`,
    value,
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
      let currentDay = dayjs(startDate).diff(dayjs(), "day") + 1;
      day.value = `${
        schedule[currentDay] ? currentDay : schedule["-1"]?.length ? -1 : 1
      }`;
    }
    return schedule;
  }
  return {};
});
//#endregion

//#region 行程编辑
const scheduleOptionDropMenu = [
  {
    label: "编辑",
    itemClass: "text-c_ts",
    icon: "solar/edit",
    action: (item: ISchedule) => handleEditSchedule(item),
  },
  {
    label: "克隆",
    icon: "solar/copy",
    itemClass: "text-c_ts",
    action: (item: ISchedule) => handleCloneSchedule(item),
  },
  {
    label: "移除",
    icon: "solar/close",
    itemClass: "text-c_danger",
    action: (item: ISchedule) => handleRemoveSchedule(item),
  },
];

async function handleCloneSchedule(item: ISchedule) {
  try {
    if (!item?.id) return;
    const res = await travelApi.cloneSchedule(item.id);
    schedules.value?.push(res.data);
    await sleep(1000);
    renderMap();
  } catch (e) {
    console.error(e);
  }
}

const { showDialogAndWaitChoice } = useMazDialogPromise();
async function handleRemoveSchedule(item: ISchedule) {
  try {
    if (!item?.id) return;
    confirmData.message = `确认删除${item.name}行程吗？`;
    await showDialogAndWaitChoice("confirm");
    await travelApi.removeSchedule(item.id);
    let index = schedules.value?.findIndex((i) => i.id === item.id);
    if (index !== undefined && index > -1) {
      schedules.value?.splice(index, 1);
      await sleep(1000);
      renderMap();
    }
  } catch (e) {
    console.error(e);
  }
}

//#endregion

//#region 攻略弹窗
const noteDialog = ref<{ show: boolean; title: string; content: string }>({
  show: false,
  title: "",
  content: "",
});

const handleOpenNoteDrawer = function (schedule: ISchedule) {
  let data = {
    show: true,
    title: `行程攻略：${schedule?.name}`,
    content:
      schedule?.notes?.replace?.(
        /(((http|https):\/\/)[^\s]+)/g,
        '<a href="$1" target="_blank" ref="noreferrer noopener">$1</a>'
      ) || "",
  };
  noteDialog.value = data;
};
//#endregion

//#region 旅程编辑弹窗与管理协作者弹窗
const travelEditShow = ref<boolean>(false);
const travelPremShow = ref<boolean>(false);
//#endregion

//#region 行程编辑
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
    await sleep(1000);
    renderMap();
  }
}

// #endregion

//#region 拉取弹窗

interface IPullCollectDialog {
  loading: boolean;
  show: boolean;
  url: string;
  skip: boolean;
}
const pullCollectDialog = reactive<IPullCollectDialog>({
  show: false,
  url: "",
  loading: false,
  skip: false,
});

function handleOpenBatchDrawer() {
  pullCollectDialog.show = true;
  pullCollectDialog.url = "";
  pullCollectDialog.skip = false;
}

async function handleBatch() {
  try {
    pullCollectDialog.loading = true;
    const res = await travelApi.pullCollect({
      tId: id,
      url: pullCollectDialog.url,
      isSkip: pullCollectDialog.skip,
    });
    pullCollectDialog.loading = false;
    getSchedule();
    pullCollectDialog.show = false;
    toast.success(
      `拉取 ${res.data.all} 个行程，成功添加了 ${res.data.success} 个行程`,
      { position: "top" }
    );
  } catch {
    pullCollectDialog.loading = false;
  }
}
//#endregion

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

//#region confirmData
const confirmData = reactive<DialogData & { buttons: DialogButton[] }>({
  title: "温馨提示",
  message: "",
  cancelText: "取消",
  confirmText: "确定",
  buttons: [
    {
      text: "取消",
      type: "reject",
      color: "transparent",
      response: "cancel",
    },
    {
      text: "删除!",
      type: "resolve",
      color: "danger",
      response: "delete",
    },
  ],
});

async function handleRemoveTravel() {
  if (detail.value) {
    try {
      confirmData.message = `确认删除旅程 "${detail.value.name}" 吗？`;
      await showDialogAndWaitChoice("confirm");
      await travelApi.remove(detail.value.id);
      router.replace("/travel");
    } catch (e) {
      console.error(e);
    }
  }
}

//#endregion

//#region 地图渲染
let mapInstance: AMap.Map | null = null;

function handleMapLoaded(map: AMap.Map) {
  mapInstance = map;
  sleep(1000).then(renderMap);
}

watch(
  () => day.value,
  async () => {
    await sleep(1000);
    renderMap();
  }
);

async function renderMap() {
  if (!mapInstance) return false;
  mapInstance.clearMap?.();
  let markers: AMap.Marker[] = [];
  scheduleDay.value[day.value]?.forEach((item: ISchedule, index: number) => {
    let position: AMap.LngLat = MapUtil.LngLat(item.coordinate);
    let instance = new AMap.Marker({
      icon: "/icons/marker.svg",
      position,
      anchor: "bottom-left",
      label: {
        offset: new AMap.Pixel(5, 0),
        content: `${
          day.value !== "-1" && !item.isHotel
            ? `${DateUtil.timeFm(item.startTime)}</br>`
            : ""
        }${item.name}`,
      },
    });
    instance.on("dblclick", () => {
      handleEditSchedule(item);
    });
    markers.push(instance);
    if (day.value !== "-1") {
      if (index > 0) {
        let startLngLat = markers[index - 1].getPosition();
        if (mapInstance && item.traffic && startLngLat && position) {
          MapUtil.planningRoute(
            mapInstance,
            item.traffic,
            startLngLat,
            position
          );
        }
      }
    }
  });
  mapInstance.add(markers);
  if (markers.length) {
    mapInstance.setFitView(markers);
  }
  // }
}

//#endregion
</script>
<style lang="stylus">
.note-content{
  a{
    text-decoration: underline;
  }
}
.detail-page{
  width: 90vw;
  l-mh: auto;
  padding-bottom: 50px;

  .detail-row{
    l-wh: 100% calc(90vw/(16/9));
    l-flex: h;
    gap: 24px;
  }
  .schedule-section{
    transform: translateZ(0)
    l-wh: 430px 100% var(--maz-border-radius-lg);
    overflow: hidden;
    position: relative;
    background: var(--maz-color-bg);
    box-shadow: yoz_shadow.ph;
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
      l-wh: 100% 100%;
      padding: 50px 15px;
      overflow: hidden auto;
    }
    .schedule-list{
      margin-right: 110px;
      .schedule-item{
        width: 100%;
        margin-bottom: 24px;
        .m-avatar .m-avatar__wrapper{
          width: 65px;
          height: 65px;
          background-image: linear-gradient(120deg, #e0c3fc 0%, #8ec5fc 100%);
        }
        &__header{
          l-flex: h sb c;
          margin: yoz_spacing.s1
          // svg{
          //   cursor pointer
          // }
        }
      }
    }
    .options-panel{
      l-abs: 10px 49px 'rt';
    }
    .day-list{
      width: 100px;
      padding: 10px;
      max-height: 50vh;
      background: var(--maz-color-bg-lighter);
      border-radius: var(--maz-border-radius);
      overflow: hidden auto;
      .m-radio-buttons__items{
        box-shadow: none;
        padding: 0.5rem 0.2rem;
      }
    }
  }


  .map-section{
    transform: translateZ(0)
    position relative
    l-wh: 0 100% var(--maz-border-radius-lg);
    background: var(--maz-color-bg);
    flex: 1;
    overflow: hidden;
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

// @media screen and (max-width: 768px) {
// }
@media screen and (max-width: 768px) {
  .detail-page{
    width: 100%;
    flex: 1;
    display: flex;
    flex-direction: column;
    padding-bottom: 0;
    .detail-row{
      l-wh: auto;
      flex-direction: column;
      flex: 1;
    }

    .schedule-section{
      padding:30px 10px;
      l-wh: auto 100%;
      display: block;
      border-bottom-left-radius: 0;
      border-bottom-right-radius: 0;
      box-shadow: none;
      flex: 1;

      &:before,&:after{
        content: none;
      }
      &__wrap{
        padding: 0px;
      }

      .options-panel{
        right: 10px;
        top: 37px;
        &.fixed{
          position: fixed;
        }
      }
    }
  }
}
</style>
