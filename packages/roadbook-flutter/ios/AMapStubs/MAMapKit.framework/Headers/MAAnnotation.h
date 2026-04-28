//
//  MAAnnotation.h
//  MAMapKit
//
//  Created by yin cai on 11-12-13.
//  Copyright (c) 2011年 Amap. All rights reserved.
//

#import "MAConfig.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "MAGeometry.h"

///该类为标注点的protocol，提供了标注类的基本信息函数
///This class is the protocol for annotation points, providing basic information functions for the annotation class
@protocol MAAnnotation <NSObject>

///标注view中心坐标
///the center coordinates of the annotation view
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@optional

///annotation标题
///the annotation title
@property (nonatomic, copy) NSString *title;

///annotation副标题
///the annotation subtitle
@property (nonatomic, copy) NSString *subtitle;

/**
 * @brief 设置标注的坐标，在拖拽时会被调用.
 * Set the coordinates of the annotation, which will be called during dragging
 * @param newCoordinate 新的坐标值
 * New coordinate values
 */
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

///annotation海拔高度，单位米，默认0
///the annotation altitude, in meters, default is 0
@property (nonatomic, assign) double altitude;
@end

/**
 * 支持动画需要实现的协议. since 4.5.0
 */
/**
 * Protocol that needs to be implemented to support animation.  since 4.5.0
 */
@protocol MAAnimatableAnnotation <NSObject>

@required
/**
 * @brief 动画帧更新回调接口，实现者可在内部做更新处理，如更新coordinate. （since 4.5.0）
 * Animation frame update callback interface, implementers can perform update processing internally, such as updating coordinates. （since 4.5.0）
 * @param timeDelta 时间步长，单位秒
 * time step, unit seconds
 */
- (void)step:(CGFloat)timeDelta;

/**
 * @brief 动画是否已完成. 通过此方法判断是否需要将动画annotation移出渲染执行过程。（since 4.5.0）
 * Whether the animation has been completed. This method is used to determine whether the animation annotation needs to be removed from the rendering execution process.（since 4.5.0）
 * @return YES动画已完成，NO没有完成
 * YES animation is completed, NO not completed
 */
- (BOOL)isAnimationFinished;

/**
 * @brief 动画是否可以开始. 通过此方法判断是否需要将动画annotation加入渲染过程，已经start且尚未finish的动画标注才会调用step方法。（since 6.0.0）
 * Whether the animation can start. This method determines whether the animation annotation needs to be added to the rendering process. Only animations that have started but not yet finished will call the step method.（since 6.0.0）
 * @return YES 可以开始，NO 尚未开始。
 * YES can start, NO has not started yet.
 */
- (BOOL)shouldAnimationStart;

@optional
/**
 * @brief 动画更新时调用此接口，获取annotationView的旋转角度，不实现默认为0. （since 4.5.0）
 * This interface is called when the animation is updated to get the rotation angle of the annotationView. If not implemented, it defaults to 0. （since 4.5.0）
 * @return 当前annotation的旋转角度，正北为0度，顺时针方向。即正东90，正南180，正西270。
 * The rotation angle of the current annotation, with true north as 0 degrees, in a clockwise direction. That is, 90 degrees for due east, 180 degrees for due south, and 270 degrees for due west.
 */
- (CLLocationDirection)rotateDegree;


@end
