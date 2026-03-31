//
//  MACircleRenderer.h
//  MAMapKit
//
//  Created by yin cai on 11-12-30.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#import "MACircle.h"
#import "MAOverlayPathRenderer.h"

///该类是MACircle的显示圆Renderer,可以通过MAOverlayPathRenderer修改其fill和stroke attributes
///This class is the renderer for MACircle's display circle. Its fill and stroke attributes can be modified via MAOverlayPathRenderer
@interface MACircleRenderer : MAOverlayPathRenderer

///关联的MAcirlce model
///Associated MAcircle model
@property (nonatomic, readonly) MACircle *circle;

/**
 * @brief 根据指定圆生成对应的Renderer
 * Generate corresponding Renderer based on specified circle
 * @param circle 指定的MACircle model
 * Specified MACircle model
 * @return 生成的Renderer
 * Generated Renderer
 */
- (instancetype)initWithCircle:(MACircle *)circle;

@end
