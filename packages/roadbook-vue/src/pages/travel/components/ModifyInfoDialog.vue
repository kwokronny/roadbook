<template>
  <MazDialog
    :model-value="props.modelValue"
    @update:model-value="emit('update:model-value', $event)"
  >
    <template #title>
      <div class="spac-pv_s2 flex-h flex-ai_c">
        <MazIcon name="user" size="24px" class="spac-mr_s1"></MazIcon>
        编辑信息
      </div>
    </template>
    <form class="flex-v gap-s3">
      <Upload style="align-self: center" @success="handleUploadSuccess">
        <MazAvatar
          :src="model.avatar"
          fallback-src="/logo.png"
          :caption="model.name"
          buttonColor="black"
          clickable
          size="3rem"
        >
          <template #icon>
            <MazIcon name="solar/upload" size="40px" color="white"></MazIcon>
          </template>
        </MazAvatar>
      </Upload>
      <MazInput
        v-model="model.name"
        label="昵称"
        block
        color="success"
        v-bind="hints.name"
        maxlength="50"
      ></MazInput>
      <MazBtn
        block
        :loading="loading"
        color="success"
        right-icon="arrow-right"
        @click="handleSubmit"
      >
        保存信息
      </MazBtn>
    </form>
  </MazDialog>
</template>
<script setup lang="ts">
import { nextTick, ref, watch } from "vue";
import { useForm } from "@/hook/useForm";
import { IUser, userApi } from "@/server/user";
import { useStore } from "@/store";
import { storeToRefs } from "pinia";
import Upload from "@/components/Upload.vue";
import { ruleColl } from "@/helper/rules";

interface IProp {
  modelValue: boolean;
}
const props = defineProps<IProp>();
const emit = defineEmits<{
  (e: "update:model-value", value: boolean): void;
  (e: "saved"): void;
}>();

const store = useStore();
const { userInfo } = storeToRefs(store);
watch(
  () => props.modelValue,
  async () => {
    if (props.modelValue) {
      reset();
      await nextTick();
      if (userInfo.value) {
        Object.assign(model, userInfo.value);
        model.name = userInfo.value.name || userInfo.value.username;
      }
    }
  }
);

const loading = ref<boolean>(false);
const { model, handleSubmit, hints, reset } = useForm<
  Pick<IUser, "id" | "name" | "avatar">
>(
  {
    id: undefined,
    name: "",
    avatar: "",
  },
  {
    rules: {
      name: ruleColl.strMax(50),
    },
    onSubmit: async (data) => {
      await userApi.update(data);
      await store.getCurrentInfo();
      emit("saved");
      emit("update:model-value", false);
    },
  }
);

function handleUploadSuccess(url: string[]) {
  model.avatar = url[0];
}
</script>
