<template>
  <MazDialog
    :model-value="props.modelValue"
    @update:model-value="emit('update:model-value', $event)"
    maxWidth="500px"
    maxHeight="80vh"
    scrollable
  >
    <template #title>
      <div class="flex-h flex-ai_c flex-jc_fs">
        <MazIcon
          :name="model.isHotel ? 'hotel' : 'time'"
          size="24px"
          class="spac-mr_s1"
        ></MazIcon>
        编辑{{ model.isHotel ? "住宿" : "行程" }}
      </div>
    </template>
    <form class="flex-v gap-s3">
      <div class="flex-h gap-s2 flex-jc_c">
        <span>行程</span>
        <MazSwitch v-model="model.isHotel" />
        <span>住宿</span>
      </div>
      <MazInput
        v-model="model.name"
        label="行程名称"
        block
        v-bind="hints.name"
        maxlength="50"
      ></MazInput>
      <MazInput
        v-model="model.address"
        label="地址"
        block
        v-bind="hints.address"
        maxlength="300"
      >
      </MazInput>
      <LimitDatePicker
        :label="model.isHotel ? '住宿时间' : '行程时间'"
        v-model="daySelect"
        :limit-date="props.limitDate"
        :is-range="!!model.isHotel"
      ></LimitDatePicker>
      <TimePicker
        v-if="!model.isHotel"
        label="时刻"
        v-model="timeSelect"
      ></TimePicker>
      <!-- <MazPicker
        v-model="model.startTime"
        pickerPosition="bottom"
        :label="model.isHotel ? '住店时间' : '出发时间'"
        :minuteInterval="10"
        :min-date="props.limitDate[0]"
        :max-date="props.limitDate[1]"
        v-bind="hints.startTime"
        format="YYYY-MM-DD HH:mm:ss"
        :time="!model.isHotel"
      ></MazPicker>
      <MazPicker
        v-if="model.isHotel"
        v-model="model.endTime"
        pickerPosition="bottom"
        label="离店时间"
        :minuteInterval="10"
        :min-date="props.limitDate[0]"
        :max-date="props.limitDate[1]"
        format="YYYY-MM-DD HH:mm:ss"
        v-bind="hints.endTime"
      ></MazPicker> -->
      <!-- <MazRadioButtons
        v-model="model.traffic"
        :options="trafficTypeEnum.getArray()"
        color="primary"
        orientation="row"
        class="spac-mb_s2"
      >
        <template #default="{ option }">
          <div class="flex-v flex-ai_c gap-s1 spac-pv_s1" style="width: 50px">
            <MazIcon :name="option.icon" size="24px" />
            <span class="text-s_s">
              {{ option.label }}
            </span>
          </div>
        </template>
      </MazRadioButtons> -->
      <MazTextarea
        v-model="model.notes"
        label="攻略"
        v-bind="hints.equipId"
        rows="8"
      >
      </MazTextarea>
      <div class="flex-v gap-s2 spac-mb_s3">
        <DropUpload
          tip="上传截图/票据"
          @success="handleUploadSuccess"
        ></DropUpload>
        <div class="flex-h gap-s2 flex-w_w">
          <MazAvatar
            v-for="(url, idx) in model.screenshots"
            size="2em"
            clickable
            rounded-size="lg"
            buttonColor="info"
            @click="handleRemoveScreenshot(idx)"
            :src="url"
          >
            <template #icon>
              <MazIcon size="1.6rem" color="white" name="solar/close"></MazIcon>
            </template>
          </MazAvatar>
        </div>
      </div>
    </form>
    <template #footer>
      <MazBtn
        :loading="loading"
        block
        size="sm"
        right-icon="arrow-right"
        @click="handleSubmit"
      >
        保存
      </MazBtn>
    </template>
  </MazDialog>
</template>
<script setup lang="ts">
import DropUpload from "@/components/DropUpload.vue";
import { useForm } from "@/hook/useForm";
import { travelApi, ISchedule } from "@/server/travel";
import { watch, nextTick, ref } from "vue";
import { ruleColl } from "@/helper/rules";
import dayjs from "dayjs";
import LimitDatePicker from "@/components/LimitDatePicker.vue";
import TimePicker from "@/components/TimePicker.vue";

