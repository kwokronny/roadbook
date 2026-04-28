//
//  MAAnimatedAnnotation.h
//  MAMapKit
//
//  Created by shaobin on 16/12/8.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#import "MAPointAnnotation.h"
#import "MAAnnotationMoveAnimation.h"

///支持动画效果的点标注
///Point annotation with animation support
@interface MAAnimatedAnnotation : MAPointAnnotation<MAAnimatableAnnotation>

///移动方向. 正北为0度，顺时针方向。即正东90，正南180，正西270。since 4.5.0
///Movement direction. 0 degrees is true north, clockwise. That is, 90 degrees is east, 180 degrees is south, and 270 degrees is west.  since 4.5.0
@property (nonatomic, assign) CLLocationDirection movingDirection;

/**
 @brief 添加移动动画, 第一个添加的动画以当前coordinate为起始点，沿传入的coordinates点移动，否则以上一个动画终点为起始点. since 4.5.0
 Add a movement animation, the first added animation starts from the current coordinate and moves along the passed coordinates, otherwise it starts from the endpoint of the previous animation.  since 4.5.0
 @param coordinates c数组，由调用者负责coordinates指向内存的管理
 C array, the caller is responsible for the management of the memory pointed to by coordinates
 @param count coordinates数组大小
 coordinates array size
 @param duration 动画时长，0或<0为无动画
 animation duration, 0 or <0 means no animation
 @param name 名字，如不指定可传nil
 name, can pass nil if not specified
 @param completeCallback 动画完成回调，isFinished: 动画是否执行完成
 animation completion callback, isFinished: whether the animation is completed
 */
- (MAAnnotationMoveAnimation *)addMoveAnimationWithKeyCoordinates:(CLLocationCoordinate2D *)coordinates
                                                            count:(NSUInteger)count
                                                     withDuration:(CGFloat)duration
                                                         withName:(NSString *)name
                                                 completeCallback:(void(^)(BOOL isFinished))completeCallback;

/**
 @brief 添加移动动画, 第一个添加的动画以当前coordinate为起始点，沿传入的coordinates点移动，否则以上一个动画终点为起始点. since 5.4.0
 Add a movement animation, the first added animation starts from the current coordinate and moves along the passed coordinates, otherwise it starts from the endpoint of the previous animation. since 5.4.0
 @param coordinates c数组，由调用者负责coordinates指向内存的管理
 C array, the caller is responsible for the management of the memory pointed to by coordinates
 @param count coordinates数组大小
 coordinates array size
 @param duration 动画时长，0或<0为无动画
 animation duration, 0 or <0 means no animation
 @param name 名字，如不指定可传nil
 name, can pass nil if not specified
 @param completeCallback 动画完成回调，isFinished: 动画是否执行完成
 animation completion callback, isFinished: whether the animation is completed
 @param stepCallback 动画每一帧回调
 Animation frame callback
 */
- (MAAnnotationMoveAnimation *)addMoveAnimationWithKeyCoordinates:(CLLocationCoordinate2D *)coordinates
                                                            count:(NSUInteger)count
                                                     withDuration:(CGFloat)duration
                                                         withName:(NSString *)name
                                                 completeCallback:(void(^)(BOOL isFinished))completeCallback
                                                     stepCallback:(void(^)(MAAnnotationMoveAnimation* currentAni))stepCallback;

/**
 * @brief 获取所有未完成的移动动画, 返回数组内为MAAnnotationMoveAnimation对象. since 4.5.0
 * Retrieve all unfinished move animations, returning an array of MAAnnotationMoveAnimation objects. since 4.5.0
 * @return 返回所有移动动画，数组内元素类型为 MAAnnotationMoveAnimation
 * Return all move animations, the elements in the array are of type MAAnnotationMoveAnimation
 */
- (NSArray<MAAnnotationMoveAnimation*> *)allMoveAnimations;

/**
 * @brief 设置需要开始动画，自定义其他类型动画时需要调用. since 6.0.0
 * Settings require starting animation, which needs to be called when customizing other types of animations. since 6.0.0
 */
- (void)setNeedsStart;

@end
