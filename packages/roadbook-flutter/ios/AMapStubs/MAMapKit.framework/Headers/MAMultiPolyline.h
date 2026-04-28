//
//  MAMultiPolyline.h
//  MapKit_static
//
//  Created by yi chen on 12/11/15.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_MAMultiPolyline

#import "MAPolyline.h"

///多彩线model类。此类用于定义一个由多个点相连的多段线，绘制时支持分段采用不同颜色（纹理）绘制，点与点之间尾部相连但第一点与最后一个点不相连, 通常MAMultiPolyline是MAMultiColoredPolylineRenderer（分段颜色绘制）或MAMultiTexturePolylineRenderer（分段纹理绘制）的model
///The MultiColorLine model class. This class is used to define a polyline connected by multiple points, supporting the use of different colors (textures) for each segment during drawing. The points are connected end to end, but the first and last points are not connected, usually MAMultiPolyline is a model of MAMultiColoredPolylineRenderer (segmented color rendering) or MAMultiTexturePolylineRenderer (segmented texture rendering)
@interface MAMultiPolyline : MAPolyline

/**
 绘制索引数组(纹理、颜色索引数组), 成员为NSNumber, 且为非负数。
 例子：[1,3,6] 表示 0-1使用第一种颜色\纹理，1-3使用第二种，3-6使用第三种，6-最后使用第四种。
 在渐变模式下（MAMultiColoredPolylineRenderer.gradient = YES），0-1使用第一种颜色，3使用第二种，6-最后使用第四种，1-3，3-6使用渐变色进行填充。
 
 注意：polyline在渲染时会进行抽稀以提高渲染效率，但是如果是设置为drawIndex的点，则不会被抽稀。
    在每一个点都是索引点的极端情况下，则抽稀过程不会生效，点数量很多时会极大的影响渲染效率。所以请尽量少的设置索引点的数量。
 */
/**
 Draw index array (texture, color index array), members are NSNumber and non-negative.
 Example: [1,3,6] means using the first color\\texture for 0-1, the second for 1-3, the third for 3-6, and the fourth from 6 to the end.
 In gradient mode (MAMultiColoredPolylineRenderer.gradient = YES), use the first color for 0-1, the second for 3, and the fourth from 6 to the end. Use gradient colors for filling between 1-3 and 3-6.
 
 Note: The polyline will be simplified during rendering to improve efficiency, but points set as drawIndex will not be simplified.
 In the extreme case where every point is an index point, the thinning process will not take effect, and a large number of points will significantly affect rendering efficiency. Therefore, please try to minimize the number of index points.
 */
@property (nonatomic, strong) NSArray<NSNumber *> *drawStyleIndexes;

/**
 * @brief 多彩线，根据MAMapPoint数据生成多彩线
 * Colorful line, generated based on MAMapPoint data;
 *
 * 分段纹理绘制：其对应的MAMultiTexturePolylineRenderer必须设置strokeTextureImages属性; 否则使用默认的灰色纹理绘制。
 * Segmented texture rendering: its corresponding MAMultiTexturePolylineRenderer must set the strokeTextureImages property; otherwise, the default gray texture will be used.
 * 分段颜色绘制：其对应的MAMultiColoredPolylineRenderer必须设置strokeColors属性
 * Segmented color rendering: Its corresponding MAMultiColoredPolylineRenderer must set the strokeColors property
 *
 * @param points           指定的直角坐标点数组，注意：如果有连续重复点，需要去重处理，只保留一个，否则会导致绘制有问题。
 * Specified array of rectangular coordinate points, note: if there are consecutive duplicate points, deduplication is required, only one should be retained, otherwise it will cause issues in drawing.
 * @param count            坐标点的个数
 * Number of coordinate points
 * @param drawStyleIndexes 纹理索引数组(颜色索引数组)
 * Texture index array (color index array)
 * @return 生成的折线对象
 * Generated polyline object
 */
+ (instancetype)polylineWithPoints:(MAMapPoint *)points count:(NSUInteger)count drawStyleIndexes:(NSArray<NSNumber *> *) drawStyleIndexes;

/**
 * @brief 多彩线，根据经纬度坐标数据生成多彩线
 * Multicolored line, generated based on latitude and longitude coordinate data
 *
 * 分段纹理绘制：其对应的MAMultiTexturePolylineRenderer必须设置strokeTextureImages属性; 否则使用默认的灰色纹理绘制。
 * Segmented texture rendering: its corresponding MAMultiTexturePolylineRenderer must set the strokeTextureImages property; otherwise, the default gray texture will be used.
 * 分段颜色绘制：其对应的MAMultiColoredPolylineRenderer必须设置strokeColors属性。
 * Segmented color rendering: Its corresponding MAMultiColoredPolylineRenderer must set the strokeColors property.
 *
 * @param coords           指定的经纬度坐标点数组，注意：如果有连续重复点，需要去重处理，只保留一个，否则会导致绘制有问题。
 * The array of specified latitude and longitude coordinate points, note: if there are consecutive duplicate points, they need to be deduplicated, only one should be retained, otherwise it will cause drawing issues.
 * @param count            坐标点的个数
 * Number of coordinate points
 * @param drawStyleIndexes 纹理索引数组(颜色索引数组), 成员为NSNumber, 且为非负数。
 * Texture index array (color index array), members are NSNumber, and are non-negative.
 * @return 生成的折线对象
 * Generated polyline object
 */
+ (instancetype)polylineWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count drawStyleIndexes:(NSArray<NSNumber *> *) drawStyleIndexes;

/**
 * @brief 重新设置坐标点. since 5.0.0
 * Reset the coordinate points . since 5.0.0
 * @param points 指定的直角坐标点数组,C数组，内部会做copy，调用者负责内存管理。注意：如果有连续重复点，需要去重处理，只保留一个，否则会导致绘制有问题。
 * Specified rectangular coordinate point array, C array, internal copy will be made, the caller is responsible for memory management,  note: if there are consecutive duplicate points, they need to be deduplicated, only one should be retained, otherwise it will cause drawing issues.
 * @param count 坐标点的个数
 * Number of coordinate points
 * @param drawStyleIndexes 纹理索引数组(颜色索引数组), 成员为NSNumber, 且为非负数。
 * Texture index array (color index array), members are NSNumber, and are non-negative.
 * @return 是否设置成功
 * Whether the setup was successful
 */
- (BOOL)setPolylineWithPoints:(MAMapPoint *)points
                        count:(NSUInteger)count
             drawStyleIndexes:(NSArray<NSNumber *> *)drawStyleIndexes;

/**
 * @brief 重新设置坐标点. since 5.0.0
 * Reset the coordinate points. since 5.0.0
 * @param coords 指定的经纬度坐标点数组,C数组，内部会做copy，调用者负责内存管理。注意：如果有连续重复点，需要去重处理，只保留一个，否则会导致绘制有问题。
 * Specified latitude and longitude coordinate point array, C array, internal copy will be made, the caller is responsible for memory management. Note: if there are consecutive duplicate points, they need to be deduplicated, only one should be retained, otherwise it will cause drawing issues.
 * @param count 坐标点的个数
 * Number of coordinate points
 * @param drawStyleIndexes 纹理索引数组(颜色索引数组), 成员为NSNumber, 且为非负数。
 * Texture index array (color index array), members are NSNumber, and are non-negative.
 * @return 是否设置成功
 * Whether the setup was successful
 */
- (BOOL)setPolylineWithCoordinates:(CLLocationCoordinate2D *)coords
                             count:(NSUInteger)count
                  drawStyleIndexes:(NSArray<NSNumber *> *)drawStyleIndexes;

@end

#endif
