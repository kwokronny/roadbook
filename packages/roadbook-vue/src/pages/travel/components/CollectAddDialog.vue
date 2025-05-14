<template>
  <MazDialog
    :model-value="props.modelValue"
    @update:model-value="emit('update:modelValue', $event)"
    max-width="500px"
    max-height="80vh"
    scrollable
  >
    <template #title>
      <div class="spac-pt_s2 flex-h flex-ai_c">
        <MazIcon
          name="solar/add-collection"
          size="24px"
          class="spac-mr_s1"
        ></MazIcon>
        添加数据合集
      </div>
    </template>
    <Quote color="info" icon="solar/magic" class="spac-mb_s2">
      可通过AI 平台规划行程并让AI按固定格式返回计划，示例：<br />
      <div class="flex-h flex-ai_c gap-s0">
        可
        <MazBadge color="info" @click="handleCopy(aiPrompt.planning)">
          <MazIcon name="solar/copy" size="16px" class="spac-mr_s0"></MazIcon>
          复制
        </MazBadge>
        文本到Deepseek等AI平台返回
      </div>
      <pre class="prompt-example">{{ aiPrompt.planning }}</pre>
      更多合集导出方式可阅读《合集导出》
    </Quote>
    <MazTextarea
      label="合集JSON"
      color="success"
      :placeholder="collectInputPlaceholder"
      v-model="collectJSON"
      :rows="5"
    />
    <!-- <MazRadioButtons color="success" v-model="tab" :options="tabs" /> -->
    <template #footer>
      <MazBtn block color="success" @click="handleAddTravel"> 添加合集 </MazBtn>
    </template>
  </MazDialog>
  <MazFullscreenLoader v-if="loader.show" color="white" @click="closeLoader">
    <div v-for="(log, idx) in loader.logs" :key="idx" class="loader-log">
      <template v-if="log.name">
        <span class="spac-mr_s1">{{ log.name }}</span>
        <MazSpinner v-if="log.status === 'pending'" color="white" />
        <MazIcon
          v-else-if="log.status === 'success'"
          name="solar/check"
          color="white"
        />
        <MazIcon
          v-else-if="log.status === 'error'"
          name="solar/close"
          color="white"
        />
      </template>
      <template v-else-if="log.status === 'text'">
        {{ log.name }}
      </template>
    </div>
  </MazFullscreenLoader>
</template>
<script setup lang="ts">
import { DateUtil } from "@/helper/util";
import { ITravel, travelApi } from "@/server/travel";
import { useToast } from "maz-ui";
import { reactive, ref } from "vue";

const props = defineProps<{
  modelValue: boolean;
  detail: ITravel;
}>();

const emit = defineEmits<{
  (e: "update:modelValue", arg: boolean): void;
}>();

const collectInputPlaceholder = `[{"name":"行程名称","coordinate":"经度,纬度", "address":"行程地址","startTime":"建议行程时间，格式为：YYYY-MM-DD HH:mm:ss","notes":"推荐理由与网址"}]`;
const collectJSON = ref<string>("");

const aiPrompt = reactive({
  planning: "",
  reply: "",
});

const toast = useToast();

const generateAIPrompt = () => {
  let { startDate, endDate, city } = props.detail;
  startDate = DateUtil.dateFm(startDate);
  endDate = DateUtil.dateFm(endDate);
  aiPrompt.planning = `出一份去往${city}的旅行计划\n计划出行日期${startDate}至${endDate}\n经纬度使用GCJ-02坐标系\n按固定格式返回计划： [{"name":"行程名称","coordinate":"经度,纬度", "address":"行程地址","startTime":"建议行程时间，格式为：YYYY-MM-DD HH:mm:ss","notes":"推荐理由与网址"}]`;
};

generateAIPrompt();

const handleCopy = (text: string) => {
  navigator.clipboard.writeText(text);
  toast.success("已复制到剪贴板");
};

