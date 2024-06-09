<template>
  <MazBtn
    class="spac-ph_s3"
    left-icon="solar/point"
    size="sm"
    color="info"
    @click="open = true"
  >
    选择坐标
  </MazBtn>
  <MazDrawer
    v-model="open"
    size="768px"
    :variant="width > 768 ? 'right' : 'bottom'"
    title="选择地点"
    backdrop-class="location-selector-drawer"
  >
    <AMapComponent @loaded="handleMapLoaded"></AMapComponent>
    <div class="localtion-selector">
      <div class="text-a_r spac-mb_s2">
        <MazBtn
          left-icon="solar/check"
          :disabled="!center"
          @click="handleConfirm"
        >
          确认选择
        </MazBtn>
      </div>
      <MazCardSpotlight style="width: 100%">
        <div class="spac-p_s3">
          <div class="flex-h gap-s1">
            <MazInput
              class="flex-fill"
              v-model="keyword"
              autocomplete="off"
              placeholder="搜索地点"
              @change="handleSearch()"
            ></MazInput>
            <MazBtn icon="solar/search" @click="handleSearch()" fab></MazBtn>
          </div>
          <MazTransitionExpand>
            <template v-if="options.length">
              <MazCarousel class="spac-mt_s1">
                <MazCard
                  v-for="(item, i) in options"
                  :key="i"
                  @click="handleClick(item)"
                >
                  <template #content>
                    <div class="flex-h flex-ai_c gap-s2">
                      <MazIcon
                        name="island"
                        styel="flex-shrink:0"
                        size="60px"
                      ></MazIcon>
                      <div class="text-o_e flex-fill">
                        <div class="text-c_t text-s_m">{{ item.name }}</div>
                        <div class="text-c_ts text-s_s">
                          {{ item.district }}
                        </div>
                      </div>
                    </div>
                  </template>
                </MazCard>
              </MazCarousel>
            </template>
          </MazTransitionExpand>
        </div>
      </MazCardSpotlight>
    </div>
  </MazDrawer>
</template>
<script setup lang="ts">
import { ref, watch } from "vue";
import AMapComponent from "./AMapContainer.vue";
import { useWindowSize } from "maz-ui";
import { MapUtil } from "@/helper/amap";
import { throttle } from "@/helper/util";

const { width } = useWindowSize();

const props = defineProps<{
  center?: string;
}>();

const emit = defineEmits<{
  (
    e: "select",
    arg: {
      lnglat: AMap.LocationValue | null;
      POI: AMap.Autocomplete.Tip | null;
    }
  ): void;
}>();

const open = ref(false);
const POI = ref<AMap.Autocomplete.Tip | null>(null);
const center = ref<AMap.LocationValue | null>(null);
const marker = ref<AMap.Marker>();

watch(
  () => open.value,
  () => {
    if (open.value && props.center) {
      let lnglat = MapUtil.stringToLngLat(props.center);
      if (lnglat) {
        center.value = lnglat;
        handleCenterChange();
      }
    }
  }
);

watch(
  () => center.value,
  () => handleCenterChange()
);

const keyword = ref("");
const options = ref<AMap.Autocomplete.Tip[]>([]);
const handleSearch = throttle(async () => {
  const res = await MapUtil.searchPleace(keyword.value);
  if (res) {
    options.value = res.tips;
  }
}, 500);

function handleClick(item: AMap.Autocomplete.Tip) {
  center.value = item.location;
  POI.value = item;
}

function handleConfirm() {
  emit("select", { lnglat: center.value, POI: POI.value });
  open.value = false;
}

let mapInstance: AMap.Map | null = null;

function handleMapLoaded(map: AMap.Map) {
  mapInstance = map;
  handleCenterChange();
  mapInstance.on("click", function (e) {
    POI.value = null;
    center.value = e.lnglat;
  });
}

function handleCenterChange() {
  if (mapInstance && center.value) {
    mapInstance.clearMap();
    let instance = new AMap.Marker({
      icon: "/icons/marker.svg",
      anchor: "center",
      position: center.value,
    });
    mapInstance.add(instance);
    marker.value = instance;
    mapInstance.setCenter(center.value);
  }
}
</script>
<style lang="stylus" scoped>
.location-selector-drawer{
  .m-drawer-body{
    position relative
  }
}
.localtion-selector{
  l-abs 5% 20px 'lb';
  l-wh 90% auto;
}
</style>
