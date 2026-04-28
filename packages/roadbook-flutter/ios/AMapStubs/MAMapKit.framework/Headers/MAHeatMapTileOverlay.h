//
//  MAHeatMapTileOverlay.h
//  test2D
//
//  Created by xiaoming han on 15/4/21.
//  Copyright (c) 2015年 Amap. All rights reserved.
//



#import "MAConfig.h"

#if MA_INCLUDE_OVERLAY_HEATMAP

#import "MATileOverlay.h"

///热力图节点
///Heatmap node
@interface MAHeatMapNode : NSObject

///经纬度
///Latitude and longitude
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

///强度
///Intensity
@property (nonatomic, assign) float intensity;

@end

///热力图渐变属性
///Heatmap gradient properties
@interface MAHeatMapGradient : NSObject<NSCopying>

///颜色变化数组。 default [blue,green,red]
///Color gradient array.  default [blue,green,red]
@property (nonatomic, readonly) NSArray<UIColor *> *colors;

///颜色变化起点，需为递增数组，区间为(0, 1)。default[@(0.2),@(0.5),@(0,9)]
///Starting point of color gradient, must be an increasing array, range (0, 1).  default[@(0.2),@(0.5),@(0,9)]
@property (nonatomic, readonly) NSArray<NSNumber *> *startPoints;

/**
 * @brief 重新设置gradient的时候，需要执行 MATileOverlayRenderer 的 reloadData 方法重刷新渲染缓存。
 * When resetting the gradient, you need to execute the reloadData method of MATileOverlayRenderer to refresh the rendering cache.
 * @param colors      颜色
 * Color
 * @param startPoints startPoints
 * @return instance
 */
- (instancetype)initWithColor:(NSArray<UIColor *> *)colors andWithStartPoints:(NSArray<NSNumber *> *)startPoints;

@end

///热力图tileOverlay
///Heatmap tileOverlay
@interface MAHeatMapTileOverlay : MATileOverlay

///MAHeatMapNode array
@property (nonatomic, strong) NSArray<MAHeatMapNode *> *data;

///热力图半径，默认为12，范围:10-200 screen point
///Heatmap radius, default is 12, range: 10-200 screen points
@property (nonatomic, assign) NSInteger radius;

///透明度，默认为0.6，范围：0-1
///Opacity, default is 0.6, range: 0-1
@property (nonatomic, assign) CGFloat opacity;

///热力图梯度
///Heatmap gradient
@property (nonatomic, strong) MAHeatMapGradient *gradient;

///是否开启高清热力图，默认关闭
///Whether to enable high-definition heatmap, default is off
@property (nonatomic, assign) BOOL allowRetinaAdapting;

@end

#endif


