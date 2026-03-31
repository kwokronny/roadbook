//
//  MAPoiFilter.h
//  MAMapKit
//
//  Created by linshiqing on 2024/6/18.
//  Copyright © 2024 Amap. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MAMapView;

NS_ASSUME_NONNULL_BEGIN
typedef NS_OPTIONS(NSUInteger, MAPoiFilterType) {
    MAPoiFilterTypePoi                   = 0x00000001,       //!< 避让POI  Avoid POI
    MAPoiFilterTypeRoadName              = 0x00000002,       //!< 避让底图路名  Avoid basemap road names
    MAPoiFilterTypeRoadShield            = 0x00000004,       //!< 避让路牌  Avoid road signs
    MAPoiFilterTypeLabel3rd              = 0x00000008,       //!< 避让第三方label  Avoid third-party labels
    MAPoiFilterTypeAll                   = 0xFFFFFFFF        //!< 避让所有  Avoid all
};

@interface MAPoiFilter : NSObject
@property (nonatomic, assign) MAPoiFilterType filterType;       //!< 避让类型  Avoid type
// 请将CLLocationCoordinate2D类型使用[NSValue valueWithMACoordinate:]包装下
//Please wrap the CLLocationCoordinate2D type with [NSValue valueWithMACoordinate:]
@property (nonatomic, copy) NSArray<NSValue *> *position;       //!< 四边形避让框坐标  Quadrilateral avoidance box coordinates
@property (nonatomic, copy) NSString *keyName;                  //!< 避让框名称  Avoidance box name
+ (instancetype)poiFilter:(MAMapView *)mapView filterType:(MAPoiFilterType)filterType keyName:(NSString *)keyName center:(CLLocationCoordinate2D)center width:(CGFloat)width height:(CGFloat)height;
@end

NS_ASSUME_NONNULL_END
