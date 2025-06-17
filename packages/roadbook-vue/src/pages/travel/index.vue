<template>
  <div class="travel-page page">
    <Header>
      <template #extra>
        <MazBtn
          fab
          href="https://roadbook.kwokronny.com/docs"
          target="_blank"
          color="info"
          pastel
          icon="solar/help"
        ></MazBtn>
        <MazBtn
          fab
          @click="store.toggleTheme"
          color="theme"
          :icon="theme"
        ></MazBtn>
        <Dropdown
          v-if="userInfo"
          :items="avatarDropMenu"
          position="bottom right"
        >
          <MazAvatar
            :src="userInfo.avatar"
            fallback-src="/logo.png"
            buttonColor="success"
            imageHeightFull
            :caption="userInfo.name || userInfo.username"
          ></MazAvatar>
        </Dropdown>
      </template>
    </Header>
    <div class="travel-section">
      <div class="spac-mb_s3 flex-h flex-jc_sb flex-ai_c gap-s2">
        <MazInput
          placeholder="搜索计划"
          class="flex-fill"
          left-icon="solar/search"
          type="search"
          color="success"
          block
          v-model="search"
          @change="handleSearch"
        ></MazInput>
        <MazBtn
          left-icon="solar/travel"
          color="success"
          @click="dialog.createTravel = true"
        >
          添加计划
        </MazBtn>
      </div>
      <div class="row gutter-m spac-mh_gm">
        <Sketch :loading="isFetching" :count="2">
          <template #template>
            <div class="col-12 col-m-24">
              <TravelSketchItem></TravelSketchItem>
            </div>
          </template>
          <MazTransitionExpand>
            <div
              class="col-12 col-m-24"
              v-for="item in data"
              :key="`travel_${item.id}`"
            >
              <TravelItem :data="item"></TravelItem>
            </div>
          </MazTransitionExpand>
        </Sketch>
      </div>
      <div
        class="empty text-a_c text-c_ts spac-pv_m2"
        v-if="!isFetching && data?.length === 0"
      >
        <img
          src="/icons/island.svg"
          class="spac-mb_s2"
          style="width: 120px; height: 120px"
        />
        <div class="spac-mb_s3">还没创建旅游计划</div>
        <MazBtn
          left-icon="solar/travel"
          color="success"
          @click="dialog.createTravel = true"
        >
          添加计划
        </MazBtn>
      </div>
      <div
        class="empty text-a_c text-c_ts spac-pv_s4"
        v-if="isFinished && data && data.length > 0"
      >
        <img
          src="/icons/island.svg"
          class="spac-mb_s2"
          style="width: 60px; height: 60px"
        />
        <div>所有计划已显示</div>
      </div>
      <div class="loading-observer"></div>
    </div>
  </div>
  <ModifyInfoDialog v-model="dialog.modifyInfo"></ModifyInfoDialog>
  <ModifyPasswordDialog v-model="dialog.modifyPassword"></ModifyPasswordDialog>
  <EditTravelDialog
    v-model="dialog.createTravel"
    @saved="(id) => router.push(`/travel/${id}`)"
  ></EditTravelDialog>
</template>
<script setup lang="ts">
import ModifyInfoDialog from "./components/ModifyInfoDialog.vue";
import ModifyPasswordDialog from "./components/ModifyPasswordDialog.vue";
import EditTravelDialog from "./components/EditTravelDialog.vue";
import TravelItem from "./components/TravelItem.vue";
import TravelSketchItem from "./components/TravelSketchItem.vue";
import { ITravel, travelApi } from "@/server/travel";
import { onMounted, reactive, ref } from "vue";
import dayjs from "dayjs";
import { useRouter } from "vue-router";
import { useFetch } from "@/hook/useFecth";
import { type trafficStatus } from "@/helper/enum";
import { throttle } from "@/helper/util";
import { useStore } from "@/store";
import { storeToRefs } from "pinia";

const router = useRouter();
const store = useStore();
const { userInfo, theme } = storeToRefs(store);

const dialog = reactive({
  modifyInfo: false,
  modifyPassword: false,
  createTravel: false,
});

const avatarDropMenu = [
  {
    label: "编辑信息",
    icon: "solar/edit",
    class: "text-c_t",
    action: () => (dialog.modifyInfo = true),
  },
  {
    label: "修改密码",
    icon: "solar/password",
    class: "text-c_t",
    action: () => (dialog.modifyPassword = true),
  },
  {
    label: "退出",
    icon: "solar/signout",
    class: "text-c_t",
    action: () => {
      store.setToken("");
      router.push("/signin");
    },
  },
];

const search = ref("");
const { data, isFetching, isFinished, registerObserver, fetch } = useFetch<
  ITravel & { status: string; duration: number }
>(async (page: number) => {
  let res = await travelApi.page({ page, name: search.value, pageSize: 15 });
  return res.data.record.map((item) => {
    const status = getStatus(item);
    const duration = dayjs(item.endDate).diff(item.startDate, "day") + 1;
    return Object.assign({ status: status, duration: duration }, item);
  });
});

const handleSearch = throttle(() => fetch(1), 500);

onMounted(() => {
  registerObserver(".loading-observer");
});

function getStatus(item: ITravel): trafficStatus {
  return dayjs().diff(new Date(item.startDate), "day") >= 0
    ? dayjs().diff(new Date(item.endDate), "day") <= 0
      ? "traving"
      : "over"
    : "ready";
}
</script>
<style lang="stylus">
.travel-page {
  padding-bottom: 40px;
  width: 900px;
  max-width: 100%;
  height: auto;
  l-flex: v;
  l-mh: auto;
  .travel-section{
    flex: 1;
    border-radius: var(--maz-border-radius-lg);
    background: var(--maz-color-bg);
    // box-shadow: yoz_shadow.ph;
    // overflow hidden auto;
    padding: 30px;
    .travel-item{
      margin-bottom: 24px;
      cursor: pointer;
    }
  }
}

@media screen and (max-width: 640px) {
  .travel-page {
    padding-bottom: 0;
    .travel-section{
      border-bottom-left-radius: 0;
      border-bottom-right-radius: 0;
      box-shadow: none;
      padding-top: 50px;
      l-ph: 10px;
    }
  }
}
</style>
