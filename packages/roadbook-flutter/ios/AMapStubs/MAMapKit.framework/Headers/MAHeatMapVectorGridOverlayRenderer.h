//
//  MAHeatMapVectorGridOverlayRenderer.h
//  MAMapKit
//
//  Created by ldj on 2019/7/26.
//  Copyright © 2019 Amap. All rights reserved.
//
#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_HEATMAP

#import "MAOverlayRenderer.h"
#import "MAHeatMapVectorGridOverlay.h"

///矢量热力图绘制类
///Vector heatmap rendering class
@interface MAHeatMapVectorGridOverlayRenderer : MAOverlayRenderer

///关联的MAHeatMapVectorOverlay
///Associated MAHeatMapVectorOverlay
@property (nonatomic, readonly) MAHeatMapVectorGridOverlay *heatOverlay;

/**
 * @brief 根据指定的MAHeatMapVectorOverlay生成一个Renderer
 * Generate a Renderer based on the specified MAHeatMapVectorOverlay
 * @param heatOverlay 指定MAHeatMapVectorOverlay
 * Specify MAHeatMapVectorOverlay
 * @return 新生成的MAHeatMapVectorOverlayRender
 * Newly generated MAHeatMapVectorOverlayRender
 */
- (instancetype)initWithHeatOverlay:(MAHeatMapVectorGridOverlay *)heatOverlay;
@end

#endif
