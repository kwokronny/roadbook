//
//  MATraceLocation.h
//  MAMapKit
//
//  Created by shaobin on 16/9/1.
//  Copyright © 2016年 Amap. All rights reserved.
//



#import "MAConfig.h"

#if MA_INCLUDE_TRACE_CORRECT

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

///返回轨迹点定义
///Return track point definition
@interface MATracePoint : NSObject<NSCoding>

///纬度坐标
///Latitude coordinate
@property (nonatomic, assign) CLLocationDegrees latitude;
///经度坐标
///Longitude coordinate
@property (nonatomic, assign) CLLocationDegrees longitude;

@end

///传入轨迹点定义
///Incoming track point definition
@interface MATraceLocation : NSObject

///经纬度坐标
///Latitude and longitude coordinates
@property (nonatomic, assign) CLLocationCoordinate2D loc;
///角度, 标识移动方向，单位度
///Angle, indicating the direction of movement, unit degree
@property (nonatomic, assign) double angle;
///速度，单位km/h
///Speed, unit km/h
@property (nonatomic, assign) double speed;
///时间，单位毫秒
///Time, unit millisecond
@property (nonatomic, assign) double time;

@end

#endif
