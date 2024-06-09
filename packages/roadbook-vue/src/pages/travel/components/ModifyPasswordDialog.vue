<template>
  <MazDialog
    :model-value="props.modelValue"
    @update:model-value="emit('update:model-value', $event)"
  >
    <template #title>
      <div class="spac-pv_s2 flex-h flex-ai_c">
        <MazIcon name="key" size="24px" class="spac-mr_s1"></MazIcon>
        修改密码
      </div>
    </template>
    <form class="flex-v gap-s3" @keyup.enter="handleSubmit">
      <MazInput
        v-model="model.oldPassword"
        type="password"
        label="原密码"
        maxlength="16"
        v-bind="hints.oldPassword"
      ></MazInput>
      <MazInput
        v-model="model.password"
        type="password"
        label="新密码"
        maxlength="16"
        v-bind="hints.password"
      ></MazInput>
      <MazInput
        v-model="model.confirmPassword"
        type="password"
        label="确认新密码"
        maxlength="16"
        v-bind="hints.confirmPassword"
      ></MazInput>
      <MazBtn
        block
        :loading="loading"
        right-icon="arrow-right"
        @click="handleSubmit"
      >
        确认修改
      </MazBtn>
    </form>
  </MazDialog>
</template>
<script setup lang="ts">
import md5 from "md5";
import { ref } from "vue";
import { useForm } from "@/hook/useForm";
import { IReqUserModifyPassword, userApi } from "@/server/user";

interface IProp {
  modelValue: boolean;
}
const props = defineProps<IProp>();
const emit = defineEmits<{
  (e: "update:model-value", value: boolean): void;
  (e: "saved"): void;
}>();

const loading = ref<boolean>(false);
const { model, handleSubmit, hints } = useForm<IReqUserModifyPassword>(
  {
    oldPassword: "",
    password: "",
    confirmPassword: "",
  },
  {
    rules: {
      oldPassword: [
        { required: true, message: "请输入旧密码" },
        {
          type: "string",
          pattern: /^[a-zA-Z0-9_!@#$%^&*`~()-+=]{6,16}$/,
          message: "密码由6~16个大小写字母、数字、特殊符号组成",
        },
      ],
      password: [
        { required: true, message: "请输入密码" },
        {
          type: "string",
          pattern: /^[a-zA-Z0-9_!@#$%^&*`~()-+=]{6,16}$/,
          message: "密码由6~16个大小写字母、数字、特殊符号组成",
        },
      ],
      confirmPassword: [
        { required: true, message: "请确认密码" },
        {
          validator(_rule, value, callback) {
            if (model.password !== value) {
              callback("两次密码不一致");
            }
            callback();
          },
        },
      ],
    },
    onSubmit: async (data) => {
      data.oldPassword = md5(data.oldPassword);
      data.password = md5(data.password);
      data.confirmPassword = md5(data.confirmPassword);
      await userApi.modifyPassword(data);
      emit("saved");
      emit("update:model-value", false);
    },
  }
);
</script>
