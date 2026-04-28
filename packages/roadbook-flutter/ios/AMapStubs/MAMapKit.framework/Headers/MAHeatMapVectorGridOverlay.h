//
//  MAHeatMapVectorGridOverlay.h
//  MAMapKit
//
//  Created by ldj on 2019/7/25.
//  Copyright © 2019 Amap. All rights reserved.
//  热力图网格覆盖物（通过顶点直接绘制）

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_HEATMAP

#import "MAShape.h"
#import "MAOverlay.h"
#import "MAHeatMapVectorOverlay.h"

///单个点对象
///Single point object
@interface MAHeatMapVectorGridNode : NSObject
///经纬度
///Latitude and longitude
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

///单个网格
///Single grid
@interface MAHeatMapVectorGrid : NSObject
/// 网格顶点
/// Grid vertices
@property (nonatomic, copy) NSArray<MAHeatMapVectorGridNode *> *inputNodes;

/// 网格颜色
/// Grid color
@property (nonatomic, strong) UIColor *color;
@end

/// 该类用于定义热力图属性.
/// This class is used to define heatmap attributes.
@interface MAHeatMapVectorGridOverlayOptions : NSObject

/// 热力图类型 (默认为蜂窝类型MAHeatMapTypeHoneycomb)
/// Heatmap type (default is honeycomb type MAHeatMapTypeHoneycomb)
@property (nonatomic, assign) MAHeatMapType type;

/// option选项是否可见. (默认YES)
/// whether the option is visible (default YES
@property (nonatomic, assign) BOOL visible;

/// 网格数据
/// grid data
@property (nonatomic, copy) NSArray<MAHeatMapVectorGrid *> *inputGrids;

/// 最小显示级别 default 3
/// minimum display level, default 3
@property (nonatomic, assign) CGFloat minZoom;

/// 最大显示级别 default 20
/// maximum display level, default 20
@property (nonatomic, assign) CGFloat maxZoom;

@end

///矢量热力图，支持类型详见MAHeatMapType
///Vector heatmap, supported types can be found in MAHeatMapType
@interface MAHeatMapVectorGridOverlay : MAShape<MAOverlay>


///热力图的配置属性
///Configuration properties of the heatmap
@property (nonatomic, strong) MAHeatMapVectorGridOverlayOptions *option;

/**
 * @brief 根据配置属性option生成MAHeatMapVectorGridOverlay
 * Generate MAHeatMapVectorGridOverlay based on configuration property option
 * @param option 热力图配置属性option
 * Heatmap configuration property option
 * @return 新生成的热力图MAHeatMapVectorGridOverlay
 * Newly generated heatmap MAHeatMapVectorGridOverlay
 */
+ (instancetype)heatMapOverlayWithOption:(MAHeatMapVectorGridOverlayOptions *)option;

@end

#endif
