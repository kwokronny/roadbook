//
//  MATileOverlay.h
//  MapKit_static
//
//  Created by Li Fei on 11/22/13.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_TILE

#import "MAOverlay.h"
#import "MABaseOverlay.h"

///该类是覆盖在球面墨卡托投影上的图片tiles的数据源
///This class is the data source for image tiles covering the spherical Mercator projection
@interface MATileOverlay : MABaseOverlay

///瓦片大小，默认是256x256, 最小支持64*64
///Tile size, default is 256x256, minimum support is 64*64
@property (nonatomic, assign) CGSize tileSize;

///tileOverlay的可见最小Zoom值
///The minimum visible Zoom value for tileOverlay
@property NSInteger minimumZ __attribute((deprecated("Deprecated, calling has no effect. since 9.6.0")));

///tileOverlay的可见最大Zoom值
///The maximum visible Zoom value of tileOverlay
@property NSInteger maximumZ __attribute((deprecated("Deprecated, calling has no effect. since 9.6.0")));

///同initWithURLTemplate:中的URLTemplate
///Same as the URLTemplate in initWithURLTemplate:
@property (readonly) NSString *URLTemplate;

///暂未开放
///not yet open
@property (nonatomic) BOOL canReplaceMapContent;

///是否停止不在显示区域内的瓦片下载，默认NO. since 5.3.0
///whether to stop downloading tiles outside the display area, default is NO.  since 5.3.0
@property (nonatomic, assign) BOOL disableOffScreenTileLoading;

/**
 * @brief 根据指定的URLTemplate生成tileOverlay
 * Generate tileOverlay based on the specified URLTemplate
 * @param URLTemplate URLTemplate是一个包含"{x}","{y}","{z}","{scale}"的字符串,"{x}","{y}","{z}","{scale}"会被tile path的值所替换，并生成用来加载tile图片数据的URL 。例如 http://server/path?x={x}&y={y}&z={z}&scale={scale}
 * URLTemplate is a string containing "{x}","{y}","{z}","{scale}", where "{x}","{y}","{z}","{scale}" will be replaced by the tile path value to generate the URL for loading tile image data. For example, http://server/path?x={x}&y={y}&z={z}&scale={scale}
 * @return 以指定的URLTemplate字符串生成tileOverlay
 * Generate tileOverlay using the specified URLTemplate string
 */
- (id)initWithURLTemplate:(NSString *)URLTemplate;

@end

///MATileOverlayPath
struct MATileOverlayPath{
    NSInteger x; ///< x坐标   x-coordinate
    NSInteger y; ///< y坐标   y-coordinate
    NSInteger z; ///< 缩放级别   zoom level
    CGFloat contentScaleFactor; ///< 屏幕的scale factor   screen's scale factor
    NSInteger index; ///< 对应的下载url   corresponding download URL
    NSInteger requestId; ///<资源下载唯一标识，用于记录   Unique identifier for resource download, used for recording
};
typedef struct MATileOverlayPath MATileOverlayPath;

///子类可覆盖CustomLoading中的方法来自定义加载MATileOverlay的行为。
///Subclasses can override methods in CustomLoading to customize the behavior of loading MATileOverlay
@interface MATileOverlay (CustomLoading)

/**
 * @brief 以tile path生成URL。用于加载tile,此方法默认填充URLTemplate
 * Generate URL from tile path. Used to load tiles, this method defaults to filling URLTemplate
 * @param path tile path
 * @return 以tile path生成tileOverlay
 * Generate tileOverlay from tile path
 */
- (NSURL *)URLForTilePath:(MATileOverlayPath)path;

/**
 * @brief 加载被请求的tile,并以tile数据或加载tile失败error访问回调block;默认实现为首先用URLForTilePath去获取URL,然后用异步NSURLConnection加载tile
 * Load the requested tile and access the callback block with tile data or a tile loading failure error; the default implementation first uses URLForTilePath to obtain the URL, then loads the tile asynchronously with NSURLConnection.
 * @param path   tile path
 * @param result 用来传入tile数据或加载tile失败的error访问的回调block
 * A callback block used to pass in tile data or access errors when tile loading fails
 */
- (void)loadTileAtPath:(MATileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result;

/**
 * @brief 取消请求瓦片，当地图显示区域发生变化时，会取消显示区域外的瓦片的下载, 当disableOffScreenTileLoading=YES时会被调用。since 5.3.0
 * Cancel tile requests, when the map display area changes, it will cancel the download of tiles outside the display area, and it will be called when disableOffScreenTileLoading=YES.  since 5.3.0
 * @param path  tile path
 */
- (void)cancelLoadOfTileAtPath:(MATileOverlayPath)path;

@end

#endif
