<template>
  <MazDialog
    :model-value="props.modelValue"
    @update:model-value="emit('update:model-value', $event)"
    scrollable
    maxHeight="80vh"
  >
    <template #title>
      <div class="spac-pv_s2 flex-h flex-ai_c flex-jc_fs">
        <MazIcon name="sun" size="24px" class="spac-mr_s1"></MazIcon>
        {{ model.id ? "编辑" : "添加" }}行程
      </div>
    </template>
    <form class="flex-v gap-s3" @keyup.enter="handleSubmit">
      <MazInput
        v-model="model.name"
        label="行程地点"
        v-bind="hints.name"
        maxlength="50"
      ></MazInput>

      <div class="flex-h gap-s2">
        <MazInput
          class="flex-fill"
          readonly
          :model-value="model.coordinate"
          v-bind="hints.coordinate"
          label="坐标"
        ></MazInput>
        <LocationSelector
          :center="model.coordinate"
          @select="handleSelectLocation"
        ></LocationSelector>
      </div>
      <MazInput
        v-model="model.address"
        label="地址"
        v-bind="hints.address"
        maxlength="300"
      >
      </MazInput>
      <MazTextarea v-model="model.notes" label="攻略" v-bind="hints.equipId">
      </MazTextarea>
      <div class="flex-h gap-s2 flex-jc_c">
        <span>行程</span>
        <MazSwitch v-model="model.isHotel" @change="handleSwitchIsHotel" />
        <span>住宿</span>
      </div>
      <MazPicker
        v-model="model.startTime"
        pickerPosition="top"
        :label="model.isHotel ? '住店时间' : '出发时间'"
        :min-date="props.limitDate[0]"
        :max-date="props.limitDate[1]"
        v-bind="hints.startTime"
        format="YYYY-MM-DD HH:mm:ss"
        time
      ></MazPicker>
      <MazPicker
        v-if="model.isHotel"
        v-model="model.endTime"
        pickerPosition="top"
        label="离店时间"
        :min-date="props.limitDate[0]"
        :max-date="props.limitDate[1]"
        format="YYYY-MM-DD HH:mm:ss"
        v-bind="hints.endTime"
        time
      ></MazPicker>
      <div class="flex-v gap-s2">
        <div class="text-a_c">交通方式</div>
        <MazRadioButtons
          v-model="model.traffic"
          :options="trafficTypeEnum.getArray()"
          color="secondary"
          class="flex-jc_c"
        >
          <template #default="{ option }">
            <div class="flex-v flex-ai_c gap-s1 spac-pv_s1" style="width: 50px">
              <MazIcon :name="option.icon" size="24px" />
              <span class="text-s_s">
                {{ option.label }}
              </span>
            </div>
          </template>
        </MazRadioButtons>
      </div>
      <div class="flex-v gap-s2 spac-mb_s3">
        <div class="text-a_c">截图/票据</div>
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
        <DropUpload
          tip="上传截图/票据"
          @success="handleUploadSuccess"
        ></DropUpload>
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
        {{ model.id ? "保存" : "添加" }}
      </MazBtn>
    </template>
  </MazDialog>
</template>
<script setup lang="ts">
import LocationSelector from "@/components/LocationSelector.vue";
import DropUpload from "@/components/DropUpload.vue";
import { useForm } from "@/hook/useForm";
import { MapUtil } from "@/helper/amap";
import { travelApi, ISchedule } from "@/server/travel";
import { trafficTypeEnum } from "@/helper/enum";
import { watch, nextTick } from "vue";
import dayjs from "dayjs";
import { ruleColl } from "@/helper/rules";

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
      coordinate: [{ required: true, message: "请选择坐标" }],
      address: [ruleColl.strMax(300)],
      startTime: [
        {
          validator(_rule, value, callback) {
            if (value && !timeIsInTravelDate(value)) {
              callback("行程时间需在旅程时间内");
            }
            callback();
          },
        },
      ],
      endTime: [
        {
          validator(_rule, value, callback) {
            if (value) {
              if (!timeIsInTravelDate(value)) {
                callback("离店时间需在旅程时间内");
              }
              const startTime = model.startTime;
              if (startTime && dayjs(value).isBefore(startTime)) {
                callback("离店不可早于住店日期");
              }
            }
            callback();
          },
        },
      ],
    },
    onSubmit: async (model) => {
      let res;
      let data = Object.assign({}, model, {
        tId: props.tId,
        screenshots: model.screenshots.join(","),
      });
      if (!data.isHotel) {
        delete data.endTime;
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

function timeIsInTravelDate(value: string) {
  return dayjs(value).isBetween(
    props.limitDate[0],
    props.limitDate[1],
    null,
    "[]"
  );
}

function handleSwitchIsHotel() {
  model.startTime = "";
  model.endTime = undefined;
}

async function handleSelectLocation({
  lnglat,
  POI,
}: {
  lnglat: AMap.LocationValue | null;
  POI: AMap.Autocomplete.Tip | null;
}) {
  if (lnglat) {
    model.coordinate = lnglat.toString();
  }
  if (POI) {
    model.name = POI.name;
    model.address = `${POI.district}${POI.address}`;
  } else if (lnglat) {
    handleTransformAddress();
  }
}

async function handleTransformAddress() {
  const lnglat = MapUtil.stringToLngLat(model.coordinate);
  if (lnglat) {
    let address = await MapUtil.getAddress(lnglat);
    if (address) {
      model.address = address.regeocode.formattedAddress;
    }
  }
}

async function handleUploadSuccess(urls: string[]) {
  model.screenshots = model.screenshots.concat(urls);
}

function handleRemoveScreenshot(idx: number) {
  model.screenshots.splice(idx, 1);
}
</script>
