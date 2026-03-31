//
//  MAMVTTileOverlayRenderer.h
//  MapKit_static
//
//  Created by Li Fei on 11/25/13.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"

#if MA_INCLUDE_OVERLAY_TILE
#if FEATURE_MVT
#import "MATileOverlayRenderer.h"
#import "MAMVTTileOverlay.h"

/// 此类是将MAMVTOverlayRenderer中的覆盖tiles显示在地图上的Renderer
/// This class is a Renderer that displays the overlay tiles from MAMVTOverlayRenderer on the map 
@interface MAMVTTileOverlayRenderer : MATileOverlayRenderer
@end

#endif
#endif
