//
//  MAOfflineMap.h
//
//  Copyright (c) 2013年 Amap. All rights reserved.
//

#import "MAConfig.h"

#if MA_INCLUDE_OFFLINE

#import <Foundation/Foundation.h>
#import "MAOfflineProvince.h"
#import "MAOfflineItemNationWide.h"
#import "MAOfflineItemMunicipality.h"

///离线地图下载状态
///Offline map download status
typedef NS_ENUM(NSInteger, MAOfflineMapDownloadStatus)
{
    MAOfflineMapDownloadStatusWaiting = 0,      //!< 已插入队列，等待中  Inserted into the queue, waiting
    MAOfflineMapDownloadStatusStart,            //!< 开始下载  Download started
    MAOfflineMapDownloadStatusProgress,         //!< 下载过程中  Downloading
    MAOfflineMapDownloadStatusCompleted,        //!< 下载成功  Download successful
    MAOfflineMapDownloadStatusCancelled,        //!< 取消  Cancel
    MAOfflineMapDownloadStatusUnzip,            //!< 解压缩  Decompressing
    MAOfflineMapDownloadStatusFinished,         //!< 全部顺利完成  All completed successfully
    MAOfflineMapDownloadStatusError             //!< 发生错误  Error occurred
};

///离线下载错误domain
///Offline download error domain
extern NSString * const MAOfflineMapErrorDomain;

///离线地图下载错误类型
///Offline map download error type
typedef NS_ENUM(NSInteger, MAOfflineMapError)
{
    MAOfflineMapErrorUnknown = -1,              //!< 未知的错误  Unknown error
    MAOfflineMapErrorCannotWriteToTmp = -2,     //!< 写入临时目录失败  Failed to write to temporary directory
    MAOfflineMapErrorCannotOpenZipFile = -3,    //!< 打开归档文件失败  Failed to open archive file
    MAOfflineMapErrorCannotExpand = -4          //!< 解归档文件失败  Failed to extract archive file
};

/**
 *  当downloadStatus == MAOfflineMapDownloadStatusProgress 时, info参数是个NSDictionary,
 *  如下两个key用来获取已下载和总和的数据大小(单位byte), 对应的是NSNumber(long long) 类型.
 *  当downloadStatus == MAOfflineMapDownloadStatusError 时, info参数是NSError
 */
/**
 *  When downloadStatus == MAOfflineMapDownloadStatusProgress, the info parameter is an NSDictionary,
 *  The following two keys are used to obtain the size of the downloaded and total data (in bytes), corresponding to the NSNumber(long long) type.
 *  When downloadStatus == MAOfflineMapDownloadStatusError, the info parameter is NSError,
 */

///下载过程info的key，表示已下载数据大小
///The key in the download process info, indicating the size of the downloaded data
extern NSString * const MAOfflineMapDownloadReceivedSizeKey;

///下载过程info的key，表示总的数据大小
///The key in the download process info, indicating the total data size
extern NSString * const MAOfflineMapDownloadExpectedSizeKey;

/**
 * @brief 离线地图下载过程回调block
 * The callback block for the offline map download process
 * @param downloadItem 下载的item
 * Downloaded item
 * @param downloadStatus 下载状态
 * Download status
 * @param info 下载过程中的附加信息
 * Additional information during download
 */
typedef void(^MAOfflineMapDownloadBlock)(MAOfflineItem * downloadItem, MAOfflineMapDownloadStatus downloadStatus, id info);

/**
 * @brief 离线地图检查更新回调block
 * Offline map check update callback block
 * @param hasNewestVersion 是否有新版本的布尔值
 * Boolean value indicating whether there is a new version
 */
/**
 * @brief
 * @param hasNewestVersion
 */
typedef void(^MAOfflineMapNewestVersionBlock)(BOOL hasNewestVersion);

///离线地图管理类
///Offline map management class
@interface MAOfflineMap : NSObject

