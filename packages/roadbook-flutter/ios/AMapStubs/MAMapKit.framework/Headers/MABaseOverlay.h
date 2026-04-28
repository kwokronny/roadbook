//
//  MABaseOverlay.h
//  MAMapKit
//
//  Created by cuishaobin on 2020/6/17.
//  Copyright © 2020 Amap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAOverlay.h"

NS_ASSUME_NONNULL_BEGIN

@interface MABaseOverlay : NSObject<MAOverlay> {
    double _altitude;   ///<海拔   Elevation
}

///返回区域中心坐标
///Return to regional center coordinates
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

///区域外接矩形
///Regional bounding rectangle
@property (nonatomic, assign) MAMapRect boundingMapRect;

///海拔，单位米，默认0
///Elevation, in meters, default 0
@property (nonatomic, assign) double altitude;
@end

NS_ASSUME_NONNULL_END
