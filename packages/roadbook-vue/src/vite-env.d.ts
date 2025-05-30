/// <reference types="vite/client" />
/// <reference types="amap-js-api" />
/// <reference types="amap-js-api-place-search" />

declare module "md5";
declare module "compressorjs";

declare namespace AMap {
  class AutoComplete extends Autocomplete {}
  namespace Walking {
    interface EventMap {
      complete: Event<"complete", SearchResult>;
      error: Event<"error", { info: string }>;
    }
    interface Options {
      /**
       * AMap.Map对象, 展现结果的地图实例。
       * 当指定此参数后，搜索结果的标注、线路等均会自动添加到此地图上
       */
      map?: Map | undefined;
      /**
       * 结果列表的HTML容器id或容器元素，提供此参数后，结果列表将在此容器中进行展示
       */
      panel?: string | HTMLElement | undefined;
      /**
       * 设置隐藏路径规划的起始点图标，设置为true：隐藏图标；设置false：显示图标 默认值为：false
       */
      hideMarkers?: boolean | undefined;
      /**
       * 使用map属性时，绘制的规划线路是否显示描边，默认为true
       */
      isOutline?: boolean | undefined;
      /**
       * 使用map属性时，绘制的规划线路是否显示描边，默认为"white"
       */
      outlineColor?: string | undefined;
      /**
       * 用于控制在路径规划结束后，是否自动调整地图视野使绘制的路线处于视口的可见范围
       */
      autoFitView?: boolean | undefined;
      // internal

      showDir?: boolean | undefined;
    }
    interface SearchPoint {
      // 地点名称
      keyword: string;
    }
    interface WalkStep {
      /**
       * 步行子路段描述,规则：沿 road步行 distance 米 action，例：”沿北京站街步行351米”
       */
      instruction: string;
      /**
       * 道路
       */
      road: string;
      /**
       * 步行方向
       */
      orientation: string;
      /**
       * 	步行子路段距离，单位：米
       */
      distance: number;
      /**
       * 步行子路段预计使用时间，单位：秒
       */
      time: number;
      /**
       * 步行子路段坐标集合
       */
      path: LngLat[];
      /**
       * 本步行子路段完成后动作
       */
      action: string;
      /**
       * @deprecated
       * 本步行子路段完成后辅助动作，一般为到达某个目的地时返回
       * 文档中有此字段但是实际代码中并没有返回
       */
      assist_action?: string | undefined;
    }
    interface WalkRoute {
      /**
       * 起点到终点总步行距离，单位：米
       */
      distance: number;
      /**
       * 步行时间预计，单位：秒
       */
      time: number;
      /**
       * 路段列表，以道路名称作为分段依据，将整个步行导航方案分隔成若干路段
       */
      steps: RideStep[];
    }
    interface SearchResultCommon {
      /**
       * 成功状态说明
       */
      info: string;
      /**
       * 步行规划起点坐标
       */
      origin: LngLat;
      /**
       * 步行规划终点坐标
       */
      destination: LngLat;
      /**
       * 步行导航路段数目
       */
      count: number;
      /**
       * 步行规划路线列表
       */
      routes: WalkRoute[];
    }
    interface Poi {
      /**
       * 坐标
       */
      location: LngLat;
      /**
       * 名称
       */
      name: string;
      /**
       * 类型
       */
      type: "start" | "end";
    }
    interface SearchResultBase extends SearchResultCommon {
      /**
       * 步行导航起点
       */
      start?: Poi | undefined;
      /**
       * 步行导航终点
       */
      end?: Poi | undefined;
    }
    interface SearchResultExt extends SearchResultCommon {
      /**
       * 步行导航起点
       */
      start: PlaceSearch.PoiExt;
      /**
       * 步行导航终点
       */
      end: PlaceSearch.PoiExt;
      /**
       * 步行导航起点名称
       */
      originName: string;
      /**
       * 步行导航终点名称
       */
      destinationName: string;
    }
    type SearchResult = SearchResultBase | SearchResultExt;
    type SearchStatus = "complete" | "error" | "no_data";
  }

  class Walking extends EventEmitter {
    constructor(options?: Walking.Options);
    /**
     * 根据起点和终点坐标，实现步行路径规划
     * @param origin 起点坐标
     * @param destination 终点坐标
     * @param callback 查询回调
     */
    search(
      origin: LocationValue,
      destination: LocationValue,
      callback?: (
        status: Walking.SearchStatus,
        result: Walking.SearchResultBase | string
      ) => void
    ): void;
    /**
     * 根据起点终点名称查询路径规划
     * @param point 名称数组
     * @param callback 查询回调
     */
    search(
      point: Walking.SearchPoint[],
      callback?: (
        status: Walking.SearchStatus,
        result: Walking.SearchResultExt | string
      ) => void
    ): void;
    /**
     * 清除搜索的结果
     */
    clear(): void;

    // internal
    open(): void;
    close(): void;
  }
}

declare interface Window {
  _AMapSecurityConfig: { serviceHost?: string; securityJsCode?: string };
  AMapKey: string;
}