/**
 * @brief 获取MAOfflineMap 单例
 * Get MAOfflineMap singleton
 * @return MAOfflineMap
 */
+ (MAOfflineMap *)sharedOfflineMap;

///省份数组(每个元素均是MAOfflineProvince类型)
///Province array (each element is of type MAOfflineProvince)
@property (nonatomic, readonly) NSArray<MAOfflineProvince *> *provinces;

///直辖市数组(每个元素均是MAOfflineItemMunicipality类型)
///Municipality array (each element is of type MAOfflineItemMunicipality)
@property (nonatomic, readonly) NSArray<MAOfflineItemMunicipality *> *municipalities;

///全国概要图
///National overview map
@property (nonatomic, readonly) MAOfflineItemNationWide *nationWide;

///城市数组, 包括普通城市与直辖市
///City array, including ordinary cities and municipalities
@property (nonatomic, readonly) NSArray<MAOfflineCity *> *cities;

///离线数据的版本号(由年月日组成, 如@"20130715")
///Version number of offline data (composed of year, month, and day, e.g., @"20130715")
@property (nonatomic, readonly) NSString *version;

/**
 * @brief 初始化离线地图数据，如果第一次运行且offlinePackage.plist文件不存在，则需要首先执行此方法。否则MAOfflineMap中的省、市、版本号等数据都为空。
 * Initialize the offline map data. If it is the first run and the offlinePackage.plist file does not exist, this method needs to be executed first. Otherwise, the data such as provinces, cities, and version numbers in MAOfflineMap will be empty.
 * @param block 初始化完成回调
 * Initialization completion callback
 */
- (void)setupWithCompletionBlock:(void(^)(BOOL setupSuccess))block;

/**
 * @brief 启动下载
 * Start download
 * @param item                                  数据
 * Data
 * @param shouldContinueWhenAppEntersBackground 进入后台是否允许继续下载
 * Whether to allow continued download in the background
 * @param downloadBlock                         下载过程block
 * Download process block
 */
- (void)downloadItem:(MAOfflineItem *)item shouldContinueWhenAppEntersBackground:(BOOL)shouldContinueWhenAppEntersBackground downloadBlock:(MAOfflineMapDownloadBlock)downloadBlock;

/**
 * @brief 监测是否正在下载
 * Monitor whether downloading is in progress
 * @param item 条目
 * item
 * @return 是否在下载
 * whether downloading is in progress
 */
- (BOOL)isDownloadingForItem:(MAOfflineItem *)item;

/**
 * @brief 暂停下载
 * pause download
 * @param item 条目
 * item
 * @return 是否在执行了cancel，如果该item并未在下载中，则返回NO
 * whether cancel has been executed, if the item is not being downloaded, return NO
 */
- (BOOL)pauseItem:(MAOfflineItem *)item;

/**
 * @brief 删除item对应离线地图数据
 * delete the offline map data corresponding to the item
 * @param item 条目
 * item
 */
- (void)deleteItem:(MAOfflineItem *)item;

/**
 * @brief 取消全部下载
 * Cancel all downloads
 */
- (void)cancelAll;

/**
 * @brief 清除所有在磁盘上的离线地图数据, 之后调用[mapView reloadMap]会使其立即生效
 * Clear all offline map data on disk, calling [mapView reloadMap] will take effect immediately
 */
- (void)clearDisk;

/**
 * @brief 监测新版本。注意：如果有新版本，会重建所有的数据，包括provinces、municipalities、nationWide、cities，外部使用应当在newestVersionBlock中更新所持有的对象。
 * Monitor new versions. Note: If there is a new version, all data will be rebuilt, including provinces, municipalities, nationWide, cities. External usage should update the held objects in the newestVersionBlock.
 * @param newestVersionBlock 回调block
 * callback block
 */
- (void)checkNewestVersion:(MAOfflineMapNewestVersionBlock)newestVersionBlock;

@end

#endif
