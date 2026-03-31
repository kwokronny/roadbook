//
//  AMapPolygonController.h
//  amap_flutter_map
//
//  Created by lly on 2020/11/12.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#if !TARGET_OS_SIMULATOR
#import <MAMapKit/MAMapKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class AMapPolyline;
@class AMapPolygon;

@interface AMapPolygonController : NSObject

#if !TARGET_OS_SIMULATOR
- (instancetype)init:(FlutterMethodChannel*)methodChannel
             mapView:(MAMapView*)mapView
           registrar:(NSObject<FlutterPluginRegistrar>*)registrar;
#endif

- (nullable AMapPolygon *)polygonForId:(NSString *)polygonId;

- (void)addPolygons:(NSArray*)polygonsToAdd;

- (void)changePolygons:(NSArray*)polygonsToChange;

- (void)removePolygonIds:(NSArray*)polygonIdsToRemove;

@end

NS_ASSUME_NONNULL_END
