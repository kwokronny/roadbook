//
//  MAGeodesicPolyline.h
//  MapKit_static
//
//  Created by songjian on 13-10-23.
//  Copyright © 2016 Amap. All rights reserved.

#import "MAConfig.h"

#if MA_INCLUDE_OVERLAY_GEODESIC

#import "MAPolyline.h"

///大地曲线
///Earth's curvature
@interface MAGeodesicPolyline : MAPolyline

/**
 * @brief 根据MAMapPoints生成大地曲线
 * Generate geodesic curves based on MAMapPoints
 * @param points MAMapPoint点
 * MAMapPoint points
 * @param count  点的个数
 * Number of points
 * @return 生成的大地曲线
 * Generated geodesic curves
 */
+ (instancetype)polylineWithPoints:(MAMapPoint *)points count:(NSUInteger)count;

/**
 * @brief 根据经纬度生成大地曲线
 * Generate geodesic curves based on latitude and longitude
 * @param coords 经纬度
 * Latitude and longitude
 * @param count  点的个数
 * Number of points
 * @return 生成的大地曲线
 * Generated geodesic curves
 */
+ (instancetype)polylineWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count;

/**
 * @brief 重新设置坐标点. since 5.0.0
 * Reset coordinate points. since 5.0.0
 * @param points 指定的直角坐标点数组，C数组，内部会做copy，调用者负责内存管理。
 * Specified rectangular coordinate points array, C array, internal copy will be made, caller is responsible for memory management
 * @param count 坐标点的个数
 * Number of coordinate points
 * @return 是否设置成功
 * Whether the setup is successful
 */
- (BOOL)setPolylineWithPoints:(MAMapPoint *)points count:(NSInteger)count;

/**
 * @brief 重新设置坐标点. since 5.0.0
 * Reset coordinate points. since 5.0.0
 * @param coords 指定的经纬度坐标点数组，C数组，内部会做copy，调用者负责内存管理
 * Specified array of latitude and longitude coordinate points, C array, internal copy will be performed, caller is responsible for memory management
 * @param count 坐标点的个数
 * Number of coordinate points
 * @return 是否设置成功
 * Whether the setup is successful
 */
- (BOOL)setPolylineWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSInteger)count;

@end

#endif
