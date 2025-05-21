<template>
  <MazDialog
    :model-value="props.modelValue"
    @update:model-value="handleClose"
    backdrop-class="equip-drawer"
    scrollable
  >
    <template #title>
      <div class="flex-h gap-s1">
        <MazIcon name="solar/bag" size="24px"></MazIcon>
        <div>行李清点</div>
      </div>
    </template>
    <div class="equip-list flex-v gap-s3">
      <MazCard
        v-if="props.canEdit"
        size="sm"
        collapsable
        style="width: 100%; z-index: 3"
      >
        <template #header>
          <div class="text-c_t">重置行李清单模板</div>
        </template>
        <div class="flex-h gap-s1 spac-p_s3">
          <MazSelect
            class="flex-fill"
            color="success"
            v-model="initEquip.equip"
            label="行李清单模板"
            :options="equipOptions"
          />
          <MazBtn color="success" class="flex-shrink" @click="handlePull()">重置</MazBtn>
        </div>
      </MazCard>
      <div class="flex-h flex-ai_c flex-jc_sb spac-ph_s2">
        <div class="text-c_ts text-s_s flex-fill">
          勾选不储存，仅用于现场确认物品是否准备
        </div>
        <div v-if="canEdit" class="flex-h gap-s1 flex-shrink">
          <MazBtn
            size="sm"
            pastel
            color="transparent"
            @click="canEdit = false"
          >
            取消
          </MazBtn>
          <MazBtn
            size="sm"
            @click="setEquip"
            color="success"
          >
            保存
          </MazBtn>
        </div>
        <MazBtn
          v-else-if="props.canEdit"
          size="sm"
          @click="canEdit = true"
          color="success"
        >
          编辑
        </MazBtn>
      </div>
      <template v-if="equip">
        <MazCard
          v-for="(group, gidx) in equip"
          size="sm"
          collapsable
          collapse-open
          style="width: 100%"
        >
          <template #header>
            <div v-if="isEdit(gidx, -2)">
              <MazInput
                block
                color="success"
                size="sm"
                auto-focus
                placeholder="请输入分组名称"
                v-model="currEdit.name"
                maxlength="50"
                @blur="handleSave"
                @keyup.enter="handleSave"
              ></MazInput>
            </div>
            <h3
              v-else
              class="spac-mv_0 spac-ph_s1 flex-h text-c_t flex-jc_sb flex-ai_c flex-fill gap-s2"
            >
              {{ group.name }}
              <div class="flex-h flex-ai_c gap-s2" v-if="isShowOption">
                <MazIcon
                  name="solar/edit"
                  size="20px"
                  @click="handleEdit(gidx)"
                ></MazIcon>
                <MazIcon
                  name="solar/close"
                  class="text-c_danger"
                  size="20px"
                  @click="handleRemove(gidx)"
                ></MazIcon>
              </div>
            </h3>
          </template>
          <template #content>
            <div class="flex-v gap-s3 spac-p_s3">
              <div class="flex" v-for="(item, idx) in group.list">
                <MazInput
                  v-if="isEdit(gidx, idx)"
                  block
                  size="sm"
                  auto-focus
                  color="success"
                  placeholder="请输入物品名称"
                  v-model="currEdit.name"
                  maxlength="50"
                  @blur="handleSave"
                  @keyup.enter="handleSave"
                ></MazInput>
                <MazCheckbox v-else class="flex-fill" color="success">
                  <div class="flex-h flex-jc_sb flex-ai_c flex-fill gap-s2">
                    <span>{{ item }}</span>
                    <div class="flex-h flex-ai_c gap-s2" v-if="isShowOption">
                      <MazIcon
                        name="solar/edit"
                        size="20px"
                        @click="handleEdit(gidx, idx)"
                      ></MazIcon>
                      <MazIcon
                        name="solar/close"
                        class="text-c_danger"
                        size="20px"
                        @click="handleRemove(gidx, idx)"
                      >
                      </MazIcon>
                    </div>
                  </div>
                </MazCheckbox>
              </div>
              <MazInput
                v-if="isEdit(gidx, -1)"
                block
                color="success"
                size="sm"
                placeholder="请输入物品名称"
                auto-focus
                v-model="currEdit.name"
                maxlength="50"
                @blur="handleSave"
                @keyup.enter="handleSave"
              ></MazInput>
              <div
                v-else-if="isShowOption"
                class="line-a_da1 radius-l spac-p_s1 cursor-pointer text-a_c"
                @click="handleEdit(gidx, -1)"
              >
                添加物品
              </div>
            </div>
          </template>
        </MazCard>
        <MazInput
          v-if="isEdit(-1, -2)"
          block
          size="sm"
          auto-focus
          color="success"
          placeholder="请输入分组名称"
          v-model="currEdit.name"
          maxlength="50"
          @blur="handleSave"
          @keyup.enter="handleSave"
        ></MazInput>
        <div
          v-else-if="isShowOption"
          class="line-a_da1 radius-l spac-p_s1 cursor-pointer text-a_c"
          @click="handleEdit(-1, -2)"
        >
          添加分组
        </div>
      </template>
    </div>
  </MazDialog>
