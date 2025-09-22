import AMapLoader from "@amap/amap-jsapi-loader";
// import { trafficType } from "./enum";

export namespace MapUtil {
  export function getAMap(): Promise<any> {
    return new Promise((resolve, reject) => {
      if (!window.AMap) {
        AMapLoader.load({
          key: window.AMapKey || import.meta.env.VITE_AMAP_KEY,
          version: "2.0",
          plugins: [
            // "AMap.Driving",
            // "AMap.Transfer",
            // "AMap.Walking",
            // "AMap.Riding",
            // "AMap.Geocoder",
            // "AMap.Geolocation",
            "AMap.PlaceSearch",
            "AMap.ElasticMarker",
          ],
        })
          .then((AMap) => {
            resolve(AMap);
          })
          .catch(reject);
      } else {
        resolve(window.AMap);
      }
    });
  }

  // export function getGeoLocation(): Promise<AMap.LngLat> {
  //   return new Promise(async (resolve, reject) => {
  //     await getAMap();
  //     const instance = new AMap.Geolocation({});
  //     instance.getCurrentPosition((status, result) => {
  //       if (status === "complete") {
  //         resolve((result as AMap.Geolocation.GeolocationResult).position);
  //       } else {
  //         reject();
  //       }
  //     });
  //   });
  // }

  export function stringToLngLat(str: string): [number, number] | null {
    let lnglat: number[] = str.split(",")?.map((i) => parseFloat(i));
    if (lnglat?.length === 2) {
      return lnglat as [number, number];
    } else {
      return null;
    }
  }

  // export function getAddress(
  //   coordinate: AMap.LocationValue
  // ): Promise<AMap.Geocoder.ReGeocodeResult> {
  //   return new Promise(async (resolve, reject) => {
  //     await getAMap();
  //     const geocoder = new AMap.Geocoder({});
  //     geocoder.getAddress(coordinate, (status: string, result) => {
  //       if (status === "complete" && typeof result !== "string") {
  //         resolve(result);
  //       } else {
  //         console.error("根据经纬度查询地址失败");
  //         reject();
  //       }
  //     });
  //   });
  // }

  export function searchPleace(
    keyword: string,
    options: AMap.PlaceSearch.Options = {}
  ): Promise<AMap.PlaceSearch.SearchResult | void> {
    return new Promise(async (resolve, reject) => {
      await getAMap();
      const placeSearch = new AMap.PlaceSearch(options);
      placeSearch.search(keyword, (status, result) => {
        if (status === "complete" && typeof result !== "string") {
          resolve(result);
        } else {
          reject();
        }
      });
    });
  }

  export function LngLat(coordinate: string) {
    let pos = coordinate.split(",").map((i: string) => parseFloat(i));
    return new AMap.LngLat(pos[0], pos[1]);
  }
  export type MarkerType = "hotel" | "schedule" | "poi" | "todo";

