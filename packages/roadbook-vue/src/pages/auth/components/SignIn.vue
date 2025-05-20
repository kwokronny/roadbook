<template>
  <form class="sign-in-form">
    <MazInput
      v-model="model.username"
      left-icon="solar/user"
      block
      color="success"
      label="用户名"
      maxlength="16"
      autocomplete="username"
      v-bind="hints.username"
    >
    </MazInput>
    <MazInput
      v-model="model.password"
      left-icon="key"
      type="password"
      block
      color="success"
      label="密码"
      maxlength="16"
      autocomplete="password"
      v-bind="hints.password"
    >
    </MazInput>
    <MazBtn
      block
      color="success"
      :loading="loading"
      right-icon="arrow-right"
      @click="handleSubmit"
    >
      登录
    </MazBtn>
  </form>
  <div class="spac-mt_s2 flex-h flex-ai_c flex-jc_c">
    未注册账号，<MazBtn color="theme" outline to="/signup">去注册</MazBtn>
  </div>
</template>
<script setup lang="ts">
import md5 from "md5";
import { userApi, IReqUserLogin } from "@/server/user";
import { useForm } from "@/hook/useForm";
import { useRoute, useRouter } from "vue-router";
import { useStore } from "@/store";
import { ruleColl } from "@/helper/rules";

const { setToken, getCurrentInfo } = useStore();
const { query } = useRoute();
const router = useRouter();

const { model, loading, hints, handleSubmit } = useForm<IReqUserLogin>(
  {
    username: "",
    password: "",
  },
  {
    rules: {
      username: [
        { required: true, message: "请输入用户名" },
        ruleColl.username,
      ],
      password: [{ required: true, message: "请输入密码" }, ruleColl.password],
    },
    onSubmit: async (data) => {
      data.password = md5(data.password);
      let res = await userApi.login(data);
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
