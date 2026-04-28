//
//  MAMapStatus.h
//  MapKit_static
//
//  Created by yi chen on 1/27/15.
//  Copyright © 2016 Amap. All rights reserved.
//



#import "MAConfig.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>

///地图状态对象
///Map status object
@interface MAMapStatus : NSObject

///地图的中心点，改变该值时，地图的比例尺级别不会发生变化
///The center point of the map, when this value is changed, the scale level of the map will not change
@property (nonatomic) CLLocationCoordinate2D centerCoordinate;

///缩放级别
///Zoom level
@property (nonatomic) CGFloat zoomLevel;

///设置地图旋转角度(逆时针为正向), 单位度, [0,360)
///Set the rotation angle of the map (counterclockwise is positive), in degrees, [0,360)
@property (nonatomic) CGFloat rotationDegree;

///设置地图相机角度(范围为[0.f, 45.f])
///Set the map camera angle (range [0.f, 45.f])
@property (nonatomic) CGFloat cameraDegree;

///地图的视图锚点。坐标系归一化，(0, 0)为MAMapView左上角，(1, 1)为右下角。默认为(0.5, 0.5)，即当前地图的视图中心
///The view anchor point of the map. The coordinate system is normalized, with (0, 0) at the top-left corner of MAMapView and (1, 1) at the bottom-right corner. Default is (0.5, 0.5), which is the center of the current map view.
@property (nonatomic) CGPoint screenAnchor;

/**
 * @brief 根据指定参数生成对应的status
 * Generate the corresponding status based on the specified parameters
 * @param coordinate     地图的中心点，改变该值时，地图的比例尺级别不会发生变化
 * The center point of the map, changing this value will not affect the map's scale level
 * @param zoomLevel      缩放级别
 * Zoom level
 * @param rotationDegree 设置地图旋转角度(逆时针为正向)
 * Set the map rotation angle (counterclockwise is positive)
 * @param cameraDegree   设置地图相机角度(范围为[0.f, 45.f])
 * Set the map camera angle (range [0.f, 45.f])
 * @param screenAnchor   地图的视图锚点。坐标系归一化，(0, 0)为MAMapView左上角，(1, 1)为右下角。默认为(0.5, 0.5)，即当前地图的视图中心
 * The view anchor point of the map. The coordinate system is normalized, with (0, 0) being the top-left corner of MAMapView and (1, 1) being the bottom-right corner. Default is (0.5, 0.5), which is the center of the current map view.
 * @return 生成的Status
 * Generated Status
 */
+ (instancetype)statusWithCenterCoordinate:(CLLocationCoordinate2D)coordinate
                                 zoomLevel:(CGFloat)zoomLevel
                            rotationDegree:(CGFloat)rotationDegree
                              cameraDegree:(CGFloat)cameraDegree
                              screenAnchor:(CGPoint)screenAnchor;

/**
 * @brief 根据指定参数初始化对应的status
 * Initialize the corresponding status according to the specified parameters
 * @param coordinate     地图的中心点，改变该值时，地图的比例尺级别不会发生变化
 * The center point of the map, changing this value will not affect the map's scale level
 * @param zoomLevel      缩放级别
 * Zoom level
 * @param rotationDegree 设置地图旋转角度(逆时针为正向)
 * Set the map rotation angle (counterclockwise is positive)
 * @param cameraDegree   设置地图相机角度(范围为[0.f, 45.f])
 * Set the map camera angle (range [0.f, 45.f])
 * @param screenAnchor   地图的视图锚点。坐标系归一化，(0, 0)为MAMapView左上角，(1, 1)为右下角。默认为(0.5, 0.5)，即当前地图的视图中心
 * The view anchor point of the map. The coordinate system is normalized, with (0, 0) being the top-left corner of MAMapView and (1, 1) being the bottom-right corner. Default is (0.5, 0.5), which is the center of the current map view.
 * @return 生成的Status
 * Generated Status
 */
- (id)initWithCenterCoordinate:(CLLocationCoordinate2D)coordinate
                     zoomLevel:(CGFloat)zoomLevel
                rotationDegree:(CGFloat)rotationDegree
                  cameraDegree:(CGFloat)cameraDegree
                  screenAnchor:(CGPoint)screenAnchor;

@end
