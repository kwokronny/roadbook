<template>
  <div class="upload" @click="handleClick">
    <slot></slot>
    <input
      ref="FileRef"
      type="file"
      accept="image/*"
      :multiple="props.multiple"
      @change="handleFileChange"
    />
  </div>
</template>
<script setup lang="ts">
import { ref } from "vue";
import Compressor from "compressorjs";
import { commonApi } from "@/server/common";

interface IProp {
  multiple?: boolean;
}
const props = defineProps<IProp>();

const emit = defineEmits<{
  (e: "success", res: any): void;
}>();

const FileRef = ref<HTMLInputElement>();

function handleClick() {
  if (FileRef.value) {
    FileRef.value.click();
  }
}

function handleUpload(files: FileList) {
  const compArr: Promise<File>[] = [];
  Array.from(files).forEach((file: File) => {
    if (file.type.includes("image/")) {
      compArr.push(
        new Promise((resolve) => {
          new Compressor(file, {
            maxWidth: 600,
            convertTypes: "image/webp",
            success(result: File) {
              resolve(result);
            },
          });
        })
      );
    }
  });

  Promise.allSettled(compArr).then(async (results) => {
    const data = new FormData();
    results.forEach((res) => {
      res.status === "fulfilled" && data.append("file", res.value);
    });
    try {
      const res = await commonApi.upload(data);
      emit("success", res.data);
    } catch (e) {
      console.error(e);
    }
  });
}

function handleFileChange(e: Event) {
  const files = (e.target as HTMLInputElement)?.files;
  if (files?.length) {
    handleUpload(files);
  }
}
</script>
<style lang="stylus">
.upload{
  display: inline-block;
  cursor pointer
  input {
    display:none;
  }
}
</style>
