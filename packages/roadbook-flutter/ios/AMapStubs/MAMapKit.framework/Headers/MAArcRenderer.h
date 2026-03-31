//
//  MAArcRenderer.h
//  MAMapKit
//
//  Created by liubo on 2018/4/10.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_ARC

#import "MAArc.h"
#import "MAOverlayPathRenderer.h"

///此类用于绘制MAArc,可以通过MAOverlayPathRenderer修改其stroke attributes
///This class is used to draw MAArc, and its stroke attributes can be modified via MAOverlayPathRenderer
@interface MAArcRenderer : MAOverlayPathRenderer

///关联的MAArc model
///Associated MAArc model
@property (nonatomic, readonly) MAArc *arc;

/**
 * @brief 根据指定的MAArc生成一个圆弧Renderer
 * Generate an arc Renderer based on the specified MAArc
 * @param arc 指定MAArc
 * Specify MAArc
 * @return 新生成的圆弧Renderer
 * The newly generated arc Renderer
 */
- (instancetype)initWithArc:(MAArc *)arc;

@end

#endif
