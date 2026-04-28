//
//  MAGroundOverlay.h
//  MapKit_static
//
//  Created by Li Fei on 11/12/13.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"

#if MA_INCLUDE_OVERLAY_GROUND

#import <UIKit/UIKit.h>
#import "MAShape.h"
#import "MAOverlay.h"

///该类用于确定覆盖在地图上的图片，及其覆盖区域, 通常MAGroundOverlay是MAGroundOverlayRenderer的model
///This class is used to determine the images overlaid on the map and their coverage areas. Typically, MAGroundOverlay is the model of MAGroundOverlayRenderer.
@interface MAGroundOverlay : MAShape<MAOverlay>

///绘制在地图上的覆盖图片
///Overlay image drawn on the map
@property (nonatomic, readonly) UIImage *icon;

///透明度. 最终透明度 = 纹理透明度 * alpha. 有效范围为[0.f, 1.f], 默认为1.f
///Transparency. Final transparency = texture transparency * alpha. Valid range is [0.f, 1.f], default is 1.f
@property (nonatomic, assign) CGFloat alpha __attribute((deprecated("Deprecated, since 7.7.0, please use alpha in MAGroundOverlayRenderer")));

///覆盖图片在地图尺寸等同于其像素的zoom值
///The zoom level at which the overlay image's size on the map equals its pixel dimensions.
@property (nonatomic, readonly) CGFloat zoomLevel;

///图片在地图中的覆盖范围
///Image coverage area on the map
@property (nonatomic, readonly) MACoordinateBounds bounds;

/**
 * @brief 根据bounds值和icon生成GroundOverlay
 * Generate GroundOverlay based on bounds and icon
 * @param bounds 图片的在地图的覆盖范围
 * Image coverage area on the map
 * @param icon   覆盖图片
 * Overlay image
 * @return 以bounds和icon 新生成GroundOverlay
 * Create a new GroundOverlay with bounds and icon
 */
+ (instancetype)groundOverlayWithBounds:(MACoordinateBounds)bounds
                                   icon:(UIImage *)icon;

/**
 * @brief 根据coordinate,icon,zoomLevel生成GroundOverlay
 * Generate GroundOverlay based on coordinate, icon, and zoomLevel
 * @param coordinate 图片的在地图上的中心点
 * The center point of the image on the map
 * @param zoomLevel  图片在地图尺寸等同于像素的zoom值
 * The zoom value where the image size on the map equals its pixel dimensions
 * @param icon       覆盖图片
 * Overlay image
 * @return 以coordinate,icon,zoomLevel 新生成GroundOverlay
 * Create a new GroundOverlay with coordinate, icon, zoomLevel
 */
+ (instancetype)groundOverlayWithCoordinate:(CLLocationCoordinate2D)coordinate
                                  zoomLevel:(CGFloat)zoomLevel
                                       icon:(UIImage *)icon;

/**
 * @brief 更新GroundOverlay. since 5.0.0
 * Update GroundOverlay. since 5.0.0
 * @param bounds 图片的在地图的覆盖范围
 * Image coverage on the map
 * @param icon   覆盖图片
 * Overlay image
 * @return 返回是否成功
 * Return success status
 */
- (BOOL)setGroundOverlayWithBounds:(MACoordinateBounds)bounds icon:(UIImage *)icon;

/**
 * @brief 更新GroundOverlay, 内部会自动计算覆盖物大小，以满足zoomLevel下显示大小为icon大小. since 5.0.0
 * Update GroundOverlay, the system will automatically calculate the overlay size to ensure the display size matches the icon size at the zoomLevel. since 5.0.0
 * @param coordinate 图片在地图上的中心点
 * The center point of the image on the map
 * @param zoomLevel  图片在地图尺寸等同于像素的zoom值
 * The zoom value where the image size on the map equals its pixel dimensions
 * @param icon       覆盖图片
 * Overlay image
 * @return 返回是否成功
 * Return success status
 */
- (BOOL)setGroundOverlayWithCoordinate:(CLLocationCoordinate2D)coordinate
                             zoomLevel:(CGFloat)zoomLevel
                                  icon:(UIImage *)icon;

@end

#endif
