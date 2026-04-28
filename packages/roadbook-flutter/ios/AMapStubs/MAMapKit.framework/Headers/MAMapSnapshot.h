//
//  MAMapSnapshot.h
//  MAMapKit
//
//  Created by ZhaoRui on 2022/3/30.
//  Copyright © 2022 Amap. All rights reserved.
//

#import "MAMapKit/MAMapKit.h"

@interface MAMapSnapshotModel : NSObject

@property (nonatomic, assign) CGSize     size;
@property (nonatomic, assign) CGPoint    position;
@property (nonatomic, assign) MAMapPoint tlPoint;
@property (nonatomic, assign) MAMapPoint trPoint;
@property (nonatomic, strong) UIImage* image;

@end

@interface MAMapSnapshot : NSObject

@property (nonatomic, readonly) CGSize minSize;
@property (nonatomic, readonly) CGSize maxSize;

- (instancetype)init:(MAMapView*)mapview;

/**
 * @brief 异步在指定区域内截图(默认会包含该区域内的annotationView), 地图载入完整时回调
 * Asynchronously capture a screenshot within the specified area (by default, it will include the annotationView within that area), callback when the map is fully loaded
 * @param size 指定的区域
 * The specified area
 * @param tl 左上
 * Top left
 * @param tr 右上
 * Top right
 * @param block 回调block(resultImages:返回的图片集合,state：0载入不完整，1完整）
 * Callback block(resultImages: returned image collection, state: 0 incomplete loading, 1 complete)
 */
typedef void(^CaptureResultBlock)(NSArray<MAMapSnapshotModel*> *resultImages, NSInteger state);
- (BOOL)captureBigPicture:(CGSize)pixelSize
                  topLeft:(CLLocationCoordinate2D)tl
                 topRight:(CLLocationCoordinate2D)tr
                 complete:(CaptureResultBlock)block;
/**
 * @brief 异步在指定区域内截图(默认会包含该区域内的annotationView), 地图载入完整时回调
 * Asynchronously capture a screenshot within the specified area (by default, it will include the annotationView within that area), callback when the map is fully loaded
 * @param size 指定的区域
 * The specified area
 * @param tl 左上
 * Top left
 * @param tr 右上
 * Top right
 * @param block 回调block(resultImage:返回的图片,state：0载入不完整，1完整）
 * Callback block(resultImage: returned image, state: 0 incomplete loading, 1 complete)
 */
typedef void(^Observer)(UIImage *resultImage, NSInteger state);
- (BOOL)capture:(CGSize)size
        topLeft:(CLLocationCoordinate2D)tl
       topRight:(CLLocationCoordinate2D)tr
       complete:(Observer)block;

@end

