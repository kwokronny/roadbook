<template>
  <div
    class="uploader-dropzone text-c_ts text-s_m"
    @click="handleClick"
    @dragover="handleDropOver"
    @drop="handleDrop"
  >
    <MazIcon name="solar/upload" size="40px"></MazIcon>
    <div>{{ props.tip }}</div>
    <input
      ref="FileRef"
      type="file"
      accept="image/*"
      multiple
      @change="handleFileChange"
    />
  </div>
</template>
<script setup lang="ts">
import { ref } from "vue";
import Compressor from "compressorjs";
import { commonApi } from "@/server/common";

interface IProp {
  tip: string;
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

function handleDropOver(e: DragEvent) {
  e.preventDefault();
}

function handleDrop(e: DragEvent) {
  e.preventDefault();
  const files = e.dataTransfer?.files;
  if (files?.length) {
    handleUpload(files);
  }
}

function handleFileChange(e: Event) {
  const files = (e.target as HTMLInputElement)?.files;
  if (files?.length) {
    handleUpload(files);
  }
}
</script>
<style lang="stylus">
.uploader-dropzone{
  l-flex: v c c;
  border: yoz_line.da1;
  border-radius: yoz_radius.b;
  padding: yoz_spacing.m1 yoz_spacing.s3
  gap: yoz_spacing.s2;
  text-align: center;
  cursor pointer;
  input{
    display: none;
  }
}
</style>
