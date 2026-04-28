//
//  MAMultiTexturePolylineRenderer.h
//  MapKit_static
//
//  Created by yi chen on 12/11/15.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_MAMultiPolyline

#import "MAPolylineRenderer.h"
#import "MAMultiPolyline.h"

///此类用于绘制MAMultiPolyline对应的多彩线，支持分段纹理绘制
///This class is used to draw the multi-colored lines corresponding to MAMultiPolyline, supporting segmented texture drawing
@interface MAMultiTexturePolylineRenderer : MAPolylineRenderer

///关联的MAMultiPolyline model
///The associated MAMultiPolyline model
@property (nonatomic, readonly) MAMultiPolyline *multiPolyline;

///分段纹理图片数组, 支持非PowerOfTwo图片
///An array of segmented texture images, supporting non-PowerOfTwo images
@property (nonatomic, strong) NSArray<UIImage*> *strokeTextureImages;

/**
 * @brief 根据指定的MAMultiPolyline生成一个多段线Renderer
 * Generate a polyline Renderer based on the specified MAMultiPolyline
 * @param multiPolyline 指定MAMultiPolyline
 * Specify MAMultiPolyline
 * @return 新生成的多段线Renderer
 * Newly generated polyline Renderer
 */
- (instancetype)initWithMultiPolyline:(MAMultiPolyline *)multiPolyline;

@end

#endif
