//
//  MAUserLocation.h
//  MAMapKit
//
//  Created by yin cai on 12-1-4.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#import <Foundation/Foundation.h>
#import "MAAnimatedAnnotation.h"

@class CLLocation;
@class CLHeading;

///定位信息类
///Location Information Category
@interface MAUserLocation : MAAnimatedAnnotation

///位置更新状态，如果正在更新位置信息，则该值为YES
///Location update status, if the location information is being updated, the value is YES
@property (readonly, nonatomic, getter = isUpdating) BOOL updating;

///位置信息，如果MAMapView的showsUserLocation为NO，或者尚未定位成功，则该值为nil
///Location information, if the showsUserLocation of MAMapView is NO, or the location has not been successfully determined, the value is nil
@property (readonly, nonatomic, strong) CLLocation *location;

///heading信息
///Heading information
@property (readonly, nonatomic, strong) CLHeading *heading;

@end
