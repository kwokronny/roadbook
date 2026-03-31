//
//  MAMapView.h
//  MAMapKit
//
//  Created by 翁乐 on 3/17/16.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MAOverlay.h"
#import "MAOverlayRenderer.h"
#import "MAAnnotationView.h"
#import "MACircle.h"
#import "MAUserLocation.h"
#import "MAMapStatus.h"
#import "MAIndoorInfo.h"
#import "MAUserLocationRepresentation.h"
#import "MAMapCustomStyleOptions.h"
#import <AMapFoundationKit/AMapServices.h>
#import "MABaseEngineOverlay.h"
#import "MAPoiFilter.h"

///地图类型
///Map Types
typedef NS_ENUM(NSInteger, MAMapType)
{
    MAMapTypeStandard = 0,  ///< 普通地图   Standard Map
    MAMapTypeSatellite,     ///< 卫星地图   Satellite Map
    MAMapTypeStandardNight, ///< 夜间视图   Night View
    MAMapTypeNavi,          ///< 导航视图   Navigation View
    MAMapTypeBus,           ///< 公交视图   Transit View
    MAMapTypeNaviNight      ///< 导航夜间视图   Navigation Night View
};

///用户跟踪模式
///User Tracking Mode
typedef NS_ENUM(NSInteger, MAUserTrackingMode)
{
    MAUserTrackingModeNone              = 0,    ///< 不追踪用户的location更新   Do Not Track User's Location Updates
    MAUserTrackingModeFollow            = 1,    ///< 追踪用户的location更新   Track User's Location Updates
    MAUserTrackingModeFollowWithHeading = 2     ///< 追踪用户的location与heading更新   Track user's location and heading updates
};

///交通拥堵状态
///Traffic congestion status
typedef NS_ENUM(NSInteger, MATrafficStatus)
{
    MATrafficStatusSmooth = 1,                  ///< 1 通畅   Smooth
    MATrafficStatusSlow,                        ///< 2 缓行   Slow-moving
    MATrafficStatusJam,                         ///< 3 阻塞   Blocked
    MATrafficStatusSeriousJam,                  ///< 4 严重阻塞   Severely blocked
    MATrafficStatusExtremelySmooth,             ///< 5 极度通畅   Extremely smooth
};

///绘制overlay的层级
///Draw overlay layers
typedef NS_ENUM(NSInteger, MAOverlayLevel) {
    MAOverlayLevelAboveRoads = 0,   ///< 在地图底图标注和兴趣点图标之下绘制overlay   Draw overlay below map base annotations and POI icons
    MAOverlayLevelAboveLabels       ///< 在地图底图标注和兴趣点图标之上绘制overlay   Draw overlay on top of map base annotations and POI icons
};

#pragma mark - 动画相关的key Animation-related key
///中心点(MAMapPoint)key, 封装成[NSValue valueWithMAMapPoint:]
///Center point (MAMapPoint) key, encapsulated as [NSValue valueWithMAMapPoint:]
extern NSString * const kMAMapLayerCenterMapPointKey;

///缩放级别key, 范围[minZoomLevel, maxZoomLevel], 封装成NSNumber
///Zoom level key, range [minZoomLevel, maxZoomLevel], encapsulated as NSNumber
extern NSString * const kMAMapLayerZoomLevelKey;

///旋转角度key, 范围[0, 360), 封装成NSNumber
///Rotation angle key, range [0, 360), encapsulated as NSNumber
extern NSString * const kMAMapLayerRotationDegreeKey;

///摄像机俯视角度, 范围[0, 45], 封装成NSNumber
///Camera tilt angle, range [0, 45], encapsulated as NSNumber
extern NSString * const kMAMapLayerCameraDegreeKey;


@protocol MAMapViewDelegate;

@interface MAMapView : UIView

///标记是否开启metal，默认NO.  注意：因机型或系统限制(要求机型最低5S,系统最低iOS10)，开启metal可能失败。
///Flag indicating whether to enable metal, default is NO. Note: Due to device or system limitations (minimum device requirement: 5S, minimum iOS version: iOS10), enabling metal may fail.
@property (nonatomic, assign, class) BOOL metalEnabled;

///是否打开地形图，默认NO.  注意：需在地图创建前设置 （since 8.2.0）
///Whether to enable the terrain map, default is NO. Note: It needs to be set before the map is created.（since 8.2.0）
@property (nonatomic, assign, class) BOOL terrainEnabled;

///是否有地形图授权，默认YES.  如果没有授权会回调MAMapViewDelegate的 - (void)mapView:(MAMapView *)mapView didFailLoadTerrainWithError:(NSError *)error 方法 （since 9.3.1）
///Whether there is terrain map authorization, default is YES. If there is no authorization, the - (void)mapView:(MAMapView *)mapView didFailLoadTerrainWithError:(NSError *)error method of MAMapViewDelegate will be called back. （since 9.3.1）
@property (nonatomic, assign, readonly) BOOL terrainAuth;

///地图view的delegate
///Delegate of the map view
@property (nonatomic, weak) id<MAMapViewDelegate> delegate;

///地图类型。注意：自定义样式优先级高于mapType，如开启了自定义样式，要关闭自定义样式后mapType才生效
///Map type. Note: Custom styles take precedence over mapType. If a custom style is enabled, mapType will only take effect after the custom style is turned off.
@property (nonatomic) MAMapType mapType;

///当前地图的中心点，改变该值时，地图的比例尺级别不会发生变化
///The center point of the current map; when this value is changed, the scale level of the map will not change.
@property (nonatomic) CLLocationCoordinate2D centerCoordinate;

///当前地图的经纬度范围，设定的该范围可能会被调整为适合地图窗口显示的范围
///The latitude and longitude range of the current map, the set range may be adjusted to fit the display window of the map
@property (nonatomic) MACoordinateRegion region;

///可见区域, 设定的该范围可能会被调整为适合地图窗口显示的范围
///Visible area, the set range may be adjusted to fit the map window display
@property (nonatomic) MAMapRect visibleMapRect;

///设置可见地图区域的矩形边界，如限制地图只显示北京市范围
///Set the rectangular boundaries of the visible map area, such as limiting the map to display only the Beijing area
@property (nonatomic, assign) MACoordinateRegion limitRegion;

///设置可见地图区域的矩形边界，如限制地图只显示北京市范围
///Set the rectangular boundaries of the visible map area, such as limiting the map to display only the Beijing area
@property (nonatomic, assign) MAMapRect limitMapRect;

///缩放级别（默认3-19，有室内地图时为3-20）
///Zoom level (default 3-19, 3-20 when indoor maps are available)
@property (nonatomic) CGFloat zoomLevel;

///最小缩放级别
///Minimum zoom level
@property (nonatomic) CGFloat minZoomLevel;

///最大缩放级别（有室内地图时最大为20，否则为19）
///Maximum zoom level (20 when indoor maps are available, otherwise 19)
@property (nonatomic) CGFloat maxZoomLevel;

///设置地图旋转角度(逆时针为正向)
///Set map rotation angle (counterclockwise is positive)
@property (nonatomic) CGFloat rotationDegree;

///设置地图相机角度(范围为[0.f, 60.f]，但高于40度的角度需要在16级以上才能生效)
///Set the map camera angle (range is [0.f, 60.f], but angles above 40 degrees require level 16 or higher to take effect)
@property (nonatomic) CGFloat cameraDegree;

///是否以screenAnchor点作为锚点进行缩放，默认为YES。如果为NO，则以手势中心点作为锚点
///Whether to use the screenAnchor point as the anchor for scaling, default is YES. If NO, the gesture center point is used as the anchor.
@property (nonatomic, assign) BOOL zoomingInPivotsAroundAnchorPoint;

///是否支持缩放, 默认YES
///Whether to support zoom, default YES
@property (nonatomic, getter = isZoomEnabled) BOOL zoomEnabled;

///是否支持平移, 默认YES
///Whether to support pan, default YES
@property (nonatomic, getter = isScrollEnabled) BOOL scrollEnabled;

///是否支持旋转, 默认YES
///Whether rotation is supported, default YES
@property (nonatomic, getter = isRotateEnabled) BOOL rotateEnabled;

