//
//  MAHeatMapVectorOverlay.h
//  MAMapKit
//
//  Created by ldj on 2019/7/25.
//  Copyright © 2019 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_HEATMAP

#import "MAShape.h"
#import "MAOverlay.h"

///热力图类型
///Heatmap Type
typedef NS_ENUM(NSInteger, MAHeatMapType)
{
    MAHeatMapTypeSquare      = 1,     ///< 网格热力图   Grid Heatmap
    MAHeatMapTypeHoneycomb   = 2      ///< 蜂窝热力图   Hexagonal Heatmap
};

///单个点对象
///Single Point Object
@interface MAHeatMapVectorNode : NSObject

///经纬度
///Latitude and Longitude
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

///权重
///Weight
@property (nonatomic, assign) float weight;

@end

///热力图展示节点（用以描述一个蜂窝或一个网格）
///Heatmap Display Node (used to describe a hexagon or a grid)
@interface MAHeatMapVectorItem : NSObject

///中心点坐标
///Center Point Coordinates
@property (nonatomic, readonly) MAMapPoint center;

///当前热力值，求和后的权重
///Current heat value, summed weight
@property (nonatomic, readonly) float intensity;

///落在此节点区域内的所有热力点的索引数组
///Index array of all heat points within this node area
@property (nonatomic, readonly) NSArray<NSNumber *> *nodeIndices;

@end

///该类用于定义热力图属性.
///This class is used to define heatmap properties
@interface MAHeatMapVectorOverlayOptions : NSObject

///热力图类型 (默认为蜂窝类型MAHeatMapTypeHoneycomb)
///Heatmap type (default is honeycomb type MAHeatMapTypeHoneycomb)
@property (nonatomic, assign) MAHeatMapType type;

///option选项是否可见. (默认YES)
///Whether the option is visible. (Default: YES)
@property (nonatomic, assign) BOOL visible;

///MAHeatMapVectorNode array
@property (nonatomic, strong) NSArray<MAHeatMapVectorNode *> *inputNodes;

/**
 @verbatim
 节点的宽 单位：米 负数按照0处理 default 2000
     —— ——    —— ——
   丨     丨 丨     丨
   丨     丨 丨     丨
     —— ——    —— ——
 
 每个方框的宽就是 size（六边形同理）
 两个方框之间的间隔就是 gap （六边形同理）
 @endverbatim
 */
/**
 @verbatim
 Node width in meters (negative values treated as 0, default 2000)
     —— ——    —— ——
   丨     丨 丨     丨
   丨     丨 丨     丨
     —— ——    —— ——
 
 The width of each box is size (same for hexagons)
 The gap between two boxes is gap (same for hexagons)
 @endverbatim
 */
@property (nonatomic, assign) CLLocationDistance size;

///节点之间的间隔 单位：米 负数按照0处理。注意：改变gap可能会改变热力节点的计算，内部会用size+gap来计算热力，最终用size来画方框。
///The spacing between nodes, unit: meters, negative values are treated as 0. Note: Changing the gap may alter the calculation of heat nodes; internally, size + gap is used to calculate the heat, and finally, size is used to draw the box.
@property (nonatomic, assign) CGFloat gap;

///颜色变化数组。 注意：colors和startPoints两数组长度必须一致且不能为0，
///Color gradient array. Note: The lengths of the colors and startPoints arrays must be equal and cannot be 0.
@property (nonatomic, strong) NSArray<UIColor *> *colors;

///颜色变化起点，需为递增数组，区间为[0, 1]。 注意：colors和startPoints两数组长度必须一致且不能为0。例如：startPoints @[@(0), @(0.3),@(0.7)] 表示区间 [0,0.3)使用第一个颜色，区间[0.3,0.7)使用第二个颜色，区间[0.7,1]使用第三个颜色。注意：startPoints首位需设置成0，如果首位不是0，内部也会把首位当成0来处理。
///The starting point of color change must be an increasing array within the range [0, 1]. Note: the lengths of the colors and startPoints arrays must be the same and cannot be zero.For example: startPoints @[@(0), @(0.3),@(0.7)] means the interval [0,0.3) uses the first color, the interval [0.3,0.7) uses the second color, and the interval [0.7,1] uses the third color.Note: The first element of startPoints must be set to 0. If it is not 0, the system will treat the first element as 0 internally.
@property (nonatomic, strong) NSArray<NSNumber *> *startPoints;

///透明度，取值范围[0,1] ，default为1不透明
///Transparency, value range [0,1], default is 1 for opaque
@property (nonatomic, assign) CGFloat opacity __attribute((deprecated("Deprecated, since 7.9.0, please use alpha in MAHeatMapVectorOverlayRender")));;

///权重的最大值，default为0，表示不填，不填则取数组inputNodes中权重的最大值
///Maximum weight, default is 0, indicating not filled, if not filled, the maximum weight in the array inputNodes is taken
@property (nonatomic, assign) int maxIntensity;

///最小显示级别 default 3
///Minimum display level, default 3
@property (nonatomic, assign) CGFloat minZoom;

///最大显示级别 default 20
///Maximum display level, default 20
@property (nonatomic, assign) CGFloat maxZoom;

@end

///矢量热力图，支持类型详见MAHeatMapType
///Vector heatmap, supported types refer to MAHeatMapType
@interface MAHeatMapVectorOverlay : MAShape<MAOverlay>

///热力图的配置属性
///Configuration properties of heatmap
@property (nonatomic, strong) MAHeatMapVectorOverlayOptions *option;

/**
 * @brief 根据配置属性option生成MAHeatMapVectorOverlay
 * Generate MAHeatMapVectorOverlay based on configuration attribute option
 * @param option 热力图配置属性option
 * Heatmap configuration attribute option
 * @return 新生成的热力图MAHeatMapVectorOverlay
 * Newly generated heatmap MAHeatMapVectorOverlay
 */
+ (instancetype)heatMapOverlayWithOption:(MAHeatMapVectorOverlayOptions *)option;

@end

#endif
