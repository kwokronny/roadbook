//
//  MARouteOverlay.h
//  MAMapKit
//
//  Created by linshiqing on 2024/1/18.
//  Copyright © 2024 Amap. All rights reserved.
//

#import "MAConfig.h"
#if FEATURE_ROUTE_OVERLAY
#import "MABaseEngineOverlay.h"
#import "MARouteOverlayModel.h"
NS_ASSUME_NONNULL_BEGIN


@interface MARouteOverlay : MABaseEngineOverlay
@property (nonatomic, assign, readonly) NSUInteger mapScene;
@property (nonatomic, copy, readonly) NSArray<MARouteOverlayParam *> *params;
@property (nonatomic, assign, readonly) BOOL select;
@property (nonatomic, strong, readonly) MAMapRouteOverlayData *data;
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *passedColors;

- (instancetype)initWithMapSecne:(NSUInteger)mapScene params:(NSArray<MARouteOverlayParam *> *)params select:(BOOL)select data:(MAMapRouteOverlayData *)data passedColors:(NSArray<NSNumber *> *)passedColors;

- (void)setCar2DWithIndex:(uint32_t)index position:(float)postion;

- (void)setCar3DWithIndex:(uint32_t)index position:(float)postion;

- (void)addRouteName;

- (void)removeRouteName;
    
- (void)setLineWidthScale:(float)scale;
    
- (void)setLine2DWithLineWidth:(int32_t)lineWidth  borderWidth:(int32_t)borderWidth;

 - (void)setShowArrow:(BOOL)bShow;
    
- (void)setArrow3DTexture:(UIImage *)image;
     
- (void)setRouteItemParam:(MARouteOverlayParam *)routeParam;

- (void)setHighlightType:(MAMapRouteHighLightType)type;

- (void)setHighlightParam:(MARouteOverlayHighLightParam *)highlightParam;

- (void)setSelectStatus:(BOOL)status;

- (void)setShowNaviRouteNameCountMap:(NSDictionary<NSNumber *, NSNumber *>*)countMap;

- (void)setArrowFlow:(BOOL)bFlow;
@end
NS_ASSUME_NONNULL_END
#endif