///是否支持camera旋转, 默认YES
///Whether camera rotation is supported, default YES
@property (nonatomic, getter = isRotateCameraEnabled) BOOL rotateCameraEnabled;

///是否显示楼块，默认为YES
///Whether to show building blocks, default YES
@property (nonatomic, getter = isShowsBuildings) BOOL showsBuildings;

///是否显示底图标注, 默认为YES
///Whether to show basemap labels, default YES
@property (nonatomic, assign, getter = isShowsLabels) BOOL showsLabels;

///是否显示交通路况图层, 默认为NO
///Whether to display the traffic layer, default is NO
@property (nonatomic, getter = isShowTraffic) BOOL showTraffic;

///设置实时交通颜色,key为 MATrafficStatus
///set real-time traffic color, key is MATrafficStatus
@property (nonatomic, copy) NSDictionary <NSNumber *, UIColor *> *trafficStatus __attribute((deprecated("Deprecated since 7.8.0")));

///是否支持单击地图获取POI信息(默认为YES), 对应的回调是 -(void)mapView:(MAMapView *) didTouchPois:(NSArray *)
///Is it possible to click on the map to get POI information (default is YES), the corresponding callback is -(void)mapView:(MAMapView *) didTouchPois:(NSArray *)
@property (nonatomic, assign) BOOL touchPOIEnabled;

///是否显示指南针, 默认YES
///whether to display the compass, default is YES
@property (nonatomic, assign) BOOL showsCompass;

///指南针原点位置
///compass origin position
@property (nonatomic, assign) CGPoint compassOrigin;

///指南针的宽高
///Compass width and height
@property (nonatomic, readonly) CGSize compassSize;

///是否显示比例尺, 默认YES
///Whether to display the scale bar, default is YES
@property (nonatomic, assign) BOOL showsScale;

///比例尺原点位置
///Scale bar origin position
@property (nonatomic, assign) CGPoint scaleOrigin;

///比例尺的最大宽高
///Maximum width and height of the scale bar
@property (nonatomic, readonly) CGSize scaleSize;

///logo位置, 必须在mapView.bounds之内，否则会被忽略
///Logo position, must be within mapView.bounds, otherwise it will be ignored
@property (nonatomic, assign) CGPoint logoCenter;

///logo的宽高
///The width and height of the logo
@property (nonatomic, readonly) CGSize logoSize;

///在当前缩放级别下, 基于地图中心点, 1 screen point 对应的距离(单位是米)
///At the current zoom level, based on the map center point, the distance corresponding to 1 screen point (in meters)
@property (nonatomic, readonly) double metersPerPointForCurrentZoom;

///标识当前地图中心位置是否在中国范围外。此属性不是精确判断，不能用于边界区域
///Indicates whether the current map center location is outside of China. This property is not an accurate judgment and should not be used for border areas.
@property (nonatomic, readonly) BOOL isAbroad;

///最大帧数，有效的帧数为：60、30、20、10等能被60整除的数。默认为60
///Maximum frame rate, valid frame rates are numbers divisible by 60 such as 60, 30, 20, 10. Default is 60
@property (nonatomic, assign) NSUInteger maxRenderFrame;

///是否允许降帧，默认为YES
///Whether to allow frame rate reduction, default is YES
@property (nonatomic, assign) BOOL isAllowDecreaseFrame;

///停止/开启 OpenGLES绘制, 默认NO. 对应回调是 - (void)mapView:(MAMapView *) didChangeOpenGLESDisabled:(BOOL)
///Stop/Start OpenGLES rendering, default NO. The corresponding callback is - (void)mapView:(MAMapView *) didChangeOpenGLESDisabled:(BOOL)
@property (nonatomic, assign) BOOL openGLESDisabled __attribute((deprecated("Deprecated, since 7.9.0, please use the renderringDisabled property")));

///停止/开启 地图绘制, 默认NO.
///Stop/Start map drawing, default NO
@property (nonatomic, assign) BOOL renderringDisabled;

///地图的视图锚点。坐标系归一化，(0, 0)为MAMapView左上角，(1, 1)为右下角。默认为(0.5, 0.5)，即当前地图的视图中心 （since 5.0.0）
///The anchor point of the map view. The coordinate system is normalized, (0, 0) is the top-left corner of MAMapView, (1, 1) is the bottom-right corner. Default is (0.5, 0.5), which is the center of the current map view.（since 5.0.0）
@property (nonatomic, assign) CGPoint screenAnchor;

///地图渲染的runloop mode，默认为NSRunLoopCommonModes。如果是和UIScrollView一起使用且不希望地图在scrollView拖动时渲染，请设置此值为NSDefaultRunLoopMode。（since 5.1.0）
///The runloop mode for map rendering, default is NSRunLoopCommonModes. If used with UIScrollView and you don't want the map to render during scrollView dragging, set this value to NSDefaultRunLoopMode.（since 5.1.0）
@property (nonatomic, copy) NSRunLoopMode runLoopMode;

///设置语言。中文:@0: 英文:@1. 英文使用注意事项：1、不能和自定义地图样式同时使用；2、英文状态只在MAMapTypeStandard生效
///Set language. Chinese:@0: English:@1. Notes for English usage: 1. Cannot be used with custom map styles simultaneously; 2. English mode only takes effect in MAMapTypeStandard
#if MA_INCLUDE_WORLD_EN_MAP
@property (nonatomic, strong) NSNumber *mapLanguage;
#endif

///语言类型
///language type
@property (nonatomic, assign, class) AMapRegionLanguageType regionLanguageType;

/// 是否显示国际图
/// Whether to display the international map
@property (nonatomic, assign, class) BOOL loadWorldVectorMap;

/**
 * @brief 导航模式下初始化地图，当需要将地图传给导航SDK时，请使用此方法创建地图，并设置isNavi为YES
 * Initialize the map in navigation mode. When you need to pass the map to the navigation SDK, use this method to create the map and set isNavi to YES
 * @param frame 地图 frame
 * map frame
 * @param isNavi 是否是导航模式
 * whether it is in navigation mode
 */
- (instancetype)initWithFrame:(CGRect)frame isNavi:(BOOL)isNavi;

/**
 * @brief 强制指定scaleFactor方式来初始化地图，原initWithFrame:方法自动根据系统scale初始化
 * @param frame 如系统initWithFrame:参数
 * @param scaleFactor 强制指定屏幕scaleFactor.0.0是走系统默认值,非0值生效。支持范围是[0-3]
 * since 10.5.2.03
 */
- (instancetype)initWithFrame:(CGRect)frame scaleFactor:(CGFloat)scaleFactor;
 

/**
 * @brief 设定当前地图的经纬度范围，该范围可能会被调整为适合地图窗口显示的范围
 * Set the latitude and longitude range of the current map, which may be adjusted to fit the map window
 * @param region 要设定的经纬度范围
 * The latitude and longitude range to be set
 * @param animated 是否动画设置
 * Whether to set animation
 */
- (void)setRegion:(MACoordinateRegion)region animated:(BOOL)animated;

/**
 * @brief 根据当前地图视图frame的大小调整region范围
 * Adjust the region range according to the size of the current map view frame
 * @param region 要调整的经纬度范围
 * The latitude and longitude range to be adjusted
 * @return 调整后的经纬度范围
 * The adjusted latitude and longitude range
 */
- (MACoordinateRegion)regionThatFits:(MACoordinateRegion)region;

/**
 * @brief 设置可见区域
 * Set the visible region
 * @param mapRect 要设定的可见区域
 * The visible region to be set
 * @param animated 是否动画设置
 * Whether to set animation
 */
- (void)setVisibleMapRect:(MAMapRect)mapRect animated:(BOOL)animated;

/**
 * @brief 重新计算可见地图矩形区域,使之匹配mapview长宽比
 * Recalculate the visible map rectangle area to match the mapview aspect ratio
 * @param mapRect 要调整的地图矩形区域
 * the map rectangle area to be adjusted
 * @return 调整后的地图矩形区域
 * the adjusted map rectangle area
 */
- (MAMapRect)mapRectThatFits:(MAMapRect)mapRect;

