<template>
  <div class="travel-item">
    <div class="flex-fill spac-p_s2 flex-v flex-jc_sb">
      <div class="flex-h gap-s1">
        <SketchItem type="circle" size="24px"></SketchItem>
        <div class="flex-fill">
          <SketchItem type="hn" size="80%"></SketchItem>
          <SketchItem type="text" size="40%"></SketchItem>
        </div>
      </div>
      <div class="user flex-h flex-ai_c">
        <SketchItem class="m-avatar" type="circle" size="24px"></SketchItem>
        <SketchItem class="m-avatar" type="circle" size="24px"></SketchItem>
        <SketchItem class="m-avatar" type="circle" size="24px"></SketchItem>
      </div>
    </div>
    <div class="stub spac-p_s2 flex-v flex-jc_sb text-a_r">
      <div class="text-c_ts text-s_s">
        <SketchItem type="circle" size="16px"></SketchItem>
        <div>
          <SketchItem type="text" size="80%"></SketchItem>
        </div>
      </div>
      <div class="text-c_ts text-s_s">
        <SketchItem type="text" size="60%"></SketchItem>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts"></script>
<style lang="stylus" scoped>
.travel-item{
  display: flex;
  flex-direction: row;
  height: 130px;
  border: 1px solid var(--maz-color-border);
  border-radius: var(--maz-border-radius);
  overflow: hidden;
  .stub{
    flex-shrink: 0;
    width: 120px;
    background-color: var(--stub-bg);
    border-left: 1px dashed var(--maz-color-border);
  }
  .user {
    .m-avatar + .m-avatar{
      margin-inline-start: -0.4rem;
    }
  }
}
</style>
