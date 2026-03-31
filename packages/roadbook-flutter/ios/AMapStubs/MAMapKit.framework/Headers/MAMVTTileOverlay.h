//
//  MAMVTTileOverlay.h
//  MapKit_static
//
//  Created by Li Fei on 11/22/13.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_TILE
#if FEATURE_MVT
#import "MATileOverlay.h"
#import "MABaseOverlay.h"

@interface MAMVTTileOverlayOptions : NSObject
@property (nonatomic, copy) NSString *url; // URL
@property (nonatomic, copy) NSString *key; // key
@property (nonatomic, copy) NSString *Id; // id
@property (nonatomic, assign) BOOL visible; // 是否可见 默认YES  Visible, default YES
@end

/// MVT瓦片数据   MVT tile data
@interface MAMVTTileOverlay : MATileOverlay
/// MVT配置选项   MVT configuration options
@property (nonatomic, strong, readonly) MAMVTTileOverlayOptions *option;
+ (instancetype)mvtTileOverlayWithOption:(MAMVTTileOverlayOptions *)option;
@end
#endif
#endif