interface IProp {
  modelValue: boolean;
  item?: ISchedule;
  tId?: number;
  limitDate: [string, string];
}

const props = defineProps<IProp>();

watch(
  () => props.modelValue,
  async () => {
    if (props.modelValue) {
      reset();
      await nextTick();
      if (props.item) {
        Object.assign(model, props.item);
        if (model.isHotel && model.startTime && model.endTime) {
          daySelect.value = [
            dayjs(model.startTime).diff(dayjs(props.limitDate[0]), "day") + 1,
            dayjs(model.endTime).diff(dayjs(props.limitDate[0]), "day") + 1,
          ];
        } else if (model.startTime) {
          daySelect.value =
            dayjs(model.startTime).diff(dayjs(props.limitDate[0]), "day") + 1;
          timeSelect.value = dayjs(model.startTime).hour() + 1;
        }
        let screenshots =
          props.item.screenshots && props.item.screenshots !== ""
            ? props.item.screenshots.split(",")
            : [];
        model.screenshots = screenshots || [];
      }
    }
  }
);

const emit = defineEmits<{
  (e: "update:model-value", show: boolean): void;
  (e: "saved", data: ISchedule): void;
}>();

const daySelect = ref<number | [number, number]>(1);
const timeSelect = ref<number>(1);
const { loading, model, hints, handleSubmit, reset } = useForm<
  Omit<ISchedule, "screenshots"> & { screenshots: string[] }
>(
  {
    id: undefined,
    cover: "",
    name: "",
    coordinate: "",
    address: "",
    isHotel: false,
    screenshots: [],
    notes: "",
  },
  {
    rules: {
      name: [
        { required: true, message: "请输入地点名称" },
        ruleColl.strMax(50),
      ],
      // coordinate: [{ required: true, message: "请选择坐标" }],
      address: [ruleColl.strMax(300)],
      // startTime: [
      //   {
      //     validator(_rule, value, callback) {
      //       if (value && !timeIsInTravelDate(value)) {
      //         callback("行程时间需在旅程时间内");
      //       }
      //       callback();
      //     },
      //   },
      // ],
      // endTime: [
      //   {
      //     validator(_rule, value, callback) {
      //       if (value) {
      //         if (!timeIsInTravelDate(value)) {
      //           callback("离店时间需在旅程时间内");
      //         }
      //         const startTime = model.startTime;
      //         if (startTime && dayjs(value).isBefore(startTime)) {
      //           callback("离店不可早于住店日期");
      //         }
      //       }
      //       callback();
      //     },
      //   },
      // ],
    },
    onSubmit: async (model) => {
      let res;
      let data = Object.assign({}, model, {
        tId: props.tId,
        screenshots: model.screenshots.join(","),
      });
      if (
        data.isHotel &&
        Array.isArray(daySelect.value) &&
        daySelect.value.length === 2
      ) {
        data.startTime = dayjs(props.limitDate[0])
          .add(daySelect.value[0] - 1, "day")
          .format("YYYY-MM-DD 12:00:00");
        data.endTime = dayjs(props.limitDate[0])
          .add(daySelect.value[1] - 1, "day")
          .format("YYYY-MM-DD 12:00:00");
      } else if (typeof daySelect.value === "number" && timeSelect.value) {
        data.startTime = dayjs(props.limitDate[0])
          .add(daySelect.value - 1, "day")
          .hour(timeSelect.value - 1)
          .format("YYYY-MM-DD HH:mm:ss");
      }
      if (model.id) {
        res = await travelApi.updateSchedule(data);
      } else {
        res = await travelApi.addSchedule(data);
      }
      if (res.data) {
        emit("saved", res.data);
      }
      emit("update:model-value", false);
    },
  }
);

// function timeIsInTravelDate(value: string) {
//   return dayjs(value).isBetween(
//     props.limitDate[0],
//     props.limitDate[1],
//     null,
//     "[]"
//   );
// }

// function handleSwitchIsHotel() {
//   model.startTime = "";
//   model.endTime = "";
// }

async function handleUploadSuccess(urls: string[]) {
  model.screenshots = model.screenshots.concat(urls);
}

function handleRemoveScreenshot(idx: number) {
  model.screenshots.splice(idx, 1);
}
</script>
