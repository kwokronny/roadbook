//
//  MACircle.h
//  MAMapKit
//
//
//  Copyright (c) 2011年 Amap. All rights reserved.

#import "MAConfig.h"
#import "MAShape.h"
#import "MAOverlay.h"
#import "MAGeometry.h"

///该类用于定义一个圆, 通常MACircle是MACircleView的model
///This class is used to define a circle, usually MACircle is the model of MACircleView
@interface MACircle : MAShape <MAOverlay>

///设置中空区域，用来创建中间带空洞的复杂图形。注意：传入的overlay只支持MAPolgon类型和MACircle类型,不支持与此circle边相交或在circle外部,不支持hollowShapes彼此间相交,和空洞顺序有关,不支持嵌套. since 5.5.0
///Set the hollow area to create complex shapes with holes in the middle. Note: The overlay passed in only supports MAPolygon type and MACircle type,Intersection with the edge of this circle or being outside the circle is not supported, intersection between hollowShapes is not supported, it is related to the order of voids, nesting is not supported.  since 5.5.0
@property (nonatomic, strong) NSArray<id<MAOverlay>> *hollowShapes;

///中心点经纬度坐标，无效坐标按照{0，0}处理
///Center point latitude and longitude coordinates, invalid coordinates are processed as {0, 0}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

///半径，单位：米 负数按照0处理
///Radius, unit: meters, negative numbers are treated as 0
@property (nonatomic, assign) CLLocationDistance radius;

/**
 * @brief 根据中心点和半径生成圆
 * Generate a circle based on the center point and radius
 * @param coord  中心点的经纬度坐标，无效坐标按照{0，0}处理
 * Latitude and longitude coordinates of the center point, invalid coordinates are treated as {0, 0}
 * @param radius 半径，单位：米, 负数按照0处理
 * Radius, unit: meters, negative values are treated as 0
 * @return 新生成的圆
 * Newly generated circle
 */
+ (instancetype)circleWithCenterCoordinate:(CLLocationCoordinate2D)coord
                                    radius:(CLLocationDistance)radius;

/**
 * @brief 根据map rect生成圆
 * Generate a circle based on map rect
 * @param mapRect mapRect 圆的最小外界矩形
 * mapRect is the minimum bounding rectangle of the circle
 * @return 新生成的圆
 * the newly generated circle
 */
+ (instancetype)circleWithMapRect:(MAMapRect)mapRect;

/**
 * @brief 设置圆的中心点和半径. since 5.0.0
 * set the center point and radius of the circle. since 5.0.0
 * @param coord 中心点的经纬度坐标，无效坐标按照{0，0}处理
 * Latitude and longitude coordinates of the center point, invalid coordinates are treated as {0, 0}
 * @param radius 半径，单位：米 负数按照0处理
 * Radius, unit: meters, negative values are treated as 0
 * @return 是否设置成功
 * whether the setting is successful
 */
- (BOOL)setCircleWithCenterCoordinate:(CLLocationCoordinate2D)coord radius:(CLLocationDistance)radius;

@end
