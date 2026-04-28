//
//  MAMultiColoredPolylineRenderer.h
//  MapKit_static
//
//  Created by yi chen on 12/11/15.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_MAMultiPolyline

#import "MAPolylineRenderer.h"
#import "MAMultiPolyline.h"

///此类用于绘制 MAMultiPolyline 对应的多彩线，支持分段颜色绘制
///This class is used to draw the colorful line corresponding to MAMultiPolyline, supporting segmented color rendering
@interface MAMultiColoredPolylineRenderer : MAPolylineRenderer

///关联的MAMultiPolyline model
///Associated MAMultiPolyline model
@property (nonatomic, readonly) MAMultiPolyline *multiPolyline;

///分段绘制的颜色,需要分段颜色绘制时，必须设置（内容必须为UIColor）。根据multiPolyline.drawStyleIndexes属性指示的索引进行渲染。
///The color for segmented drawing must be set (the content must be UIColor) when segmented color drawing is required. It is rendered according to the index indicated by the multiPolyline.drawStyleIndexes property.
@property (nonatomic, strong) NSArray<UIColor *> *strokeColors;

///颜色是否渐变, 默认为NO。如果设置为YES，则为多彩渐变线。
///Whether the color is gradient, default is NO. If set to YES, it becomes a colorful gradient line.
@property (nonatomic, getter=isGradient) BOOL gradient;

/**
 * @brief 根据指定的MAPolyline生成一个多段线Renderer
 * Generate a polyline Renderer based on the specified MAPolyline
 * @param multiPolyline 指定MAMultiPolyline
 * Specify MAMultiPolyline
 * @return 新生成的多段线Renderer
 * Newly generated polyline Renderer
*/
- (instancetype)initWithMultiPolyline:(MAMultiPolyline *)multiPolyline;

@end

#endif
