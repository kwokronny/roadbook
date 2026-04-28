//
//  MAMultiPointOverlay.h
//  MAMapKit
//
//  Created by hanxiaoming on 2017/4/11.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_MAMultiPoint

#import "MAShape.h"
#import "MAOverlay.h"

///海量点overlay单个点对象（since 5.1.0））
///Massive point overlay single point object   since 5.1.0
@interface MAMultiPointItem : NSObject<NSCopying, MAAnnotation>

///经纬度
/// Latitude and longitude
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

///唯一标识，默认为nil。
///Unique identifier, default is nil
@property (nonatomic, copy) NSString *customID;

///标题
///Title
@property (nonatomic, copy) NSString *title;

///副标题
///Subtitle
@property (nonatomic, copy) NSString *subtitle;

@end


///海量点overlay（since 5.1.0）
///Massive point overlay   since 5.1.0
@interface MAMultiPointOverlay : MAShape<MAOverlay>

///点对象集合（注意：MAMultiPointItem属性不支持动态更新）
///Point object collection (Note: MAMultiPointItem properties do not support dynamic updates)
@property (nonatomic, readonly) NSArray<MAMultiPointItem *> *items;

///初始化方法
///Initialization method
- (instancetype)initWithMultiPointItems:(NSArray<MAMultiPointItem *> *)items;

@end

#endif
