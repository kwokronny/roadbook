import AMapLoader from "@amap/amap-jsapi-loader";
// import { trafficType } from "./enum";

export namespace MapUtil {
  export function getAMap(): Promise<any> {
    return new Promise((resolve, reject) => {
      if (!window.AMap) {
        AMapLoader.load({
          key: window.roadbookConfig.aMapKey,
          version: "2.0",
          plugins: [
            // "AMap.Driving",
            // "AMap.Transfer",
            // "AMap.Walking",
            // "AMap.Riding",
            // "AMap.Geocoder",
            // "AMap.Geolocation",
            "AMap.PlaceSearch",
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
