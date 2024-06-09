<template>
  <MazDialog
    :model-value="props.modelValue"
    @update:model-value="emit('update:model-value', $event)"
  >
    <template #title>
      <div class="spac-pv_s2 flex-h flex-ai_c">
        <MazIcon name="luggage" size="24px" class="spac-mr_s1"></MazIcon>
        {{ model.id ? "编辑旅程" : "创建旅程" }}
      </div>
    </template>
    <form class="flex-v gap-s3" @keyup.enter="handleSubmit">
      <MazInput
        v-model="model.name"
        left-icon="island"
        label="旅程计划"
        maxlength="50"
        v-bind="hints.name"
      ></MazInput>
      <MazPicker
        v-model="model.startDate"
        left-icon="calendar"
        label="开始日期"
        auto-close
        format="YYYY-MM-DD 00:00:00"
        v-bind="hints.startDate"
      ></MazPicker>
      <MazPicker
        v-model="model.endDate"
        left-icon="calendar"
        auto-close
        label="结束日期"
        format="YYYY-MM-DD 23:59:59"
        v-bind="hints.endDate"
      ></MazPicker>
      <MazSelect
        v-if="!model.id"
        v-model="model.equip"
        left-icon="luggage"
        label="行李清单模板"
        :options="equipOptions"
        option-input-value-key="name"
        option-label-key="name"
        option-value-key="list"
        v-bind="hints.equip"
      >
      </MazSelect>
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
import { nextTick, ref, watch } from "vue";
import { travelApi, ITravel } from "@/server/travel";
import { IEquipList, equipApi } from "@/server/equip";
import { useForm } from "@/hook/useForm";
import dayjs from "dayjs";
import { objectUtil } from "@/helper/util";

interface IProp {
  modelValue: boolean;
  item?: ITravel;
}
const props = defineProps<IProp>();
const emit = defineEmits<{
  (e: "update:model-value", value: boolean): void;
  (e: "saved", id: number): void;
}>();

watch(
  () => props.modelValue,
  async () => {
    if (props.modelValue) {
      reset();
      getEquipList();
      await nextTick();
      if (props.item) {
        Object.assign(model, objectUtil.omitEmpty(props.item));
      }
    }
  }
);

const loading = ref<boolean>(false);

const { model, handleSubmit, hints, reset } = useForm<ITravel>(
  {
    id: undefined,
    name: "",
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
      data.equip = JSON.stringify(data.equip);
      const res = await travelApi.save(data);
      emit("saved", res.data.id!);
      emit("update:model-value", false);
    },
  }
);

let equipOptions = ref<IEquipList[]>();

async function getEquipList() {
  try {
    let res = await equipApi.list();
    equipOptions.value = res;
  } catch {}
}
</script>