/**
 * @brief 根据边缘插入来调整地图矩形区域，使之匹配mapview加insets后的长宽比
 * Adjust the map rectangular area according to the edge insertion to match the aspect ratio of the mapview with insets
 * @param mapRect 要调整的地图矩形区域
 * the map rectangular area to be adjusted
 * @param insets 边缘插入
 * edge insertion
 * @return 调整后的地图矩形区域
 * the adjusted map rectangle area
 */
- (MAMapRect)mapRectThatFits:(MAMapRect)mapRect edgePadding:(UIEdgeInsets)insets;

/**
 * @brief 设置可见地图矩形区域
 * Set visible map rectangle area
 * @param insets 边缘插入
 * edge insertion
 * @param mapRect 要显示的地图矩形区域
 * The map rectangle area to display
 * @param animated 是否动画效果
 * Whether to enable animation
 */
- (void)setVisibleMapRect:(MAMapRect)mapRect edgePadding:(UIEdgeInsets)insets animated:(BOOL)animated;

/**
 * @brief 设置可见地图矩形区域
 * Set visible map rectangle area
 * @param insets 边缘插入
 * edge insertion
 * @param mapRect 要显示的地图矩形区域
 * The map rectangle area to display
 * @param animated 是否动画效果
 * Whether to enable animation
 * @param duration 动画时长，单位秒
 * Animation duration in seconds
 */
- (void)setVisibleMapRect:(MAMapRect)mapRect edgePadding:(UIEdgeInsets)insets animated:(BOOL)animated duration:(CFTimeInterval)duration;

/**
 * @brief 设置当前地图的中心点，改变该值时，地图的比例尺级别不会发生变化
 * Set the center point of the current map. When this value is changed, the scale level of the map will not change
 * @param coordinate 要设置的中心点
 * The center point to set
 * @param animated 是否动画设置
 * Whether to animate the setting
 */
- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;

/**
 * @brief 设置缩放级别（默认3-19，有室内地图时为3-20）
 * Set the zoom level (default 3-19, 3-20 when indoor maps are available)
 * @param zoomLevel 要设置的缩放级别
 * The zoom level to be set
 * @param animated 是否动画设置
 * Whether to animate the setting
 */
- (void)setZoomLevel:(CGFloat)zoomLevel animated:(BOOL)animated;

/**
 * @brief 根据指定的枢纽点来缩放地图
 * Zoom the map based on the specified pivot point
 * @param zoomLevel 缩放级别
 * Zoom level
 * @param pivot 枢纽点(基于地图view的坐标系)
 * Pivot point (based on the map view coordinate system)
 * @param animated 是否动画
 * Whether to animate
 */
- (void)setZoomLevel:(CGFloat)zoomLevel atPivot:(CGPoint)pivot animated:(BOOL)animated;

/**
 * @brief 设置地图旋转角度(逆时针为正向)
 * Set the map rotation angle (counterclockwise is positive)
 * @param rotationDegree 旋转角度, 如当前角度是0，720表示逆时针旋转2周，-720表示正时针旋转2周
 * Rotation angle, if the current angle is 0, 720 means rotating counterclockwise for 2 rounds, -720 means rotating clockwise for 2 rounds
 * @param animated 动画
 * Animation
 * @param duration 动画时间
 * Animation duration
 */
- (void)setRotationDegree:(CGFloat)rotationDegree animated:(BOOL)animated duration:(CFTimeInterval)duration;

/**
 * @brief 设置地图相机角度(范围为[0.f, 60.f]，但高于40度的角度需要在16级以上才能生效)
 * Set map camera angle (range [0.f, 60.f], but angles above 40 degrees require level 16 or higher to take effect)
 * @param cameraDegree 要设置的相机角度
 * Camera angle to set
 * @param animated 是否动画
 * Whether to animate
 * @param duration 动画时间
 * Animation duration
 */
- (void)setCameraDegree:(CGFloat)cameraDegree animated:(BOOL)animated duration:(CFTimeInterval)duration;

/**
 * @brief 获取地图状态
 * Get map status
 * @return 地图状态
 * Map status
 */
- (MAMapStatus *)getMapStatus;


/**
 * @brief 设置地图状态
 * Set map status
 * @param status 要设置的地图状态
 * Map status to be set
 * @param animated 是否动画
 * Whether to animate
 */
- (void)setMapStatus:(MAMapStatus *)status animated:(BOOL)animated;

/**
 * @brief 设置地图状态
 * Set map status
 * @param status 要设置的地图状态
 * Map status to be set
 * @param animated 是否动画
 * Whether to animate
 * @param duration 动画时间，默认动画时间为0.35s
 * Animation time, default animation time is 0.35s
 */
- (void)setMapStatus:(MAMapStatus *)status
            animated:(BOOL)animated
            duration:(CFTimeInterval)duration;

/**
 * @brief 设置指南针的图片
 * Set compass image
 * @param image 新的指南针图片
 * New compass image
 */
- (void)setCompassImage:(UIImage *)image;

/**
 * @brief 在指定区域内截图(默认会包含该区域内的annotationView),注意不要在地图回调方法内直接调用
 * Take screenshot in specified area (annotationView within the area will be included by default). Note: Do not call directly within map callback methods
 * @param rect 指定的区域
 * Specified area
 * @return 截图image
 * Screenshot image
 */
- (UIImage *)takeSnapshotInRect:(CGRect)rect __attribute((deprecated("Deprecated, please use the takeSnapshotInRect:withCompletionBlock: method since 6.0.0")));

/**
 * @brief 异步在指定区域内截图(默认会包含该区域内的annotationView), 地图载入完整时回调
 * Asynchronously capture a screenshot within the specified area (by default includes the annotationView within that area), callback when the map is fully loaded
 * @param rect 指定的区域
 * Specified area
 * @param block 回调block(resultImage:返回的图片,state：0载入不完整，1完整）
 * Callback block(resultImage: returned image, state: 0 incomplete loading, 1 complete)
 */
- (void)takeSnapshotInRect:(CGRect)rect withCompletionBlock:(void (^)(UIImage *resultImage, NSInteger state))block;

/**
 * @brief 异步在指定区域内截图(默认会包含该区域内的annotationView), 地图载入完整时回调 (since 7.8.0)
 * Asynchronously capture a screenshot within the specified area (by default includes the annotationView within the area), callback when the map is fully loaded (since 7.8.0)
 * @param rect 指定的区域
 * Specified area
 * @param timeout 超时时间
 * timeout
 * @param block 回调block(resultImage:返回的图片,state：0载入不完整，1完整）
 * Callback block(resultImage: returned image, state: 0 incomplete loading, 1 complete)
 */
- (void)takeSnapshotInRect:(CGRect)rect timeoutInterval:(NSTimeInterval)timeout completionBlock:(void (^)(UIImage *resultImage, NSInteger state))block;

/**
 * @brief 在指定的缩放级别下, 基于地图中心点, 1 screen point 对应的距离(单位是米).
 * At a specified zoom level, based on the map center point, the distance corresponding to 1 screen point (in meters)
 * @param zoomLevel 指定的缩放级别, 在[minZoomLevel, maxZoomLevel]范围内.
 * the specified zoom level is within the [minZoomLevel, maxZoomLevel] range.
 * @return 对应的距离(单位是米)
 * Corresponding distance (unit is meters)
 */
- (double)metersPerPointForZoomLevel:(CGFloat)zoomLevel;

/**
 * @brief 将经纬度转换为指定view坐标系的坐标
 * Convert latitude and longitude to coordinates in the specified view coordinate system
 * @param coordinate 经纬度
 * Latitude and longitude
 * @param view 指定的view
 * Specified view
 * @return 基于指定view坐标系的坐标
 * Coordinates based on the specified view coordinate system
 */
- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(UIView *)view;

/**
 * @brief 将指定view坐标系的坐标转换为经纬度
 * Convert coordinates in the specified view coordinate system to latitude and longitude
 * @param point 指定view坐标系的坐标
 * Coordinates in the specified view coordinate system
 * @param view 指定的view
 * Specified view
 * @return 经纬度
 * Latitude and longitude
 */
- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(UIView *)view;

/**
 * @brief 将经纬度region转换为指定view坐标系的rect
 * Convert latitude and longitude region to rect in the specified view coordinate system
 * @param region 经纬度region
 * Latitude and longitude region
 * @param view 指定的view
 * Specified view
 * @return 指定view坐标系的rect
 * Specify the rect of the view coordinate system
 */
