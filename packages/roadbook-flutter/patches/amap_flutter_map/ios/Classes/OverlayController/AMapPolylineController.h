//
//  AMapPolylineController.h
//  amap_flutter_map
//
//  Created by lly on 2020/11/6.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#if !TARGET_OS_SIMULATOR
#import <MAMapKit/MAMapKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class AMapPolyline;

@interface AMapPolylineController : NSObject

#if !TARGET_OS_SIMULATOR
- (instancetype)init:(FlutterMethodChannel*)methodChannel
             mapView:(MAMapView*)mapView
           registrar:(NSObject<FlutterPluginRegistrar>*)registrar;
#endif

- (nullable AMapPolyline *)polylineForId:(NSString *)polylineId;

- (void)addPolylines:(NSArray*)polylinesToAdd;

- (void)changePolylines:(NSArray*)polylinesToChange;

- (void)removePolylineIds:(NSArray*)polylineIdsToRemove;

- (BOOL)onPolylineTap:(NSString*)polylineId;

@end

NS_ASSUME_NONNULL_END
