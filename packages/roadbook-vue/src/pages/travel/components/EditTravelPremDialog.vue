<template>
  <MazDialog
    :model-value="props.modelValue"
    @update:model-value="emit('update:model-value', $event)"
  >
    <template #title>
      <div class="spac-pv_s2 flex-h flex-ai_c">
        <MazIcon name="solar/perm" size="24px" class="spac-mr_s1"></MazIcon>
        权限设置
      </div>
    </template>
    <div class="flex-v gap-s2" style="min-height: 300px">
      <MazInput
        left-icon="solar/share"
        label="邀请链接"
        block
        :model-value="url"
        readonly
      >
        <template #right-icon>
          <MazIcon name="solar/copy" size="20px" @click="handleCopy"></MazIcon>
        </template>
      </MazInput>
      <div
        v-for="user in detail?.Users"
        :key="`user_${user.id}`"
        class="flex-h gap-s2 flex-ai_c flex-jc_sb spac-ph_s2"
      >
        <div class="flex-h gap-s1 flex-ai_c flex-fill" style="width: 0">
          <MazAvatar
            :src="user.avatar"
            fallback-src="/logo.png"
            :caption="user.name || user.username"
            size="0.8rem"
          ></MazAvatar>
          <div class="text-c_t text-s_l text-o_e flex-fill" style="width: 0">
            {{ user.name || user.username }}
          </div>
        </div>
        <div class="shrink-0" v-if="userInfo?.id === user.id">
          {{ roleTypeEnum.get(user.UserTravel.role).label }}
        </div>
        <MazSelect
          v-else
          :model-value="user.UserTravel.role"
          @update:model-value="(val) => handleSetRole(user, val as roleType)"
          :options="roleTypeEnum.getArray()"
          style="width: 120px"
          color="info"
          :item-height="40"
          size="sm"
        >
        </MazSelect>
      </div>
    </div>
  </MazDialog>
</template>
<script setup lang="ts">
import { roleType, roleTypeEnum } from "@/helper/enum";
import { copy } from "@/helper/util";
import { ITravel, travelApi } from "@/server/travel";
import { IUser } from "@/server/user";
import { useStore } from "@/store";
import { useToast } from "maz-ui";
import { ref, watch, toRefs } from "vue";

interface IProp {
  modelValue: boolean;
  detail?: Required<ITravel>;
}
const props = defineProps<IProp>();

const { detail } = toRefs(props);

const emit = defineEmits<{
  (e: "update:model-value", value: boolean): void;
  (e: "saved"): void;
}>();
const toast = useToast();
const { userInfo } = useStore();
const url = ref("");

watch(
  () => props.modelValue,
  async (val) => {
    if (val && detail.value) {
      const res = await travelApi.invite(detail.value.id);
      url.value = `${window.location.href.replace(
        /travel\/(\d+)$/,
        "accept"
      )}?inviteToken=${res.data}`;
    }
  }
);

async function handleCopy() {
  copy(url.value)
    .then(() => toast.success("复制成功"))
    .catch(() => toast.error("复制失败，请手动复制"));
}

async function handleSetRole(
  user: Required<IUser & { UserTravel: { role: roleType } }>,
  perm: roleType
) {
  try {
    if (detail.value?.id && user) {
      await travelApi.setRole({
        id: detail.value.id,
        uid: user.id,
        role: perm,
      });
      toast.success("设置成功");
      user.UserTravel.role = perm;
      emit("saved");
    }
  } catch (e) {
    console.error(e);
  }
}
</script>
