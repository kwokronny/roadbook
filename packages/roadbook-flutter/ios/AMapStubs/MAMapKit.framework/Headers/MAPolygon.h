//
//  MAPolygon.h
//  MAMapKit
//
//  Copyright (c) 2011年 Amap. All rights reserved.
//

#import "MAConfig.h"
#import <Foundation/Foundation.h>
#import "MAMultiPoint.h"
#import "MAOverlay.h"

///此类用于定义一个由多个点组成的闭合多边形, 点与点之间按顺序尾部相连, 第一个点与最后一个点相连, 通常MAPolygon是MAPolygonView的model
///This class is used to define a closed polygon composed of multiple points, where the points are connected sequentially from tail to head, and the first point is connected to the last point. Typically, MAPolygon is the model of MAPolygonView.
@interface MAPolygon : MAMultiPoint <MAOverlay>

///设置中空区域，用来创建中间带空洞的复杂图形。注意：传入的overlay只支持MAPolgon类型和MACircle类型,不支持与polygon边相交或在polygon外部,不支持hollowShapes彼此间相交,和空洞顺序有关,不支持嵌套. since 5.5.0
///Set the hollow area to create complex shapes with holes in the middle. Note: The incoming overlay only supports MAPolgon type and MACircle type. Intersection with polygon edges or being outside the polygon is not supported, intersection between hollowShapes is not supported, it is related to the order of holes, nesting is not supported. since 5.5.0
@property (nonatomic, strong) NSArray<id<MAOverlay>> *hollowShapes;

/**
 * @brief 根据经纬度坐标数据生成闭合多边形
 * Generate a closed polygon based on latitude and longitude coordinate data
 * @param coords 经纬度坐标点数据,coords对应的内存会拷贝,调用者负责该内存的释放
 * The memory corresponding to the latitude and longitude coordinate points, coords, will be copied, and the caller is responsible for releasing this memory
 * @param count  经纬度坐标点数组个数
 * The number of latitude and longitude coordinate point arrays
 * @return 新生成的多边形
 * Newly generated polygon
 */
+ (instancetype)polygonWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count;

/**
 * @brief 根据map point数据生成多边形
 * Generate polygon based on map point data
 * @param points map point数据,points对应的内存会拷贝,调用者负责该内存的释放
 * map point data, the memory corresponding to points will be copied, the caller is responsible for releasing this memory
 * @param count  点的个数
 * number of points
 * @return 新生成的多边形
 * Newly generated polygon
 */
+ (instancetype)polygonWithPoints:(MAMapPoint *)points count:(NSUInteger)count;

/**
 * @brief 重新设置多边形顶点. since 5.0.0
 * Reset polygon vertices. since 5.0.0
 * @param points 指定的直角坐标点数组, C数组，内部会做copy，调用者负责内存管理
 * specified rectangular coordinate point array, C array, internal copy will be made, caller is responsible for memory management
 * @param count 坐标点的个数
 * number of coordinate points
 * @return 是否设置成功
 * whether the setup was successful
 */
- (BOOL)setPolygonWithPoints:(MAMapPoint *)points count:(NSInteger)count;

/**
 * @brief 重新设置多边形顶点. since 5.0.0
 * Reset polygon vertices. since 5.0.0
 * @param coords 指定的经纬度坐标点数组, C数组，内部会做copy，调用者负责内存管理
 * specified latitude and longitude coordinate point array, C array, internal copy will be made, caller is responsible for memory management
 * @param count 坐标点的个数
 * number of coordinate points
 * @return 是否设置成功
 * whether the setup was successful
 */
- (BOOL)setPolygonWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSInteger)count;

@end
