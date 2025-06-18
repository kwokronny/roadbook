<template>
  <MazDialog
    :model-value="props.modelValue"
    @update:model-value="emit('update:model-value', $event)"
  >
    <template #title>
      <div class="flex-h flex-ai_c">
        <MazIcon name="solar/travel" size="24px" class="spac-mr_s1"></MazIcon>
        {{ model.id ? "编辑旅程" : "创建旅程" }}
      </div>
    </template>
    <form class="flex-v gap-s3">
      <MazInput
        v-model="model.name"
        label="旅程计划"
        maxlength="50"
        block
        v-bind="hints.name"
      ></MazInput>
      <MazPicker
        v-model="model.startDate"
        label="开始日期"
        auto-close
        format="YYYY-MM-DD 00:00:00"
        v-bind="hints.startDate"
      ></MazPicker>
      <MazPicker
        v-model="model.endDate"
        auto-close
        label="结束日期"
        format="YYYY-MM-DD 23:59:59"
        v-bind="hints.endDate"
      ></MazPicker>
      <div>
        <MazInputTags
          v-model="model.city"
          label="城市"
          placeholder="请输入前往的城市"
          v-bind="hints.city"
          block
          multiple
        ></MazInputTags>
        <div class="text-c_ts text-s_s spac-mh_s1">
          用于辅助地图限制搜索范围
        </div>
      </div>
      <!-- <MazSelect
        v-if="!model.id"
        v-model="model.equip"
        label="行李清单模板"
        :options="options.equips"
        v-bind="hints.equip"
      >
      </MazSelect> -->
      <div class="flex-v">
        <div class="flex-h flex-ai_c flex-jc_c gap-s1">
          <div class="text-c_ts">私密</div>
          <MazSwitch v-model="model.public"></MazSwitch>
          <div class="text-c_success">公开</div>
        </div>
        <div class="text-s_s text-c_ts text-a_c spac-mt_s2">
          可以通过邀请协作者共同制定旅程<br />
          {{ model.public ? "所有人可通过分享链接直接查看旅程" : "" }}
        </div>
      </div>
      <MazBtn
        block
        :loading="loading"
        right-icon="arrow-right"
        @click="handleSubmit"
      >
        保存旅程
      </MazBtn>
    </form>
  </MazDialog>
</template>
<script setup lang="ts">
import { ref, watch } from "vue";
import { travelApi, ITravel } from "@/server/travel";
// import { equipApi } from "@/server/equip";
import { useForm } from "@/hook/useForm";
import dayjs from "dayjs";
import { DateUtil, objectUtil } from "@/helper/util";
// import { type MazSelectOption } from "maz-ui/components/MazSelect";

interface IProp {
  modelValue: boolean;
  detail?: ITravel;
}
const props = defineProps<IProp>();
const emit = defineEmits<{
  (e: "update:model-value", value: boolean): void;
  (e: "saved", id: number): void;
}>();

const loading = ref<boolean>(false);

const { model, handleSubmit, hints, reset } = useForm<ITravel>(
  {
    id: undefined,
    name: `旅程计划${DateUtil.dateFm(new Date())}`,
    city: [],
    startDate: "",
    endDate: "",
    userIds: [],
    public: false,
    equip: "",
  },
  {
    rules: {
      name: [
        { required: true, message: "请输入旅程名称" },
        { type: "string", max: 50, message: "最大50个字符" },
      ],
      startDate: [{ required: true, message: "请选择日期" }],
      endDate: [
        { required: true, message: "请选择日期" },
        {
          validator(_rule, value, callback) {
            if (dayjs(value).isBefore(model.startDate)) {
              callback("结束日期不可早于开始日期");
            }
            callback();
          },
        },
      ],
    },
    onSubmit: async (data) => {
      const res = await travelApi.save(
        Object.assign(data, { city: (data.city || []).join(",") })
      );
      emit("saved", res.data.id!);
      emit("update:model-value", false);
    },
  }
);

// const options = reactive<{
// equips: MazSelectOption[];
// citys: string[];
// }>({
// equips: [],
// citys: [],
// });

// async function getEquipList() {
//   try {
//     let res = await equipApi.list();
//     res.forEach((item) => {
//       try {
//         options.equips.push({
//           label: item.name,
//           value: JSON.stringify(item.list),
//         });
//       } catch {}
//     });
//   } catch {}
// }

// async function getCityOptions() {
//   try {
//     await fetch("/city.json").then((res) => {
//       res.json().then((data) => {
//         options.citys = data;
//       });
//     });
//   } catch (e) {
//     console.error(e);
//   }
// }

watch(
  () => props.modelValue,
  (val) => {
    if (val) {
      reset();
      // getEquipList();
      // getCityOptions();
      if (props.detail) {
        Object.assign(model, objectUtil.omitEmpty(props.detail));
      }
    }
  },
  { immediate: true }
);
</script>
