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
          :items="avatarDropMenu"
          v-if="userInfo"
          position="bottom right"
        >
          <MazAvatar
            :src="userInfo.avatar || '/icons/user.svg'"
            imageHeightFull
            :caption="userInfo.name || userInfo.username"
          ></MazAvatar>
        </Dropdown>
      </template>
    </Header>
    <div class="travel-section">
      <div class="spac-mb_s3 flex-h flex-jc_sb flex-ai_c gap-s2">
        <MazInput
          placeholder="搜索旅程"
          class="flex-fill"
          left-icon="solar/search"
          type="search"
          v-model="search"
          @change="handleSearch"
        ></MazInput>
        <!-- <MazBtn
          left-icon="solar/luggage"
          color="info"
          size="sm"
          @click="handleCreateTravel"
          pastel
          >添加旅程</MazBtn
        > -->
      </div>
      <div class="row gutter-m spac-mh_gm">
        <Sketch :loading="isFetching" :count="2">
          <template #template>
            <div class="col-12 col-m-24">
              <SketchItem
                type="box"
                class="travel-item spac-p_s2 flex-v radius-b"
              >
                <div class="spac-p_s2 spac-ph_s3">
                  <SketchItem
                    type="circle"
                    size="120"
                    class="travel-bg"
                  ></SketchItem>
                  <SketchItem type="hn" size="60%"></SketchItem>
                  <SketchItem type="text"></SketchItem>
                </div>
              </SketchItem>
            </div>
          </template>
          <MazTransitionExpand>
            <div class="col-12 col-m-24" key="travel-add">
              <MazCardSpotlight
                v-if="data?.length"
                orientation="row"
                color="primary"
                class="travel-item"
                @click="dialog.createTravel = true"
              >
                <div class="spac-p_s2 spac-ph_s3">
                  <h3 class="spac-mv_s2 text-c_ts text-a_c">
                    <MazIcon name="solar/luggage" size="32px"></MazIcon>
                    <div>添加旅程</div>
                  </h3>
                </div>
              </MazCardSpotlight>
            </div>
            <div
              class="col-12 col-m-24"
              v-for="item in data"
              :key="`travel_${item.id}`"
            >
              <MazCardSpotlight
                :color="trafficStatusEnum.get(item.status).color"
                class="travel-item"
                @click="router.push(`/travel/${item.id}`)"
              >
                <div class="spac-p_s2 spac-ph_s3">
                  <MazIcon
                    :name="trafficStatusEnum.get(item.status).icon"
                    class="travel-bg"
                    size="120px"
                  ></MazIcon>
                  <h3 class="spac-mv_s0 flex-h flex-jc_sb flex-ai_c">
                    <span class="text-c_t text-o_e flex-fill">
                      {{ item.name }}
                    </span>
                    <div class="text-c_ts text-s_m flex-shrink spac-ml_s1">
                      {{
                        dayjs(item.endDate).diff(item.startDate, "day") + 1
                      }}天游
                    </div>
                  </h3>
                  <div class="text-c_ts text-s_m">
                    {{ DateUtil.travelDate(item.startDate, item.endDate) }}
                  </div>
                  <div class="spac-mt_s2">
                    <MazBadge
                      pastel
                      :color="trafficStatusEnum.get(item.status).color"
                    >
                      {{ trafficStatusEnum.get(item.status).label }}
                    </MazBadge>
                  </div>
                </div>
              </MazCardSpotlight>
            </div>
          </MazTransitionExpand>
        </Sketch>
      </div>
      <div
        class="empty text-a_c text-c_ts spac-pv_m2"
        v-if="!isFetching && data?.length === 0"
      >
        <MazIcon name="island" size="120px"></MazIcon>
        <div class="spac-mb_s3">还没创建旅游计划，快来一场计划充足的旅程吧</div>
        <MazCardSpotlight
          color="primary"
          @click="dialog.createTravel = true"
          style="width: 360px"
        >
          <div class="spac-p_s2 spac-ph_s3">
            <h3 class="spac-mv_s1 text-c_ts text-a_c">
              <MazIcon name="solar/luggage" size="32px"></MazIcon>
              <div>添加旅程</div>
            </h3>
          </div>
        </MazCardSpotlight>
      </div>
      <div
        class="empty text-a_c text-c_ts spac-pv_s4"
        v-if="isFinished && data && data.length > 0"
      >
        <MazIcon name="island" size="60px"></MazIcon>
        <div>没有更多了</div>
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
import Dropdown from "@/components/Dropdown.vue";
import { ITravel, travelApi } from "@/server/travel";
import { onMounted, reactive, ref } from "vue";
import dayjs from "dayjs";
import { useRouter } from "vue-router";
import { useFetch } from "@/hook/useFecth";
import { trafficStatus, trafficStatusEnum } from "@/helper/enum";
import { DateUtil, throttle } from "@/helper/util";
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
    action: () => (dialog.modifyInfo = true),
  },
  {
    label: "修改密码",
    icon: "solar/key",
    action: () => (dialog.modifyPassword = true),
  },
  {
    label: "退出",
    icon: "solar/signout",
    action: () => {
      store.setToken("");
      router.push("/signin");
    },
  },
];

// const randomBg = () => {
//   let svgIcon: string[] = ["ship", "train", "sun", "tent", "fountain"];
//   return svgIcon[Math.floor(Math.random() * svgIcon.length)];
// };

const search = ref("");
const { data, isFetching, isFinished, registerObserver, fetch } = useFetch<
  ITravel & { status: string }
>(async (page: number) => {
  let res = await travelApi.page({ page, name: search.value, pageSize: 15 });
  return res.data.record.map((item) => {
    const status = getStatus(item);
    return Object.assign({ status: status }, item);
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
    l-wh: 100% auto var(--maz-border-radius-lg);
    background: var(--maz-color-bg);
    box-shadow: yoz_shadow.ph;
    // overflow hidden auto;
    padding: 30px;
    .travel-item{
      width: 100%;
      margin-bottom: 24px;
      cursor: pointer;
      .content{
        overflow: hidden;
        height: 130px;
      }
      .travel-bg{
        z-index -1;
        l-abs: 0 0 'rb';
        transform: scale(1.4);
        opacity 0.2;
      }
    }
  }
  .avatar-list{
    l-mv: 20px 0;
    display: flex;
    // flex-direction: row;
    margin-inline-start: calc(-1*-10px);
    .m-avatar{
      margin-inline-start: -10px;
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
