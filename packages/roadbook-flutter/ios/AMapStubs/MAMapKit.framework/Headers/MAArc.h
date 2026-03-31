//
//  MAArc.h
//  MAMapKit
//
//  Created by liubo on 2018/4/10.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_ARC

#import "MAShape.h"
#import "MAOverlay.h"

///该类用于定义一个圆弧, 通常MAArc是MAArcRenderer的model
///This class is used to define an arc, usually MAArc serves as the model for MAArcRenderer
@interface MAArc : MAShape <MAOverlay>

///起点经纬度坐标，无效坐标按照{0，0}处理
///Starting point latitude and longitude coordinates, invalid coordinates are treated as {0, 0}
@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate;

///途径点经纬度坐标，无效坐标按照{0，0}处理
///Waypoint latitude and longitude coordinates, invalid coordinates are treated as {0, 0}
@property (nonatomic, assign) CLLocationCoordinate2D passedCoordinate;

///终点经纬度坐标，无效坐标按照{0，0}处理
///Destination latitude and longitude coordinates, invalid coordinates are treated as {0, 0}
@property (nonatomic, assign) CLLocationCoordinate2D endCoordinate;

/**
 * @brief 根据起点、途经点和终点生成圆弧
 * Generate an arc based on the starting point, waypoints, and endpoint
 * @param startCoordinate 起点的经纬度坐标，无效坐标按照{0，0}处理
 * Starting point latitude and longitude coordinates, invalid coordinates are treated as {0, 0}
 * @param passedCoordinate 途径点的经纬度坐标，无效坐标按照{0，0}处理
 * Waypoint latitude and longitude coordinates, invalid coordinates are treated as {0, 0}
 * @param endCoordinate 终点的经纬度坐标，无效坐标按照{0，0}处理
 * Destination latitude and longitude coordinates, invalid coordinates are treated as {0, 0}
 * @return 新生成的圆弧
 * the newly generated arc
 */
+ (instancetype)arcWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                      passedCoordinate:(CLLocationCoordinate2D)passedCoordinate
                         endCoordinate:(CLLocationCoordinate2D)endCoordinate;

@end

#endif