- (CGRect)convertRegion:(MACoordinateRegion)region toRectToView:(UIView *)view;

/**
 * @brief 将指定view坐标系的rect转换为经纬度region
 * Convert the rect of the specified view coordinate system to a latitude and longitude region
 * @param rect 指定view坐标系的rect
 * Specify the rect of the view coordinate system
 * @param view 指定的view
 * Specified view
 * @return 经纬度region
 * Latitude and longitude region
 */
- (MACoordinateRegion)convertRect:(CGRect)rect toRegionFromView:(UIView *)view;

/**
 * @brief 重新加载地图 
 * Reload the map
 *
 * 将离线地图解压到 Documents/3dvmap/ 目录下后，调用此函数使离线数据生效,
 * After extracting the offline map to the Documents/3dvmap/ directory, call this function to activate the offline data.
 * 对应的回调分别是 offlineDataWillReload:(MAMapView *)mapView, offlineDataDidReload:(MAMapView *)mapView.
 * The corresponding callbacks are offlineDataWillReload:(MAMapView *)mapView, offlineDataDidReload:(MAMapView *)mapView.
 */
- (void)reloadMap;

/**
 * @brief 清除所有磁盘上缓存的地图数据(不包括离线地图)
 * Clear all cached map data on disk (excluding offline maps)
 */
- (void)clearDisk;

/**
 * @brief 重新加载内部纹理，在纹理被错误释放时可以执行此方法。（since 5.4.0）
 * Reload internal textures, this method can be executed when textures are incorrectly released.（since 5.4.0）
 */
- (void)reloadInternalTexture;
 
/**
 * @brief 获取地图审图号。如果启用了“自定义样式”功能(customMapStyleEnabled 为 YES)，则返回nil。（since 5.4.0）
 * Obtain the map approval number. If the 'Custom Style' feature is enabled (customMapStyleEnabled is YES), return nil.（since 5.4.0）
 * @return 地图审图号
 * Map approval number
 */
- (NSString *)mapContentApprovalNumber;

/**
 * @brief 获取卫星图片审图号。（since 5.4.0）
 * Obtain satellite image approval number （since 5.4.0）
 * @return 卫星图片审图号
 * Satellite image approval number
 */
- (NSString *)satelliteImageApprovalNumber;

/**
 * @brief 获取地形图审图号。（since 8.2.0）
 * Obtain topographic map approval number（since 8.2.0）
 * @return 地形图审图号
 * Topographic map approval number
 */
- (NSString *)terrainApprovalNumber;

/**
 * @brief 添加CAKeyframeAnimation动画。（since 6.0.0）
 * Add CAKeyframeAnimation（since 6.0.0）
 * @param mapCenterAnimation 地图中心点动画
 * Map center point animation
 * @param zoomAnimation 放大缩小动画
 * Zoom in/out animation
 * @param rotateAnimation 旋转动画
 * Rotation animation
 * @param cameraDegreeAnimation 仰角动画
 * Elevation animation
 */
- (void)addAnimationWith:(CAKeyframeAnimation *)mapCenterAnimation
           zoomAnimation:(CAKeyframeAnimation *)zoomAnimation
         rotateAnimation:(CAKeyframeAnimation *)rotateAnimation
   cameraDegreeAnimation:(CAKeyframeAnimation *)cameraDegreeAnimation;

/**
 * @brief 强制刷新。（since 6.0.0）
 * Force refresh
 */
- (void)forceRefresh;

/**
 * @brief 设置在建道路图层是否显示。默认NO（since 7.7.0）
 * Set whether the road under construction layer is displayed. Default NO（since 7.7.0）
 * @param enabled 是否显示
 * Whether to display
 */
- (void)setConstructingRoadEnable:(BOOL)enabled;

- (void)setMapOptRecordState:(BOOL)state;
#pragma mark - Privacy 隐私合规 Privacy compliance
/**
 * @brief 更新App是否显示隐私弹窗的状态，隐私弹窗是否包含高德SDK隐私协议内容的状态. 注意：必须在MAMapView实例化之前调用 since 8.1.0
 * Update the status of whether the app displays a privacy popup and whether the popup includes the content of the Amap SDK privacy agreement. Note: This must be called before the MAMapView is instantiated.   since 8.1.0
 * @param showStatus 隐私弹窗状态
 * Privacy pop-up status
 * @param containStatus 包含高德SDK隐私协议状态
 * includes the status of the AMap SDK privacy agreement
 */
+ (void)updatePrivacyShow:(AMapPrivacyShowStatus)showStatus privacyInfo:(AMapPrivacyInfoStatus)containStatus;
/**
 * @brief 更新用户授权高德SDK隐私协议状态. 注意：必须在MAMapView实例化之前调用 since 8.1.0
 * Updates the user's authorization status for the AMap SDK privacy agreement. Note: Must be called before the instantiation of MAMapView.    since 8.1.0
 * @param agreeStatus 用户授权高德SDK隐私协议状态
 * User authorization status of the AMap SDK privacy agreement
*/
+ (void)updatePrivacyAgree:(AMapPrivacyAgreeStatus)agreeStatus;

@end

@interface MAMapView (Annotation)

///所有添加的标注, 注意从5.3.0开始返回数组内不再包含定位蓝点userLocation
///All added annotations, note that from version 5.3.0 the returned array no longer includes the location blue dot userLocation
@property (nonatomic, readonly) NSArray *annotations;

///处于选中状态的标注数据数据(其count == 0 或 1)
///Annotation data in selected state (where count == 0 or 1)
@property (nonatomic, copy) NSArray *selectedAnnotations;

///annotation 可见区域
///annotation visible area
@property (nonatomic, readonly) CGRect annotationVisibleRect;

/**
 * @brief 向地图窗口添加标注，需要实现MAMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
 * To add annotations to the map window, you need to implement the -mapView:viewForAnnotation: function of MAMapViewDelegate to generate the corresponding view for the annotation
 * @param annotation 要添加的标注
 * Annotation to be added
 */
- (void)addAnnotation:(id <MAAnnotation>)annotation;

/**
 * @brief 向地图窗口添加一组标注，需要实现MAMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
 * To add a set of annotations to the map window, you need to implement the -mapView:viewForAnnotation: function of MAMapViewDelegate to generate the corresponding view for the annotation
 * @param annotations 要添加的标注数组
 * Array of annotations to add
 */
- (void)addAnnotations:(NSArray *)annotations;

/**
 * @brief 移除标注
 * Remove annotation
 * @param annotation 要移除的标注
 * Annotation to remove
 */
- (void)removeAnnotation:(id <MAAnnotation>)annotation;

/**
 * @brief 移除一组标注
 * Remove a group of annotations
 * @param annotations 要移除的标注数组
 * Array of annotations to remove
 */
- (void)removeAnnotations:(NSArray *)annotations;

/**
 * @brief 获取指定投影矩形范围内的标注
 * Get annotations within the specified projected rectangle
 * @param mapRect 投影矩形范围
 * Projected rectangle bounds
 * @return 标注集合
 * Annotation collection
 */
- (NSSet *)annotationsInMapRect:(MAMapRect)mapRect;

/**
 * @brief 根据标注数据获取标注view
 * Get annotation view from annotation data
 * @param annotation 标注数据
 * Annotation data
 * @return 对应的标注view
 * Corresponding annotation view
 */
- (MAAnnotationView *)viewForAnnotation:(id <MAAnnotation>)annotation;

/**
 * @brief 从复用内存池中获取制定复用标识的annotation view
 * Retrieve annotation view with specified reuse identifier from reuse memory pool
 * @param identifier 复用标识
 * Reuse identifier
 * @return annotation view
 * annotation view
 */
