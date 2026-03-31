//
//  MAGroundOverlayRenderer.h
//  MapKit_static
//
//  Created by Li Fei on 11/13/13.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"

#if MA_INCLUDE_OVERLAY_GROUND

#import "MAOverlayRenderer.h"
#import "MAGroundOverlay.h"

///此类是将MAGroundOverlay中的覆盖图片显示在地图上的renderer
///This class is the renderer that displays the overlay image from MAGroundOverlay on the map
@interface MAGroundOverlayRenderer : MAOverlayRenderer

///具有覆盖图片，以及图片覆盖的区域
///It has the overlay image and the area covered by the image
@property (nonatomic ,readonly) MAGroundOverlay *groundOverlay;

/**
 * @brief 根据指定的GroundOverlay生成将图片显示在地图上Renderer
 * Generate a Renderer to display the image on the map based on the specified GroundOverlay
 * @param groundOverlay 制定了覆盖图片，以及图片的覆盖区域的groundOverlay
 * Defined the overlay image and the groundOverlay area of the image
 * @return 以GroundOverlay新生成Renderer
 * It generates a new Renderer with GroundOverlay
 */
- (instancetype)initWithGroundOverlay:(MAGroundOverlay *)groundOverlay;

@end

#endif