  export function createElasticMarker(options: {
    position: AMap.LngLat;
    type: MarkerType;
    idx?: string;
    day?: string;
    label: string;
    click?: () => void;
  }) {
    const dayColor = [
      "#1f8fff",
      "#5425c6",
      "#c625c2",
      "#c6255a",
      "#348e0e",
      "#1599a6",
    ];
    let icon = "";
    if (options.type === "hotel") {
      icon = createScheduleMarkerIcon("H", "#544380");
    } else if (options.type === "schedule") {
      icon = createScheduleMarkerIcon(
        options.idx || "",
        options.day ? dayColor[parseInt(options.day)] : "#1f8fff",
        options.day ? `D${options.day}` : ""
      );
    } else if (options.type === "todo") {
      icon = createScheduleMarkerIcon("?", "#c38a1b");
    } else if (options.type === "poi") {
      icon = createScheduleMarkerIcon("+1", "#658722");
    }
    const styles = [
      {
        icon: {
          img: icon,
          size: [20, 20],
          anchor: "bottom-center",
          scaleFactor: 0.5,
          minScale: 2,
          maxScale: 4,
        },
      },
      {
        icon: {
          img: icon,
          size: [20, 20],
          anchor: "bottom-center",
          scaleFactor: 0.5,
          minScale: 2,
          maxScale: 4,
        },
        label: {
          position: "BM",
          content: options.label,
        },
      },
    ];
    let zoomStyleMapping: Record<number, number> = {};
    for (let i = 2; i < 26; i++) {
      zoomStyleMapping[i] = i > 15 ? 1 : 0;
    }
    const marker = new AMap.ElasticMarker({
      position: options.position,
      styles,
      zoomStyleMapping,
    });
    options.click && marker.on("click", options.click);
    return marker;
  }
  // export function planningRoute(
  //   map: AMap.Map,
  //   traffic: trafficType,
  //   startLngLat: AMap.LngLat,
  //   endLngLat: AMap.LngLat
  // ) {
  //   if (traffic === "bus") {
  //     getAddress(startLngLat).then((res) => {
  //       const transfer = new AMap.Transfer({
  //         policy: AMap.TransferPolicy.LEAST_TIME,
  //         hideMarkers: true,
  //         city: res.regeocode.addressComponent.citycode,
  //       });
  //       transfer.search(startLngLat, endLngLat, function (status, result: any) {
  //         if (status === "complete") {
  //           if (result.plans && result.plans.length) {
  //             drawRoute(map, result.plans[0].path, "#17a2b8");
  //           }
  //         }
  //       });
  //     });
  //   } else if (traffic === "walk") {
  //     const transfer = new AMap.Walking({
  //       hideMarkers: true,
  //     });
  //     transfer.search(startLngLat, endLngLat, function (status, result: any) {
  //       if (status === "complete") {
  //         if (result.routes && result.routes.length) {
  //           var path = parseRouteToPath(result.routes[0]);
  //           drawRoute(map, path, "#fcb731");
  //         }
  //       }
  //     });
  //   } else if (traffic === "ride") {
  //     const transfer = new AMap.Riding({
  //       hideMarkers: true,
  //     });
  //     transfer.search(startLngLat, endLngLat, function (status, result: any) {
  //       if (status === "complete") {
  //         if (result.routes && result.routes.length) {
  //           var path = parseRouteToPath(result.routes[0]);
  //           drawRoute(map, path, "#fcb731");
  //         }
  //       }
  //     });
  //   } else if (traffic === "car" || traffic === "taxi") {
  //     const transfer = new AMap.Driving({
  //       policy: AMap.DrivingPolicy.LEAST_TIME,
  //       hideMarkers: true,
  //       showTraffic: false,
  //     });
  //     transfer.search(startLngLat, endLngLat, function (status, result: any) {
  //       if (status === "complete") {
  //         if (result.routes && result.routes.length) {
  //           var path = parseRouteToPath(result.routes[0]);
  //           drawRoute(map, path, "#1e90ff");
  //         }
  //       }
  //     });
  //   } else {
  //     var routeLine = new AMap.Polyline({
  //       path: [startLngLat, endLngLat],
  //       isOutline: true,
  //       outlineColor: "#ffeeee",
  //       borderWeight: 2,
  //       strokeWeight: 6,
  //       strokeOpacity: 0.9,
  //       // strokeStyle: "dashed",
  //       strokeColor: "#fcb731",
  //       lineJoin: "round",
  //       showDir: true,
  //     });
  //     map.add(routeLine);
  //   }
  // }

  // function drawRoute(map: AMap.Map, path: AMap.LngLat[], color: string) {
  //   var routeLine = new AMap.Polyline({
  //     path: path,
  //     isOutline: true,
  //     outlineColor: "#ffeeee",
  //     borderWeight: 2,
  //     strokeWeight: 6,
  //     showDir: true,
  //     strokeOpacity: 0.9,
  //     strokeColor: color,
  //     lineJoin: "round",
  //   });

  //   map.add(routeLine);

  //   // 调整视野达到最佳显示区域
  //   // map.setFitView([startMarker, endMarker, routeLine]);
  // }

  //   function parseRouteToPath(route: any): AMap.LngLat[] {
  //     var path: AMap.LngLat[] = [];
  //     route.steps?.forEach((step: any) =>
  //       step?.path?.forEach((p: AMap.LngLat) => path.push(p))
  //     );
  //     return path;
  //   }
}

//用canvas生成一个图标：传入一个文本，生成一个圆形，圆形内显示文本
export function createScheduleMarkerIcon(
  text: string,
  bgColor: string = "#1f8fff",
  badge: string = ""
) {
  // 生成base64的svg图片
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 28">
<path fill="${bgColor}" fill-rule="evenodd" d="m12,7.00952a9,9 0 0 1 9,9c0,3.074 -1.676,5.59 -3.442,7.395a20.4,20.4 0 0 1 -2.876,2.416l-0.426,0.29l-0.2,0.133l-0.377,0.24l-0.336,0.205l-0.416,0.242a1.88,1.88 0 0 1 -1.854,0l-0.416,-0.242l-0.52,-0.32l-0.192,-0.125l-0.41,-0.273a20.7,20.7 0 0 1 -3.093,-2.566c-1.766,-1.807 -3.442,-4.321 -3.442,-7.395a9,9 0 0 1 9,-9" class="duoicon-secondary-layer" opacity="0.9"/>
${
  badge
    ? `<rect fill="#f00" x="13" y="3" width="11" height="7" rx="2"/>
<text fill="#fff" x="22.5" text-anchor="end" y="8.5" font-size="6" font-family="Comic Sans MS">${badge}</text>`
    : ""
}
<text fill="#fff" x="12" text-anchor="middle" y="20" font-size="10" font-family="Comic Sans MS">${text}</text>
</svg>`;
  const base64 = btoa(svg);
  return `data:image/svg+xml;base64,${base64}`;
}
