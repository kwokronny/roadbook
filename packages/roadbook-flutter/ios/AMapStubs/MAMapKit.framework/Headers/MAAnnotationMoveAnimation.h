//
//  MAAnnotationMoveAnimation.h
//  MAMapKit
//
//  Created by shaobin on 16/11/21.
//  Copyright © 2016 Amap. All rights reserved.
//


#import "MAConfig.h"
#import <Foundation/Foundation.h>
#import "MAAnnotation.h"

///annotation移动动画. since 4.5.0
///annotation animation  since 4.5.0
@interface MAAnnotationMoveAnimation : NSObject

/**
 * @brief 获取动画名字
 * get animation name
 * @return 添加动画时传入的名字
 * name passed when adding animation
 */
- (NSString *)name;

/**
 * @brief 获取经纬度坐标点数组
 * get latitude and longitude coordinate point array
 * @return 返回经纬度坐标点数组
 * return latitude and longitude coordinate point array
 */
- (CLLocationCoordinate2D *)coordinates;

/**
 * @brief 获取coordinates数组内坐标点个数
 * get number of coordinate points in the coordinates array
 * @return coordinates数组内坐标点个数
 * Number of coordinate points in the coordinates array
 */
- (NSUInteger)count;

/**
 * @brief 获取动画时长
 * Get animation duration
 * @return 动画时长
 * Animation duration
 */
- (CGFloat)duration;

/**
 * @brief 获取动画已执行的时长
 * Get elapsed animation duration
 * @return 动画已执行的时长
 * Elapsed animation duration
 */
- (CGFloat)elapsedTime;

/**
 * @brief 取消
 * Cancel
 */
- (void)cancel;

/**
 * @brief 是否已取消
 * Is canceled
 * @return YES已取消，NO未取消
 * YES canceled, NO not canceled
 */
- (BOOL)isCancelled;

/**
 * @brief 获取当前动画已走过点的总个数
 * Get the total number of points the current animation has passed
 * @return 个数
 * count
 */
- (NSInteger)passedPointCount;


@end
