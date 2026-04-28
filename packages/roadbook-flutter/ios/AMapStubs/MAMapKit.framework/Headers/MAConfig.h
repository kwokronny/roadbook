/*
 * @Author: hunk.lc
 * @Date: 2022-08-17 15:09:58
 * @Description: 
 */

#pragma once

#pragma mark - iOS 平台特有的宏

#ifndef MA_INCLUDE_OFFLINE
#define MA_INCLUDE_OFFLINE 1
#endif

#ifndef MA_INCLUDE_TRACE_CORRECT
#define MA_INCLUDE_TRACE_CORRECT 1
#endif

#ifndef MA_INCLUDE_INDOOR
#define MA_INCLUDE_INDOOR 1
#endif

#ifndef MA_INCLUDE_CACHE
#define MA_INCLUDE_CACHE 1
#endif

#ifndef MA_INCLUDE_CUSTOM_MAP_STYLE
#define MA_INCLUDE_CUSTOM_MAP_STYLE 1
#endif

#ifndef MA_INCLUDE_WORLD_EN_MAP
#define MA_INCLUDE_WORLD_EN_MAP 1
#endif

#ifndef MA_INCLUDE_OVERLAY_TILE
#define MA_INCLUDE_OVERLAY_TILE 1
#endif

#ifndef MA_INCLUDE_OVERLAY_HEATMAP
#define MA_INCLUDE_OVERLAY_HEATMAP 1
#endif

#ifndef MA_INCLUDE_QUARDTREE
#define MA_INCLUDE_QUARDTREE 1
#endif

#ifndef MA_INCLUDE_OVERLAY_ARC
#define MA_INCLUDE_OVERLAY_ARC 1
#endif

#ifndef MA_INCLUDE_OVERLAY_CUSTOMBUILDING
#define MA_INCLUDE_OVERLAY_CUSTOMBUILDING 1
#endif

#ifndef MA_INCLUDE_OVERLAY_GROUND
#define MA_INCLUDE_OVERLAY_GROUND 1
#endif

#ifndef MA_INCLUDE_OVERLAY_GEODESIC
#define MA_INCLUDE_OVERLAY_GEODESIC 1
#endif

#ifndef MA_INCLUDE_OVERLAY_MAMultiPolyline
#define MA_INCLUDE_OVERLAY_MAMultiPolyline 1
#endif

#ifndef MA_INCLUDE_OVERLAY_MAMultiPoint
#define MA_INCLUDE_OVERLAY_MAMultiPoint 1
#endif

#ifndef MA_INCLUDE_OVERLAY_ParticleSystem
#define MA_INCLUDE_OVERLAY_ParticleSystem 1
#endif

#ifndef MA_INCLUDE_OVERSEA
#define MA_INCLUDE_OVERSEA 0
#endif

#ifndef MA_ENABLE_ThirdPartyLog
#define MA_ENABLE_ThirdPartyLog 0
#endif

//标识是否支持异步等待引擎线程池结束
#ifndef MA_INCLUDE_END_THEADPOOL_ASYN
#define MA_INCLUDE_END_THEADPOOL_ASYN 1
#endif

//国际图
#ifndef AMC_INCLUDE_Global
#define AMC_INCLUDE_Global 1
#endif

#pragma mark - iOS和android 双平台都用到的宏

#ifndef AMC_INCLUDE_GNaviSearch
#define AMC_INCLUDE_GNaviSearch 1
#endif

#ifndef AMC_INCLUDE_MAMapVectorOverlay
#define AMC_INCLUDE_MAMapVectorOverlay 1
#endif

//自定义楼块
#ifndef AMC_INCLUDE_CustomBuilding
#define AMC_INCLUDE_CustomBuilding 1
#endif

//粒子系统
#ifndef AMC_INCLUDE_ParticleSystem
#define AMC_INCLUDE_ParticleSystem 1
#endif

// 3d模型
#ifndef MA_INCLUDE_3DModel
#define MA_INCLUDE_3DModel 1
#endif

// gltf
#ifndef FEATURE_GLTF
#define FEATURE_GLTF 1
#endif

// mvt
#ifndef FEATURE_MVT
#define FEATURE_MVT 1
#endif

// 3dtiles
#ifndef FEATURE_3DTiles
#define FEATURE_3DTiles 1
#endif

// location
#ifndef FEATURE_LOCATION
#define FEATURE_LOCATION 1
#endif

// engine routeoverlay
#ifndef FEATURE_ROUTE_OVERLAY
#define FEATURE_ROUTE_OVERLAY 1
#endif

// arrowOverlay
#ifndef FEATURE_ARROWOVERLAY
#define FEATURE_ARROWOVERLAY 1
#endif
