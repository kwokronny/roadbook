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
    <div class="flex-v gap-s2">
      <MazSelect
        label="合集数据类型"
        color="success"
        v-model="collectType"
        :options="collectTypeOptions"
      />
      <MazTextarea
        label="合集JSON"
        color="success"
        :placeholder="collectInputPlaceholder"
        v-model="collectJSON"
        :rows="5"
      />
      <Quote v-if="collectType === 'default'" color="info" icon="solar/magic">
        可通过AI
        平台规划行程或将收集的攻略交给AI分析，并让AI按固定格式返回计划，示例：<br />
        可将下面的文本到Deepseek等AI平台返回（注意：AI会骗人）
        <pre class="prompt-example">{{ aiPrompt.planning }}</pre>
        <MazBadge color="info" @click="handleCopy(aiPrompt.planning)">
          <MazIcon name="solar/copy" size="16px" class="spac-mr_s0"></MazIcon>
          复制
        </MazBadge>
      </Quote>
      <Quote
        v-else-if="collectType === 'dianping'"
        color="warning"
        icon="dianping"
      >
        如何获取点评的合集JSON？
        <a href="https://kwokronny.github.io/roadbook/travel-planning.html#%E5%A6%82%E4%BD%95%E8%8E%B7%E5%8F%96%E7%82%B9%E8%AF%84%E4%B8%93%E8%BE%91json%E6%95%B0%E6%8D%AE" target="_blank">
          👉点击查看
        </a>
      </Quote>
    </div>
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
import { ISchedule, ITravel, travelApi } from "@/server/travel";
import { useToast } from "maz-ui";
import { computed, reactive, ref } from "vue";

const props = defineProps<{
  modelValue: boolean;
  detail: ITravel;
}>();

const emit = defineEmits<{
  (e: "update:modelValue", arg: boolean): void;
  (e: "saved"): void;
}>();

const collectInputPlaceholder = computed(() => {
  if (collectType.value === "dianping") {
    return "点评返回的合集JSON";
  }
  return `[{"name":"行程名称","coordinate":"经度,纬度", "address":"行程地址","startTime":"建议行程时间，格式为：YYYY-MM-DD HH:mm:ss","notes":"推荐理由与网址"}]`;
});
const collectJSON = ref<string>("");
const collectType = ref<string>("default");

const collectTypeOptions = ref([
  { label: "默认", value: "default" },
  { label: "点评", value: "dianping" },
]);

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
  let schedules: ISchedule[] = [];
  try {
    if (collectType.value === "dianping") {
      schedules = dianpingDataTransform();
    } else {
      schedules = JSON.parse(collectJSON.value);
    }
  } catch (e) {
    loader.show = false;
    return toast.error("解析失败，请检查JSON格式是否正确");
  }
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

const dianpingDataTransform = (): ISchedule[] => {
  const data: ISchedule[] = [];
  const dianpingResult = JSON.parse(collectJSON.value);
  if (dianpingResult.records?.[0].collectItemList?.length) {
    const schedules = dianpingResult.records[0].collectItemList;
    for (const schedule of schedules) {
      data.push({
        isHotel: false,
        name: schedule.title,
        cover: schedule.image,
        dianpingUUID: schedule.favorCore?.bizUuid || "",
        coordinate: `${schedule.lng},${schedule.lat}`,
        address: schedule.address,
        notes: `====大众点评====\n${schedule.collectShare.content}`,
      });
    }
  }
  return data;
};

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
    emit("saved");
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
