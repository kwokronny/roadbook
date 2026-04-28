//
//  MAHeatMapVectorOverlayRender.h
//  MAMapKit
//
//  Created by ldj on 2019/7/26.
//  Copyright © 2019 Amap. All rights reserved.
//
#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_HEATMAP

#import "MAOverlayRenderer.h"
#import "MAHeatMapVectorOverlay.h"

///矢量热力图绘制类
///Vector Heatmap Drawing Class
@interface MAHeatMapVectorOverlayRender : MAOverlayRenderer

///关联的MAHeatMapVectorOverlay
///Associated MAHeatMapVectorOverlay
@property (nonatomic, readonly) MAHeatMapVectorOverlay *heatOverlay;

/**
 * @brief 根据指定的MAHeatMapVectorOverlay生成一个Renderer
 * Generate a Renderer based on the specified MAHeatMapVectorOverlay
 * @param heatOverlay 指定MAHeatMapVectorOverlay
 * Specify MAHeatMapVectorOverlay
 * @return 新生成的MAHeatMapVectorOverlayRender
 * Newly generated MAHeatMapVectorOverlayRender
 */
- (instancetype)initWithHeatOverlay:(MAHeatMapVectorOverlay *)heatOverlay;


/**
 * @brief 根据经纬度获取对应的热力节点信息MAHeatMapVectorItem
 * Obtain corresponding heatmap node information MAHeatMapVectorItem based on latitude and longitude
 * @param coordinate 经纬度
 * Latitude and longitude
 */
- (MAHeatMapVectorItem *)getHeatMapItem:(CLLocationCoordinate2D )coordinate;

@end

#endif
