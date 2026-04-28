//
//  MAOverlay.h
//  MAMapKit
//
//  
//  Copyright (c) 2011年 Amap. All rights reserved.
//

#import "MAConfig.h"
#import "MAAnnotation.h"
#import "MAGeometry.h"

///该类是地图覆盖物的基类，所有地图的覆盖物需要继承自此类
///This class is the base class for map overlays, all map overlays need to inherit from this class
@protocol MAOverlay <MAAnnotation>
@required

///返回区域中心坐标
///Return the center coordinates of the area
- (CLLocationCoordinate2D)coordinate;

///区域外接矩形
///The bounding rectangle of the area
- (MAMapRect)boundingMapRect;

@end
