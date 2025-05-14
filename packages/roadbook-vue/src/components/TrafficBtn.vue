<template>
  <Dropdown :items="items" position="bottom" fit>
    <MazBtn color="success" block outline size="sm" left-icon="solar/map" rounded target="_blank" :key="coordinate">
      导航出发
    </MazBtn>
  </Dropdown>
</template>
<script lang="ts" setup>
import { trafficTypeEnum } from "@/helper/enum";
import { Platform, getPlatform } from "@/helper/util";
import Dropdown from "./Dropdown.vue";
interface IProp {
  name: string;
  coordinate: string;
}
const props = defineProps<IProp>();

const platform = getPlatform();
const platformURI: Record<Platform, (mapMode: string) => string> = {
  pc: (mapMode: string) => {
    return `//uri.amap.com/navigation?from=&to=${props.coordinate}&via=&mode=${mapMode}&policy=0&src=roadbook-web&callnative=1`;
  },
  ios: (mapMode: string) => {
    let latlon = props.coordinate.split(",");
    let t = { car: 0, text: 0, walk: 2, ride: 3, bus: 1 }[mapMode] || 0;
    return `iosamap://path?sourceApplication=applicationName&dlat=${latlon[1]}&dlon=${latlon[0]}&dname=${props.name}&dev=0&t=${t}`;
  },
  android: (mapMode: string) => {
    let latlon = props.coordinate.split(",");
    let t = { car: 0, text: 0, bus: 1, walk: 2, ride: 3 }[mapMode] || 0;
    return `amapuri://route/plan/?dlat=${latlon[1]}&dlon=${latlon[0]}&dname=${props.name}&dev=0&t=${t}`;
  },
};

const items = trafficTypeEnum.getArray().map((item) => {
  return {
    label: item.label,
    icon: item.icon,
    class: "text-s_m",
    href: platformURI[platform](item.mapMode),
  };
});
</script>
