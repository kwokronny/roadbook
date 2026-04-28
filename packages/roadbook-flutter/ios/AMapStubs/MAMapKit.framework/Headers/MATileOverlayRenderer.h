//
//  MATileOverlayRenderer.h
//  MapKit_static
//
//  Created by Li Fei on 11/25/13.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_TILE

#import "MAOverlayRenderer.h"
#import "MATileOverlay.h"

///此类是将MAOverlayRenderer中的覆盖tiles显示在地图上的Renderer
///This type of Renderer displays overlay tiles from MAOverlayRenderer on the map
@interface MATileOverlayRenderer : MAOverlayRenderer

///覆盖在球面墨卡托投影上的图片tiles的数据源
///Data source for image tiles covering the spherical Mercator projection
@property (nonatomic ,readonly) MATileOverlay *tileOverlay;

/**
 * @brief 根据指定的tileOverlay生成将tiles显示在地图上的Renderer
 * Generates a Renderer to display tiles on the map based on the specified tileOverlay
 * @param tileOverlay 制定了覆盖图片
 * Established overlay images
 * @return 以tileOverlay新生成Renderer
 * Newly generated Renderer with tileOverlay
 */
- (instancetype)initWithTileOverlay:(MATileOverlay *)tileOverlay;

/**
 * @brief 清除所有tile的缓存，并刷新overlay
 * Clear the cache of all tiles and refresh the overlay
 */
- (void)reloadData;

@end

#endif
