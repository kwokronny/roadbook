//
//  MATouchPoi.h
//  MapKit_static
//
//  Created by songjian on 13-7-17.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

///MATouchPoi 定义
///MATouchPoi definition
@interface MATouchPoi : NSObject

///名称
///name
@property (nonatomic, copy, readonly) NSString *name;

///经纬度坐标
///latitude and longitude coordinates
@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;

///poi的ID
///POI ID
@property (nonatomic, copy, readonly) NSString *uid;

@end