</template>
<script setup lang="ts">
import { useToast } from "maz-ui";
import { type IEquip, equipApi } from "@/server/equip";
import { ref, reactive, computed, watch, onMounted } from "vue";
import { travelApi } from "@/server/travel";
import { type MazSelectOption } from "maz-ui/components/MazSelect";

interface IProp {
  modelValue: boolean;
  id: number;
  canEdit?: boolean;
  data: string;
}
const props = defineProps<IProp>();
const emit = defineEmits<{
  (e: "update:model-value", value: boolean): void;
  (e: "close"): void;
}>();

onMounted(() => {
  getEquipList();
});

function handleClose(value: boolean) {
  emit("update:model-value", value);
  if (value === false) {
    emit("close");
  }
}

const equip = ref<IEquip[]>([]);

//#region 清单编辑
const canEdit = ref(false);

const isShowOption = computed(() => {
  return props.canEdit && canEdit.value;
});

const currEdit = reactive({
  idx: [-2, -2], // -2：read, -1: edit,
  name: "",
});

function isEdit(gidx: number, idx: number) {
  return currEdit.idx[0] === gidx && currEdit.idx[1] === idx;
}

function handleEdit(gidx?: number, idx?: number) {
  if (!props.data) return;
  if (gidx !== undefined) {
    currEdit.idx[0] = gidx;
    if (idx !== undefined) {
      // 编辑 或 添加物品
      currEdit.idx[1] = idx;
      currEdit.name = idx === -2 ? "" : equip.value[gidx].list[idx];
    } else {
      // 编辑 或 添加组
      currEdit.idx[1] = -2;
      currEdit.name = gidx === -1 ? "" : equip.value[gidx].name;
    }
  } else {
    currEdit.idx = [-2, -2];
  }
}

function handleSave() {
  if (!equip.value) return;
  if (currEdit.name.length > 50) {
    toast.warning("长度不可超过50个字符");
    return;
  }
  if (currEdit.idx[0] > -2 && currEdit.name !== "") {
    if (currEdit.idx[1] > -2) {
      // 编辑 或 添加组
      if (currEdit.idx[1] === -1) {
        equip.value[currEdit.idx[0]].list.push(currEdit.name);
      } else {
        equip.value[currEdit.idx[0]].list[currEdit.idx[1]] = currEdit.name;
      }
    } else {
      // 编辑 或 添加组
      if (currEdit.idx[0] === -1) {
        equip.value.push({ name: currEdit.name, list: [] });
      } else {
        equip.value[currEdit.idx[0]].name = currEdit.name;
      }
    }
  }
  currEdit.name = "";
  handleEdit();
  // setEquip(equip.value);
}

function handleRemove(gidx: number, idx?: number) {
  if (equip.value) {
    if (gidx >= 0 && equip.value[gidx]) {
      if (typeof idx === "number" && idx >= 0) {
        equip.value[gidx].list.splice(idx, 1);
      } else {
        equip.value.splice(gidx, 1);
      }
    }
  }
}

const toast = useToast();
async function setEquip() {
  try {
    if (props.id && equip.value) {
      const equipStr = JSON.stringify(equip.value);
      await travelApi.setEquip({
        id: props.id,
        equip: equipStr,
      });
      toast.success("保存成功");
      canEdit.value = false;
    }
  } catch {}
}

//#endregion

watch(
  () => props.data,
  () => {
    try {
      let data = JSON.parse(props.data);
      if (typeof data === "string") {
        data = [];
      }
      equip.value = data;
    } catch {
      equip.value = [];
    }
  },
  { immediate: true }
);

const initEquip = reactive<{
  show: boolean;
  equip: string;
}>({ show: false, equip: "" });
let equipOptions = ref<MazSelectOption[]>([]);

async function getEquipList() {
  try {
    let res = await equipApi.list();
    res.forEach((item) => {
      try {
        equipOptions.value.push({
          label: item.name,
          value: JSON.stringify(item.list),
        });
      } catch {}
    });
  } catch {}
}

function handlePull() {
  if (initEquip.equip) {
    equip.value = JSON.parse(initEquip.equip);
    setEquip();
  }
}
</script>

<style lang="stylus">
.equip-drawer .m-drawer-content-wrap{
  height: 100%;
}
</style>
