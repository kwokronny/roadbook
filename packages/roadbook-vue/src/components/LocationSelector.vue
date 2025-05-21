<template>
  <MazDrawer
    v-model="props.modelValue"
    size="768px"
    :variant="width > 768 ? 'right' : 'bottom'"
    title="添加地点"
    backdrop-class="location-selector-drawer"
  >
    <div class="abs-lt-0_0 flex-h gap-s1">
      <MazInput
        class="flex-fill"
        v-model="keyword"
        autocomplete="off"
        placeholder="搜索地点"
        @keyup.enter="handleSearch()"
      />
      <MazBtn icon="solar/search" @click="handleSearch()" fab />
    </div>
    <AMapComponent @loaded="handleMapLoaded"></AMapComponent>
    <!-- <div class="localtion-selector">
      <MazCardSpotlight style="width: 100%">
        <div class="spac-p_s3">
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
    </div> -->
  </MazDrawer>
</template>
<script setup lang="ts">
import { ref, watch } from "vue";
import AMapComponent from "./AMapContainer.vue";
import { useWindowSize } from "maz-ui";
import { MapUtil } from "@/helper/amap";
import { throttle } from "@/helper/util";

const props = defineProps<{
  modelValue: boolean;
  
}>();

const { width } = useWindowSize();

const emit = defineEmits<{
  (e: "update:modelValue", arg: boolean): void;
}>();

const selectedPOI = ref<AMap.PlaceSearch.Poi[]>([]);
const markers = ref<AMap.Marker[]>([]);

const keyword = ref("");
const options = ref<AMap.PlaceSearch.Poi[]>([]);
const handleSearch = throttle(async () => {
  const res = await MapUtil.searchPleace(keyword.value);
  if (res) {
    options.value = res.poiList.pois;
    options.value.forEach((item) => renderMarker(item));
  }
}, 500);

// function handleClick(item: AMap.Autocomplete.Tip) {
//   center.value = item.location;
//   POI.value = item;
// }

// function handleConfirm() {
//   emit("select", { lnglat: center.value, POI: POI.value });
//   open.value = false;
// }

let mapInstance: AMap.Map | null = null;

function handleMapLoaded(map: AMap.Map) {
  mapInstance = map;
  // handleCenterChange();
  // mapInstance.on("click", function (e) {
  //   POI.value = null;
  //   center.value = e.lnglat;
  // });
}

function renderMarker(poi: AMap.PlaceSearch.Poi) {
  if (!mapInstance || !poi.location) return;
  const marker = new AMap.Marker({
    icon: "/icons/marker.svg",
    position: poi.location,
    anchor: "bottom-left",
    label: {
      offset: new AMap.Pixel(5, 0),
      content: `${poi.name}`,
    },
  });
  markers.value.push(marker);
  mapInstance.add(marker);
}

// function removeSearchMarker() {
//   if (mapInstance && center.value) {
//     mapInstance.clearMap();
//     let instance = new AMap.Marker({
//       icon: "/icons/marker.svg",
//       anchor: "center",
//       position: center.value,
//     });
//     mapInstance.add(instance);
//     marker.value = instance;
//     mapInstance.setCenter(center.value);
//   }
// }
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
