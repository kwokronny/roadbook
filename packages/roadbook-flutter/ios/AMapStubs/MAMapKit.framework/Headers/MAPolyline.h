//
//  MAPolyline.h
//  MAMapKit
//
//  
//  Copyright (c) 2011年 Amap. All rights reserved.
//

#import "MAConfig.h"
#import "MAMultiPoint.h"
#import "MAOverlay.h"

///此类用于定义一个由多个点相连的多段线，点与点之间尾部相连但第一点与最后一个点不相连, 通常MAPolyline是MAPolylineView的model
///This class is used to define a polyline connected by multiple points, where the points are connected end-to-end but the first point is not connected to the last point. Typically, MAPolyline is the model of MAPolylineView.
@interface MAPolyline : MAMultiPoint <MAOverlay>

/**
 * @brief 根据map point数据生成多段线
 * Generate polylines based on map point data
 * @param points map point数据,points对应的内存会拷贝,调用者负责该内存的释放
 * map point data, the memory corresponding to points will be copied, the caller is responsible for releasing this memory
 * @param count  map point个数
 * number of map points
 * @return 生成的多段线
 * generated polylines
 */
+ (instancetype)polylineWithPoints:(MAMapPoint *)points count:(NSUInteger)count;

/**
 * @brief 根据经纬度坐标数据生成多段线
 * Generate a polyline based on latitude and longitude coordinate data
 * @param coords 经纬度坐标数据,coords对应的内存会拷贝,调用者负责该内存的释放
 * Latitude and longitude coordinate data, the memory corresponding to coords will be copied, the caller is responsible for releasing this memory
 * @param count  经纬度坐标个数
 * Number of latitude and longitude coordinates
 * @return 生成的多段线
 * generated polylines
 */
+ (instancetype)polylineWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count;

/**
 * @brief 重新设置折线坐标点. since 5.0.0
 * Reset polyline coordinate points. since 5.0.0
 * @param points 指定的直角坐标点数组, C数组，内部会做copy，调用者负责内存管理
 * Specified rectangular coordinate point array, C array, internal copy will be made, caller is responsible for memory management.
 * @param count 坐标点的个数
 * Number of coordinate points
 * @return 是否设置成功
 * Whether the setting is successful
 */
- (BOOL)setPolylineWithPoints:(MAMapPoint *)points count:(NSInteger)count;

/**
 * @brief 重新设置折线坐标点. since 5.0.0
 * Reset polyline coordinate points. since 5.0.0
 * @param coords 指定的经纬度坐标点数组, C数组，内部会做copy，调用者负责内存管理
 * Specified latitude-longitude coordinate point array, C array, internal copy will be made, caller is responsible for memory management.
 * @param count 坐标点的个数
 * Number of coordinate points
 * @return 是否设置成功
 * Whether the setting is successful
 */
- (BOOL)setPolylineWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSInteger)count;

@end
