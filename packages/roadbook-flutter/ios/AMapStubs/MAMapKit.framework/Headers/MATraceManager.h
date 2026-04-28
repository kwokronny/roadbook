//
//  MATraceManager.h
//  MAMapKit
//
//  Created by shaobin on 16/9/1.
//  Copyright © 2016年 Amap. All rights reserved.
//



#import "MAConfig.h"

#if MA_INCLUDE_TRACE_CORRECT

#import <Foundation/Foundation.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "MATraceLocation.h"

@class MATraceManager;

///处理中回调， index: 批次编号，0 based
///Processing callback, index: batch number, 0 based
typedef void(^MAProcessingCallback)(int index, NSArray<MATracePoint *> *points);

///成功回调，distance：距离，单位米
///Success callback, distance: distance, unit meters
typedef void(^MAFinishCallback)(NSArray<MATracePoint *> *points, double distance);

///失败回调
///Failure callback
typedef void(^MAFailedCallback)(int errorCode, NSString *errorDesc);

///定位回调, locations: 原始定位点; tracePoints: 纠偏后的点，如果纠偏失败返回nil; distance:距离; error: 纠偏失败时的错误信息
///Location callback, locations: raw location points; tracePoints: corrected points, returns nil if correction fails; distance: distance; error: error message when correction fails
typedef void(^MATraceLocationCallback)(NSArray<CLLocation *> *locations, NSArray<MATracePoint *> *tracePoints, double distance, NSError *error);

/**
 * @brief 轨迹定位的代理协议，since v6.2.0
 * Proxy protocol for trajectory positioning   since v6.2.0
*/
@protocol MATraceDelegate <NSObject>

@required

/**
 * @brief 轨迹定位纠偏的回调方法，since v6.2.0
 * Callback method for trajectory positioning correction  v6.2.0
 * @param manager 轨迹定位管理对象
 * Trajectory positioning management object
 * @param locations 已经完成纠偏的原始定位数据
 * Original positioning data that has been corrected
 * @param tracePoints 已经完成纠偏处理后的轨迹点
 * Trajectory points after correction processing
 * @param distance 距离，单位米
 * Distance, in meters
 * @param error 如果成功的话为nil，否则为失败原因
 * If successful, it is nil, otherwise it is the reason for failure
 */
- (void)traceManager:(MATraceManager *)manager
            didTrace:(NSArray<CLLocation *> *)locations
             correct:(NSArray<MATracePoint *> *)tracePoints
            distance:(double)distance
           withError:(NSError *)error;

@optional
/**
 *  @brief 当plist配置NSLocationAlwaysUsageDescription或者NSLocationAlwaysAndWhenInUseUsageDescription，并且[CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined，会调用代理的此方法。
 此方法实现调用后台权限API即可（ 该回调必须实现 [locationManager requestAlwaysAuthorization] ）; since 6.8.1
 * When the plist configures NSLocationAlwaysUsageDescription or NSLocationAlwaysAndWhenInUseUsageDescription, and [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined, this method of the delegate will be called. This method can be implemented by calling the background permission API (this callback must implement [locationManager requestAlwaysAuthorization]);  since 6.8.1
 *  @param locationManager  地图的CLLocationManager。
 *  Map's CLLocationManager
 */
- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager;

@end

///轨迹纠偏管理类
///Trajectory correction management class
@interface MATraceManager : NSObject

/**
 * @brief 单例方法
 * Singleton method
 */
+ (instancetype)sharedInstance;

/**
 * @brief 获取纠偏后的经纬度点集
 * Obtain the corrected latitude and longitude point set
 * @param locations 待纠偏处理的点集, 顺序即为传入的顺序
 * Point set to be corrected, the order is the input order
 * @param type loctions经纬度坐标的类型, 如果已经是高德坐标系，传 -1
 * The type of loctions latitude and longitude coordinates. If it is already in the AutoNavi coordinate system, pass -1
 * @param processingCallback  如果一次传入点过多，内部会分批处理。每处理完一批就调用此回调
 * If too many points are passed in at once, they will be processed in batches internally. This callback is called after each batch is processed
 * @param finishCallback 全部处理完毕调用此回调
 * This callback is called when all processing is complete
 * @param failedCallback 失败调用此回调
 * This callback is called on failure
 * @return 返回一个NSOperation对象，可调用cancel取消
 * Returns an NSOperation object, which can be canceled by calling cancel
 */
- (NSOperation *)queryProcessedTraceWith:(NSArray<MATraceLocation *>*)locations
                                    type:(AMapCoordinateType)type
                      processingCallback:(MAProcessingCallback)processingCallback
                          finishCallback:(MAFinishCallback)finishCallback
                          failedCallback:(MAFailedCallback)failedCallback;

/**
 * @brief 轨迹定位的代理回调对象，配合start和stop方法使用，since v6.2.0
 * The delegate callback object for trajectory positioning, used in conjunction with the start and stop methods.   since v6.2.0
 */
@property (nonatomic, weak) id<MATraceDelegate> delegate;

/**
 * @brief 开始轨迹定位, 内部使用系统CLLocationManager，distanceFilter，desiredAccuracy均为系统默认值，since v6.2.0
 * Start trajectory tracking, internally using the system CLLocationManager, distanceFilter, and desiredAccuracy are set to system default values.   since v6.2.0
 */
- (void)start;

/**
 * @brief 停止轨迹定位，since v6.2.0
 * Stop trajectory tracking.    since v6.2.0
 */
- (void)stop;

@end

#endif
