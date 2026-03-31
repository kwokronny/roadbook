//
//  MAPointAnnotation.h
//  MAMapKitDemo
//
//  Created by songjian on 13-1-7.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#import "MAShape.h"
#import <CoreLocation/CLLocation.h>

///点标注数据
///Point annotation data
@interface MAPointAnnotation : MAShape

///经纬度
///Latitude and longitude
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

///是否固定在屏幕一点, 注意，拖动或者手动改变经纬度，都会导致设置失效
///Whether it is fixed at a point on the screen, note that dragging or manually changing the latitude and longitude will cause the setting to become invalid
@property (nonatomic, assign, getter = isLockedToScreen) BOOL lockedToScreen;

///固定屏幕点的坐标
///Fixed screen point coordinates
@property (nonatomic, assign) CGPoint lockedScreenPoint;

@end