- (MAAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier;

/**
 * @brief 选中标注数据对应的view。注意：如果annotation对应的annotationView因不在屏幕范围内而被移入复用池，为了完成选中操作，会将对应的annotationView添加到地图上，并将地图中心点移至annotation.coordinate的位置。
 * Select the view corresponding to the annotation data. Note: If the annotationView corresponding to the annotation is moved into the reuse pool because it is not within the screen range,To complete the selection operation, the corresponding annotationView will be added to the map, and the center point of the map will be moved to the position of annotation.coordinate.
 * @param annotation 标注数据
 * Annotation data
 * @param animated 是否有动画效果
 * Whether there is an animation effect
 */
- (void)selectAnnotation:(id <MAAnnotation>)annotation animated:(BOOL)animated;

/**
 * @brief 取消选中标注数据对应的view
 * Deselect the view corresponding to the annotation data
 * @param annotation 标注数据
 * Annotation data
 * @param animated 是否有动画效果
 * Whether there is an animation effect
 */
- (void)deselectAnnotation:(id <MAAnnotation>)annotation animated:(BOOL)animated;

/**
 * @brief 设置地图使其可以显示数组中所有的annotation, 如果数组中只有一个则直接设置地图中心为annotation的位置。
 * Configure the map to display all annotations in the array. If there is only one annotation in the array, directly set the map center to the location of the annotation.
 * @param annotations 需要显示的annotation
 * Annotation to be displayed
 * @param animated    是否执行动画
 * Whether to execute the animation
 */
- (void)showAnnotations:(NSArray *)annotations animated:(BOOL)animated;

/**
 * @brief 设置地图使其可以显示数组中所有的annotation, 如果数组中只有一个则直接设置地图中心为annotation的位置。
 * Configure the map to display all annotations in the array. If there is only one annotation in the array, directly set the map center to the location of the annotation.
 * @param annotations 需要显示的annotation
 * Annotation to be displayed
 * @param insets      insets 嵌入边界
 * insets embedded boundary
 * @param animated    是否执行动画
 * Whether to execute the animation
 */
- (void)showAnnotations:(NSArray *)annotations edgePadding:(UIEdgeInsets)insets animated:(BOOL)animated;

@end


@interface MAMapView (UserLocation)

///是否显示用户位置
///Whether to display user location
@property (nonatomic) BOOL showsUserLocation;

///当前的位置数据
///Current location data
@property (nonatomic, readonly) MAUserLocation *userLocation;

///是否自定义用户位置精度圈(userLocationAccuracyCircle)对应的 view, 默认为 NO.\n 如果为YES: 会调用 - (MAOverlayRenderer *)mapView (MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay 若返回nil, 则不加载.\n 如果为NO : 会使用默认的样式.
///Whether to customize the view corresponding to the user location accuracy circle (userLocationAccuracyCircle), default is NO.\n If YES: it will call - (MAOverlayRenderer *)mapView (MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay, if it returns nil, it will not be loaded.\n If NO: the default style will be used.
@property (nonatomic) BOOL customizeUserLocationAccuracyCircleRepresentation;

///用户位置精度圈 对应的overlay
///Overlay corresponding to user location accuracy circle
@property (nonatomic, readonly) MACircle *userLocationAccuracyCircle;

///定位用户位置的模式, 注意：在follow模式下，设置地图中心点、设置可见区域、滑动手势、选择annotation操作会取消follow模式，并触发 - (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated;
///User location tracking mode, Note: In follow mode, setting the map center point, setting the visible region, swipe gestures, or selecting an annotation will cancel follow mode and trigger - (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated;
@property (nonatomic) MAUserTrackingMode userTrackingMode;

///当前位置在地图中是否可见
///Whether the current location is visible on the map
@property (nonatomic, readonly, getter=isUserLocationVisible) BOOL userLocationVisible;

///设定定位的最小更新距离。默认为kCLDistanceFilterNone，会提示任何移动
///Set the minimum update distance for positioning. The default is kCLDistanceFilterNone, which will prompt any movement
@property (nonatomic) CLLocationDistance distanceFilter;

///设定定位精度。默认为kCLLocationAccuracyBest
///Set the positioning accuracy. The default is kCLLocationAccuracyBest
@property (nonatomic) CLLocationAccuracy desiredAccuracy;

///设定最小更新角度。默认为1度，设定为kCLHeadingFilterNone会提示任何角度改变
///Set the minimum update angle. The default is 1 degree, setting it to kCLHeadingFilterNone will prompt any angle change.
@property (nonatomic) CLLocationDegrees headingFilter;

///指定定位是否会被系统自动暂停
///Whether the specified positioning will be automatically paused by the system
@property (nonatomic) BOOL pausesLocationUpdatesAutomatically;

///是否允许后台定位。默认为NO。只在iOS 9.0之后起作用。\n 设置为YES的时候必须保证 Background Modes 中的 Location updates处于选中状态，否则会抛出异常。\n 注意：定位必须在停止的状态下设置（showsUserLocation = NO），否则无效
///Whether to allow background location. Default is NO. Only works after iOS 9.0.\n When set to YES, you must ensure that Location updates in Background Modes is selected, otherwise an exception will be thrown.\n Note: The location must be set in a stopped state (showsUserLocation = NO), otherwise it will be invalid.
@property (nonatomic) BOOL allowsBackgroundLocationUpdates;

/**
 * @brief 设置定位用户位置的模式
 * Set the mode for locating the user's position
 * @param mode 要设置的模式
 * the mode to be set
 * @param animated 是否动画设置
 * whether to animate the setting
 */
- (void)setUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated;

/**
 * @brief 设定UserLocationView样式。如果用户自定义了userlocation的annotationView，或者该annotationView还未添加到地图上，此方法将不起作用
 * Set the style of UserLocationView. If the user has customized the annotationView for userlocation, or if the annotationView has not been added to the map yet, this method will not work.
 * @param representation 样式信息对象
 * the style information object
 */
- (void)updateUserLocationRepresentation:(MAUserLocationRepresentation *)representation;

@end

@interface MAMapView (Overlay)

///所有添加的Overlay
///All added Overlays
@property (nonatomic, readonly) NSArray *overlays;

/**
 * @brief 取位于level下的overlays
 * Get overlays under level
 * @param level 层级
 * Level
 */
- (NSArray *)overlaysInLevel:(MAOverlayLevel)level;

/**
 * @brief 向地图窗口添加Overlay。
 * Add Overlay to the map window
 * 需要实现MAMapViewDelegate的-mapView:rendererForOverlay:函数来生成标注对应的Renderer。
 * Need to implement the -mapView:rendererForOverlay: function of MAMapViewDelegate to generate the corresponding Renderer for the annotation.
 * 默认添加层级：MAGroundOverlay默认层级为MAOverlayLevelAboveRoads，其余overlay类型默认层级为MAOverlayLevelAboveLabels
 * Default level for adding: MAGroundOverlay's default level is MAOverlayLevelAboveRoads, while other overlay types default to MAOverlayLevelAboveLabels.
 * @param overlay 要添加的overlay
 * Overlay to be added
 */
- (void)addOverlay:(id <MAOverlay>)overlay;

/**
 * @brief 向地图窗口添加一组Overlay，需要实现MAMapViewDelegate的-mapView:rendererForOverlay:函数来生成标注对应的Renderer
 * To add a set of Overlays to the map window, you need to implement the -mapView:rendererForOverlay: function of MAMapViewDelegate to generate the corresponding Renderer for the annotation
 * 默认添加层级：MAOverlayLevelAboveLabels
 * Default level for adding: MAOverlayLevelAboveLabels
 * @param overlays 要添加的overlay数组
 * Array of overlays to be added
 */
- (void)addOverlays:(NSArray *)overlays;

/**
 * @brief 向地图窗口添加Overlay，需要实现MAMapViewDelegate的-mapView:rendererForOverlay:函数来生成标注对应的Renderer
 * Add Overlay to the map window，need to implement the -mapView:rendererForOverlay: function of MAMapViewDelegate to generate the corresponding Renderer for the annotation.
 * @param overlay 要添加的overlay
 * Overlay to be added
 * @param level 添加的overlay所在层级
 * The level of the added overlay
 */
- (void)addOverlay:(id <MAOverlay>)overlay level:(MAOverlayLevel)level;

/**
 * @brief 向地图窗口添加一组Overlay，需要实现MAMapViewDelegate的-mapView:rendererForOverlay:函数来生成标注对应的Renderer
 * To add a set of Overlays to the map window，need to implement the -mapView:rendererForOverlay: function of MAMapViewDelegate to generate the corresponding Renderer for the annotation.
 * @param overlays 要添加的overlay数组
 * Array of overlays to be added
 * @param level 添加的overlay所在层级
 * The level of the added overlay
 */
- (void)addOverlays:(NSArray *)overlays level:(MAOverlayLevel)level;

/**
 * @brief 移除Overlay
 * Remove Overlay
 * @param overlay 要移除的overlay
 * The overlay to be removed
 */
- (void)removeOverlay:(id <MAOverlay>)overlay;

/**
 * @brief 移除一组Overlay
 * Remove a group of Overlays
 * @param overlays 要移除的overlay数组
 * The array of overlays to be removed
 */
- (void)removeOverlays:(NSArray *)overlays;

/**
 * @brief 在指定层级的指定的索引处添加一个Overlay
 * Add an overlay at the specified index of the specified level
 * @param overlay 要添加的overlay
 * Overlay to be added
 * @param index 指定的索引
 * Specified index
 * @param level Specified level
 
 * 注：各个层级的索引分开计数；
 * Note: The indexes of each level are counted separately
 * 若index大于level层级的最大索引，则添加至level层级的最大索引之后。
 * If the index is greater than the maximum index of the level, it will be added after the maximum index of the level
 */
- (void)insertOverlay:(id <MAOverlay>)overlay atIndex:(NSUInteger)index level:(MAOverlayLevel)level;

/**
 * @brief 在指定的Overlay之上插入一个overlay
 * Insert an overlay above the specified overlay
 * @param overlay 带添加的Overlay
 * Overlay with addition
 * @param sibling 用于指定相对位置的Overlay
 * Overlay for specifying relative position
 */
- (void)insertOverlay:(id <MAOverlay>)overlay aboveOverlay:(id <MAOverlay>)sibling;

/**
 * @brief 在指定的Overlay之下插入一个overlay
 * Insert an overlay below the specified overlay
 * @param overlay 带添加的Overlay
 * Overlay with addition
 * @param sibling 用于指定相对位置的Overlay
 * Overlay for specifying relative position
 */
- (void)insertOverlay:(id <MAOverlay>)overlay belowOverlay:(id <MAOverlay>)sibling;

/**
 * @brief 在指定的索引处添加一个Overlay
 * Add an Overlay at the specified index
 * @param overlay 要添加的overlay
 * Overlay to be added
 * @param index 指定的索引
 * the specified index
 */
- (void)insertOverlay:(id <MAOverlay>)overlay atIndex:(NSUInteger)index;

/**
 * @brief 在MAOverlayLevelAboveLabels上交换指定索引处的Overlay
 * swap the Overlay at the specified index on MAOverlayLevelAboveLabels
 * @param index1 索引1
 * index 1
 * @param index2 索引2
 * index 2
 */
- (void)exchangeOverlayAtIndex:(NSUInteger)index1 withOverlayAtIndex:(NSUInteger)index2;

/**
 * @brief 交换指定索引处的Overlay
 * Swap Overlay at specified index
 * @param index1 索引1
 * index 1
 * @param index2 索引2
 * index 2
 * @param level 所处层级
 * Current hierarchy level
 */
- (void)exchangeOverlayAtIndex:(NSUInteger)index1 withOverlayAtIndex:(NSUInteger)index2 atLevel:(MAOverlayLevel)level;

/**
 * @brief 交换两个overlay
 * Swap two overlays
 * @param overlay1 overlay1
 * @param overlay2 overlay2
 */
- (void)exchangeOverlay:(id <MAOverlay>)overlay1 withOverlay:(id <MAOverlay>)overlay2;

/**
 * @brief 查找指定overlay对应的Renderer，如果该View尚未创建，返回nil
 * Find the Renderer corresponding to the specified overlay, returns nil if the View has not been created
 * @param overlay 指定的overlay
 * Specify the overlay
 * @return 指定overlay对应的Renderer
 * Specify the Renderer corresponding to the overlay
 */
- (MAOverlayRenderer *)rendererForOverlay:(id <MAOverlay>)overlay;

/**
 * @brief 设置地图使其可以显示数组中所有的overlay, 如果数组中只有一个则直接设置地图中心为overlay的位置。
 * Set the map to display all overlays in the array, if there is only one in the array, directly set the map center to the location of the overlay.
 * @param overlays    需要显示的overlays
 * Overlays to be displayed
 * @param animated    是否执行动画
 * whether to execute animation
 */
- (void)showOverlays:(NSArray *)overlays animated:(BOOL)animated;

/**
 * @brief 设置地图使其可以显示数组中所有的overlay, 如果数组中只有一个则直接设置地图中心为overlay的位置。
 * Set the map to display all overlays in the array, if there is only one in the array, directly set the map center to the location of the overlay.
 * @param overlays    需要显示的overlays
 * Overlays to be displayed
 * @param insets      insets 嵌入边界
 * insets embedded boundaries
 * @param animated    是否执行动画
 * whether to execute animation
 */
- (void)showOverlays:(NSArray *)overlays edgePadding:(UIEdgeInsets)insets animated:(BOOL)animated;

/**
 * @brief 获取点击选中的polylineRenderer, 注意：开启polylineRenderer的点击选中功能，需设置userInteractionEnabled=YES。since 7.1.0
 * obtain the selected polylineRenderer by clicking, note: to enable the click selection function of polylineRenderer, userInteractionEnabled=YES needs to be set.  since 7.1.0
 * @param tappedCoord   点击点的坐标
 * Coordinates of the clicked point
 * @param traverseAll   如果有polyline重合情况，是否返回多个。NO: 只返回最上面的 YES:返回所有
 * If there is an overlap of polylines, whether to return multiple. NO: Only return the topmost one YES: Return all
 * @return 返回选中的polylineRenderer数组，最上面的在第一个
 * Return the selected polylineRenderer array, with the topmost one first
 * */
- (NSArray*)getHittedPolylinesWith:(CLLocationCoordinate2D)tappedCoord traverseAll:(BOOL)traverseAll;

/**
 * @brief 多语言设置经纬度
 * Multilingual setting of latitude and longitude
 * @param location 位置
 * Location
 */
- (void)setCurrentLocation:(CLLocationCoordinate2D)location;
@end

#if MA_INCLUDE_INDOOR
@interface MAMapView (Indoor)

///是否显示室内地图, 默认NO
///Whether to display indoor maps, default NO
@property (nonatomic, getter = isShowsIndoorMap) BOOL showsIndoorMap;

///是否显示室内地图默认控件, 默认YES
///Whether to display the default indoor map controls, default YES
@property (nonatomic, getter = isShowsIndoorMapControl) BOOL showsIndoorMapControl;

///默认室内地图控件的最大宽高
///The maximum width and height of the default indoor map controls
@property (nonatomic, readonly) CGSize indoorMapControlSize;

/**
 * @brief 设置默认室内地图控件位置
 * Set the position of the default indoor map controls
 * @param origin 左上角点位置
 * The position of the top-left corner point
 */
- (void)setIndoorMapControlOrigin:(CGPoint)origin;

/**
 * @brief 设置当前室内地图楼层数
 * Set the current indoor map floor count
 * @param floorIndex 要设置的楼层数
 * Number of floors to set
 */
- (void)setCurrentIndoorMapFloorIndex:(NSInteger)floorIndex;

/**
 * @brief 清空室内地图缓存
 * Clear indoor map cache
 */
- (void)clearIndoorMapCache;

@end
#endif

///自定义样式
///Custom style
@interface MAMapView (CustomMapStyle)

///是否开启自定义样式, 默认NO. since 5.0.0
///Whether to enable custom style, default NO.   since 5.0.0
@property (nonatomic, assign) BOOL customMapStyleEnabled;

/**
 * @brief 自定义地图样式设置,可以支持分级样式配置，如控制不同级别显示不同的颜色(自7.0.0开始样式有更新，旧的样式文件不能继续使用，必须到官网重新导出新样式文件。 自6.6.0开始使用新版样式，旧版样式无法在新版接口setCustomMapStyleOptions:(MAMapCustomStyleOptions *)styleOptions中使用，请到官网(lbs.amap.com)更新新版样式文件.)
 * Custom map style settings support hierarchical style configurations, such as controlling different levels to display different colors (since version 7.0.0, the style has been updated, and old style files can no longer be used. You must re-export the new style file from the official website.From version 6.6.0, the new style is in use. The old style cannot be used in the new interface setCustomMapStyleOptions:(MAMapCustomStyleOptions *)styleOptions. Please update the new style file on the official website (lbs.amap.com).)
 * @param styleOptions 自定义样式options.  since 6.6.0
 * Custom style options.  since 6.6.0
 */
- (void)setCustomMapStyleOptions:(MAMapCustomStyleOptions *)styleOptions;

@end

/// 建筑物操作 @since 9.6.0
/// Building operations  since 9.6.0
@interface MAMapView (Buildings)

/**
 * @brief 隐藏建筑物
 * Hide buildings
 * @param polygon   围栏的经纬度信息
 * Fence's latitude and longitude information
 * @param polygonSize   围栏的size（需 >= 3 否则无法构成围栏）
 * Fence size (must be >=3 otherwise cannot form a fence)
 * @return 隐藏成功返回当前的operationId（>= 0） 失败返回-1
 * Returns current operationId (>=0) if successful, -1 if failed
 */
- (NSInteger)hideBuildingsWithPolygon:(CLLocationCoordinate2D *)polygon polygonSize:(NSUInteger)polygonSize;

/**
 * @brief 显示建筑物
 * Display buildings
 * @param operationId 操作Id（隐藏建筑物接口的返回值）
 * Operation ID (return value of the hide buildings interface)
 */
- (void)showHiddenBuildingsWithOperationId:(NSInteger)operationId;
@end

@interface MAMapView (EngineOverlay)

/**
 * @brief 向地图窗口添加Overlay。
 * Add Overlay to the map window
 * @param overlay 要添加的engine overlay
 * The engine overlay to be added
 */
- (void)addEngineOverlay:(MABaseEngineOverlay *)overlay;
@end

@interface MAMapView (PoiFilter)
/**
 * @brief 添加poi避让框
 * Add POI avoidance frame
 * @param poiFilter
 */
- (void)addPoiFilter:(MAPoiFilter *)poiFilter;
/**
 * @brief 移除poi避让框
 * Remove POI avoidance frame
 * @param keyName 名称
 * Name
 */
- (void)removePoiFilter:(NSString *)keyName;
/**
 * @brief 清除poi避让框
 * Clear POI avoidance frame
 */
- (void)clearPoiFilter;
@end

#pragma mark - MAMapViewDelegate
@protocol MAMapViewDelegate <NSObject>

@optional

/**
 * @brief 地图区域改变过程中会调用此接口 since 4.6.0
 * This interface will be called during the map region change process.   since 4.6.0
 * @param mapView 地图View
 * Map View
 */
- (void)mapViewRegionChanged:(MAMapView *)mapView;

/**
 * @brief 地图区域即将改变时会调用此接口
 * This interface will be called when the map region is about to change
 * @param mapView 地图View
 * Map View
 * @param animated 是否动画
 * Whether to animate
 */
- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated;

/**
 * @brief 地图区域改变完成后会调用此接口
 * This interface will be called after the map region change is completed
 * @param mapView 地图View
 * Map View
 * @param animated 是否动画
 * Whether to animate
 */
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated;

/**
 * @brief 地图区域即将改变时会调用此接口，如实现此接口则不会触发回掉mapView:regionWillChangeAnimated:
 * This interface will be called when the map region is about to change, and if this interface is implemented, the callback mapView:regionWillChangeAnimated: will not be triggered
 * @param mapView 地图View
 * Map View
 * @param animated 是否动画
 * Whether to animate
 * @param wasUserAction 标识是否是用户动作
 * Indicates whether it is a user action
 */
- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated wasUserAction:(BOOL)wasUserAction;

/**
 * @brief 地图区域改变完成后会调用此接口，如实现此接口则不会触发回掉mapView:regionDidChangeAnimated:
 * This interface will be called after the map region change is completed，and if this interface is implemented, the callback mapView:regionDidChangeAnimated: will not be triggered
 * @param mapView 地图View
 * Map View
 * @param animated 是否动画
 * Whether to animate
 * @param wasUserAction 标识是否是用户动作
 * Indicates whether it is a user action
 */
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated wasUserAction:(BOOL)wasUserAction;

/**
 * @brief 地图将要发生移动时调用此接口
 * This interface will be called when the map is about to move
 * @param mapView       地图view
 * Map view
 * @param wasUserAction 标识是否是用户动作
 * Identifies whether it is a user action
 */
- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction;

/**
 * @brief 地图移动结束后调用此接口
 * This interface will be called after the map movement ends
 * @param mapView       地图view
 * Map view
 * @param wasUserAction 标识是否是用户动作
 * Identifies whether it is a user action
 */
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction;

/**
 * @brief 地图将要发生缩放时调用此接口
 * This interface is called when the map is about to zoom
 * @param mapView       地图view
 * Map view
 * @param wasUserAction 标识是否是用户动作
 * Identifies whether it is a user action
 */
- (void)mapView:(MAMapView *)mapView mapWillZoomByUser:(BOOL)wasUserAction;

/**
 * @brief 地图缩放结束后调用此接口
 * This interface is called after the map zoom ends
 * @param mapView       地图view
 * Map view
 * @param wasUserAction 标识是否是用户动作
 * Identifies whether it is a user action
 */
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction;

/**
 * @brief 地图开始加载
 * The map starts loading
 * @param mapView 地图View
 * Map view
 */
- (void)mapViewWillStartLoadingMap:(MAMapView *)mapView;

/**
 * @brief 地图加载成功
 * The map is loaded successfully
 * @param mapView 地图View
 * Map view
 */
- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView;

/**
 * @brief 地图加载失败
 * The map fails to load
 * @param mapView 地图View
 * Map view
 * @param error 错误信息
 * Error message
 */
- (void)mapViewDidFailLoadingMap:(MAMapView *)mapView withError:(NSError *)error;

/**
 * @brief 地形图加载失败
 * Terrain map failed to load
 * @param mapView 地图View
 * Map view
 * @param error 错误信息
 * Error message
 */
- (void)mapView:(MAMapView *)mapView didFailLoadTerrainWithError:(NSError *)error;

/**
 * @brief 根据anntation生成对应的View。
 * Generate corresponding View based on annotation.
 
 注意：
 Note：
 1、5.1.0后由于定位蓝点增加了平滑移动功能，如果在开启定位的情况先添加annotation，需要在此回调方法中判断annotation是否为MAUserLocation，从而返回正确的View。
 if ([annotation isKindOfClass:[MAUserLocation class]]) {
    return nil;
 }
 After version 5.1.0, the positioning blue dot has added a smooth movement function. If you add an annotation while the positioning is turned on，it is necessary to determine whether the annotation is MAUserLocation in this callback method in order to return the correct View.
 if ([annotation isKindOfClass:[MAUserLocation class]]) {
    return nil;
 }
 
 2、请不要在此回调中对annotation进行select和deselect操作，此时annotationView还未添加到mapview。
 Please do not perform select or deselect operations on the annotation in this callback, as the annotationView has not been added to the mapView yet.
 
 * @param mapView 地图View
 * Map view
 * @param annotation 指定的标注
 * Specified annotation
 * @return 生成的标注View
 * Generated annotation View
 */
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation;

/**
 * @brief 当mapView新添加annotation views时，调用此接口
 * This interface is called when new annotation views are added to the mapView
 * @param mapView 地图View
 * Map view
 * @param views 新添加的annotation views
 * the newly added annotation views
 */
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views;

/**
 * @brief 当选中一个annotation view时，调用此接口. 注意如果已经是选中状态，再次点击不会触发此回调。取消选中需调用-(void)deselectAnnotation:animated:
 * This interface is called when an annotation view is selected. Note that if it is already in the selected state, clicking again will not trigger this callback. To deselect, call -(void)deselectAnnotation:animated:
 * @param mapView 地图View
 * Map view
 * @param view 选中的annotation view
 * On the selected annotation view
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view;

/**
 * @brief 当取消选中一个annotation view时，调用此接口
 * This interface is called when an annotation view is deselected
 * @param mapView 地图View
 * Map view
 * @param view 取消选中的annotation view
 * Deselect the annotation view
 */
- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view;

/**
 * @brief 在地图View将要启动定位时，会调用此函数
 * This function is called when the map view is about to start positioning
 * @param mapView 地图View
 * Map view
 */
- (void)mapViewWillStartLocatingUser:(MAMapView *)mapView;

/**
 * @brief 在地图View停止定位后，会调用此函数
 * This function will be called after the MapView stops locating
 * @param mapView 地图View
 * Map view
 */
- (void)mapViewDidStopLocatingUser:(MAMapView *)mapView;

/**
 * @brief 位置或者设备方向更新后，会调用此函数
 * This function will be called after the location or device orientation is updated
 * @param mapView 地图View
 * Map view
 * @param userLocation 用户定位信息(包括位置与设备方向等数据)
 * User location information (including location and device orientation data)
 * @param updatingLocation 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
 * Indicates whether it is a location data update, YES: location data update NO: heading data update
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation;

/**
 *  @brief 当plist配置NSLocationAlwaysUsageDescription或者NSLocationAlwaysAndWhenInUseUsageDescription，并且[CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined，会调用代理的此方法。
    此方法实现调用后台权限API即可（ 该回调必须实现 [locationManager requestAlwaysAuthorization] ）; since 6.8.0
 *    When the plist is configured with NSLocationAlwaysUsageDescription or NSLocationAlwaysAndWhenInUseUsageDescription, and [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined, this method of the delegate will be called. This method just needs to call the background permission API (this callback must implement [locationManager requestAlwaysAuthorization]); since 6.8.0
 *  @param locationManager  地图的CLLocationManager。
 *  Map's CLLocationManager
 */
- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager;

/**
 * @brief 定位失败后，会调用此函数
 * This function will be called after positioning failure
 * @param mapView 地图View
 * Map view
 * @param error 错误号，参考CLError.h中定义的错误号
 * Error code, refer to the error codes defined in CLError.h
 */
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error;

/**
 * @brief 拖动annotation view时view的状态变化
 * State changes of the annotation view during dragging
 * @param mapView 地图View
 * Map view
 * @param view annotation view
 * @param newState 新状态
 * New state
 * @param oldState 旧状态
 * Old state
 */
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState
   fromOldState:(MAAnnotationViewDragState)oldState;

/**
 * @brief 根据overlay生成对应的Renderer
 * Generate the corresponding Renderer based on the overlay
 * @param mapView 地图View
 * Map view
 * @param overlay 指定的overlay
 * the specified overlay
 * @return 生成的覆盖物Renderer
 * the generated overlay Renderer
 */
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay;

/**
 * @brief 当mapView新添加overlay renderers时，调用此接口
 * Call this interface when mapView adds new overlay renderers
 * @param mapView 地图View
 * Map view
 * @param overlayRenderers 新添加的overlay renderers
 * Newly added overlay renderers
 */
- (void)mapView:(MAMapView *)mapView didAddOverlayRenderers:(NSArray *)overlayRenderers;

/**
 * @brief 标注view的accessory view(必须继承自UIControl)被点击时，触发该回调
 * When the accessory view of the annotation view (must inherit from UIControl) is clicked, this callback is triggered
 * @param mapView 地图View
 * Map view
 * @param view callout所属的标注view
 * the annotation view to which the callout belongs
 * @param control 对应的control
 * Corresponding control
 */
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;

/**
 * @brief 标注view的calloutview整体点击时，触发该回调。只有使用默认calloutview时才生效。
 * Triggers this callback when the calloutView of the annotationView is clicked. Only takes effect when using the default calloutView
 * @param mapView 地图的view
 * Map view
 * @param view calloutView所属的annotationView
 * The annotationView to which the calloutView belongs
 */
- (void)mapView:(MAMapView *)mapView didAnnotationViewCalloutTapped:(MAAnnotationView *)view;

/**
 * @brief 标注view被点击时，触发该回调。（since 5.7.0）
 * When the annotation view is clicked, this callback is triggered （since 5.7.0）
 * @param mapView 地图的view
 * Map view
 * @param view annotationView
 */
- (void)mapView:(MAMapView *)mapView didAnnotationViewTapped:(MAAnnotationView *)view;

/**
 * @brief 当userTrackingMode改变时，调用此接口
 * When the userTrackingMode changes, this interface is called
 * @param mapView 地图View
 * Map view
 * @param mode 改变后的mode
 * The changed mode
 * @param animated 动画
 * Animation
 */
- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated;

/**
 * @brief 当openGLESDisabled变量改变时，调用此接口
 * When the openGLESDisabled variable changes, call this interface
 * @param mapView 地图View
 * Map view
 * @param openGLESDisabled 改变后的openGLESDisabled
 * the changed openGLESDisabled
 */
- (void)mapView:(MAMapView *)mapView didChangeOpenGLESDisabled:(BOOL)openGLESDisabled __attribute((deprecated("Deprecated, since 7.9.0")));

/**
 * @brief 当touchPOIEnabled == YES时，单击地图使用该回调获取POI信息
 * When touchPOIEnabled == YES, click on the map to use this callback to get POI information
 * @param mapView 地图View
 * Map view
 * @param pois 获取到的poi数组(由MATouchPoi组成)
 * the obtained poi array (composed of MATouchPoi)
 */
- (void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois;

/**
 * @brief 单击地图回调，返回经纬度
 * Click on the map callback, return latitude and longitude
 * @param mapView 地图View
 * Map view
 * @param coordinate 经纬度
 * latitude and longitude
 */
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 * @brief 长按地图，返回经纬度
 * Long press on the map, return latitude and longitude
 * @param mapView 地图View
 * Map view
 * @param coordinate 经纬度
 * latitude and longitude
 */
- (void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 * @brief 地图初始化完成（在此之后，可以进行坐标计算）
 * Map initialization completed (after this, coordinate calculations can be performed)
 * @param mapView 地图View
 * Map view
 */
- (void)mapInitComplete:(MAMapView *)mapView;

#if MA_INCLUDE_INDOOR
/**
 * @brief  室内地图出现,返回室内地图信息
 * Indoor map appears, returns indoor map information
 *
 *  @param mapView        地图View
 *  Map view
 *  @param indoorInfo     室内地图信息
 *  Indoor map information
 */
- (void)mapView:(MAMapView *)mapView didIndoorMapShowed:(MAIndoorInfo *)indoorInfo;

/**
 * @brief  室内地图楼层发生变化,返回变化的楼层
 * Indoor map floor changes, returns the changed floor
 *
 *  @param mapView        地图View
 *  Map view
 *  @param indoorInfo     变化的楼层
 *  Changing floors
 */
- (void)mapView:(MAMapView *)mapView didIndoorMapFloorIndexChanged:(MAIndoorInfo *)indoorInfo;

/**
 * @brief  室内地图消失后,返回室内地图信息
 *  After the indoor map disappears, return to the indoor map information
 *  @param mapView        地图View
 *  Map view
 *  @param indoorInfo     室内地图信息
 *  Indoor map information
 */
- (void)mapView:(MAMapView *)mapView didIndoorMapHidden:(MAIndoorInfo *)indoorInfo;
#endif //end of MA_INCLUDE_INDOOR

/**
 * @brief 离线地图数据将要被加载, 调用reloadMap会触发该回调，离线数据生效前的回调.
 * Offline map data is about to be loaded, calling reloadMap will trigger this callback, the callback before the offline data takes effect.
 * @param mapView 地图View
 * Map view
 */
- (void)offlineDataWillReload:(MAMapView *)mapView;

/**
 * @brief 离线地图数据加载完成, 调用reloadMap会触发该回调，离线数据生效后的回调.
 * Offline map data loading completed. Calling reloadMap will trigger this callback, which is the callback after the offline data takes effect.
 * @param mapView 地图View,
 * Map view
 */
- (void)offlineDataDidReload:(MAMapView *)mapView;

/**
 * @brief 自定义地图样式在线数据加载鉴权失败回调
 * @param errorCode 错误码
 * @param msg 错误信息
 */
- (void)customMapStyleAuthFailedWithErrorCode:(int)errorCode message:(NSString *)msg;

@end