const handleAddTravel = async () => {
  resetLoader();
  loader.show = true;
  loader.logs.push({
    name: "开始计划...",
    status: "text",
  });
  try {
    const schedules = JSON.parse(collectJSON.value);
    loader.logs.push({
      name: `解析成功，开始添加${schedules.length}个行程...`,
      status: "text",
    });
    for (const schedule of schedules) {
      let idx = loader.logs.push({
        name: `添加行程：${schedule.name}`,
        status: "pending",
      });
      idx = idx - 1;
      if (loader.logs[idx]?.status === "pending") {
        try {
          await travelApi.addSchedule(
            Object.assign({ tId: props.detail.id, isHotel: false }, schedule)
          );
          loader.logs[idx].status = "success";
        } catch (e) {
          loader.logs[idx].status = "error";
        }
      }
    }
    loader.logs.push({
      name: `已添加${schedules.length}个行程，点击屏幕关闭`,
      status: "text",
    });
    loader.canClose = true;
  } catch (e) {
    loader.show = false;
    return toast.error("解析失败，请检查JSON格式是否正确");
  }
};

// const dianpingCollect = reactive<{
//   url: string;
//   result: string;
//   skip: boolean;
// }>({
//   url: "",
//   result: "",
//   skip: false,
// });

// const collectUrl = computed(() => {
//   if (!dianpingCollect.url) return "";
//   let url = dianpingCollect.url.match(/(http(|s):\/\/[^\s]+)/g);
//   if (!url?.[0]) return "";
//   const albumId = url[0].match(/albumId=(\d+)/i)?.[1];
//   if (!albumId) return "";
//   return `https://mapi.dianping.com/mapi/collect/getfavoralbumdetail.bin?nextstart=&type=0&albumid=${albumId}&mapi_cacheType=0&`;
// });

// const handleAddDianpingTravel = async () => {
//   resetLoader();
//   loader.show = true;
//   loader.logs.push("开始解析计划...");
//   try {
//     const dianpingResult = JSON.parse(dianpingCollect.result);
//     if (dianpingResult.records?.[0].collectItemList?.length) {
//       const schedules = dianpingResult.records[0].collectItemList;
//       loader.logs.push(`解析成功，开始添加${schedules.length}个行程...`);
//       for (const schedule of schedules) {
//         try {
//           loader.logs.push(`添加行程：${schedule.title}`);
//           await travelApi.addSchedule({
//             tId: props.detail.id,
//             isHotel: false,
//             name: schedule.title,
//             cover: schedule.image,
//             dianpingUUID: schedule.favorCore?.bizUuid || "",
//             coordinate: `${schedule.lng},${schedule.lat}`,
//             address: schedule.address,
//             notes: `====大众点评====\n${schedule.collectShare.content}`,
//           });
//           loader.logs.push(`添加行程成功：${schedule.title}`);
//         } catch (e) {
//           loader.logs.push(`添加行程失败：${schedule.title}`);
//         }
//       }
//       toast.success("添加行程成功");
//     } else {
//       toast.error("未获取到行程");
//     }
//   } catch (e) {
//     return toast.error("解析失败，请检查JSON格式是否正确");
//   }
// };

interface IScheduleLog {
  name: string;
  status: "pending" | "success" | "error" | "text";
}

const loader = reactive<{
  show: boolean;
  canClose: boolean;
  logs: Array<IScheduleLog>;
}>({
  show: false,
  canClose: false,
  logs: [],
});

function closeLoader() {
  if (loader.canClose) {
    loader.show = false;
    collectJSON.value = "";
    emit("update:modelValue", false);
  }
}

function resetLoader() {
  loader.logs = [];
  loader.canClose = false;
}
</script>
<style lang="stylus" scoped>
.prompt-example {
  overflow: scroll;
  max-height: 120px;
  background-color: #f0f0f0;
  padding: 10px;
  border-radius: 5px;
  white-space: pre-wrap;
  word-break: break-all;
}
.loader-log {
  color: white;
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
}
</style>
