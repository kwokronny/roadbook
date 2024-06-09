<template>
  <form class="sign-up-form" @keyup.enter="handleSubmit">
    <MazInput
      v-model="model.username"
      left-icon="user"
      label="用户名"
      maxlength="16"
      v-bind="hints.username"
    ></MazInput>
    <MazInput
      v-model="model.password"
      left-icon="key"
      type="password"
      label="密码"
      maxlength="16"
      v-bind="hints.password"
    ></MazInput>
    <MazInput
      v-model="model.confirmPassword"
      left-icon="key"
      type="password"
      label="确认密码"
      maxlength="16"
      v-bind="hints.confirmPassword"
    >
    </MazInput>
    <MazBtn
      block
      :loading="loading"
      right-icon="arrow-right"
      @click="handleSubmit"
    >
      注册
    </MazBtn>
  </form>
  <div class="spac-mt_s2">
    已有账号，<MazBtn color="theme" outline to="/signin">去登录</MazBtn>
  </div>
</template>
<script setup lang="ts">
import { userApi, IReqUserRegister } from "@/server/user";
import { useForm } from "@/hook/useForm";
import md5 from "md5";
import { useRoute, useRouter } from "vue-router";
import { useStore } from "@/store";
import { ruleColl } from "@/helper/rules";

const router = useRouter();
const { query } = useRoute();
const { setToken, getCurrentInfo } = useStore();

const { model, loading, hints, handleSubmit } = useForm<IReqUserRegister>(
  {
    username: "",
    password: "",
    confirmPassword: "",
  },
  {
    rules: {
      username: [
        { required: true, message: "请输入用户名" },
        ruleColl.username,
      ],
      password: [{ required: true, message: "请输入密码" }, ruleColl.password],
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
      data.password = md5(data.password);
      data.confirmPassword = md5(data.confirmPassword);
      const res = await userApi.register(data);
      setToken(res.data.token);
      getCurrentInfo();

      router.push(
        query.inviteToken
          ? `/accept?inviteToken=${query.inviteToken}`
          : "/travel"
      );
    },
  }
);
</script>
