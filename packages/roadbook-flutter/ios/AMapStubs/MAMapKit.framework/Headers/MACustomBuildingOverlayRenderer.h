//
//  MACustomBuildingOverlayRenderer.h
//  MAMapKit
//
//  Created by liubo on 2018/5/23.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_CUSTOMBUILDING

#import "MAOverlayRenderer.h"
#import "MACustomBuildingOverlay.h"

///该类是MACustomBuildingOverlay的显示Renderer. since 6.3.0
///This class is the renderer for MACustomBuildingOverlay display.   since 6.3.0
@interface MACustomBuildingOverlayRenderer : MAOverlayRenderer

///关联的MACustomBuildingOverlay model
///Associated with the MACustomBuildingOverlay model
@property (nonatomic, readonly) MACustomBuildingOverlay *customBuildingOverlay;

/**
 * @brief 根据指定MACustomBuildingOverlay生成对应的Renderer
 * Generate the corresponding Renderer based on the specified MACustomBuildingOverlay
 * @param customBuildingOverlay 指定的MACustomBuildingOverlay model
 * The specified MACustomBuildingOverlay model
 * @return 生成的Renderer
 * The generated Renderer
 */
- (instancetype)initWithCustomBuildingOverlay:(MACustomBuildingOverlay *)customBuildingOverlay;

@end
#endif
