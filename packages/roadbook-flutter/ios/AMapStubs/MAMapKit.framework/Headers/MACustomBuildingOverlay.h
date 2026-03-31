//
//  MACustomBuildingOverlay.h
//  MAMapKit
//
//  Created by liubo on 2018/5/23.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_CUSTOMBUILDING

#import "MAShape.h"
#import "MAOverlay.h"
#import "MAMultiPoint.h"

#pragma mark - MACustomBuildingOverlayOption

///该类用于定义一个楼块显示选项. since 6.3.0
///This class is used to define a building block display option.   since 6.3.0
@interface MACustomBuildingOverlayOption : MAMultiPoint

///楼块的高度. 修改该属性会使option范围内的所有楼块为同一个高度. (范围 (-1 U [1, 1000]). 默认-1,显示为默认高度.)
///The height of the building block. Modifying this property will set all building blocks within the option scope to the same height. (Range (-1 U [1, 1000]). Default -1, displayed as the default height.
@property (nonatomic, assign) CGFloat height;

///楼块的高度缩放比例. 修改该属性会使option范围内的所有楼块高度放大或者缩小heightScale倍. (默认1. 如果指定了height则此值将被忽略.)
///The height scaling ratio of the building blocks. Modifying this attribute will scale the height of all building blocks within the option range by a factor of heightScale. (Default is 1. If height is specified, this value will be ignored.)
@property (nonatomic, assign) CGFloat heightScale;

///楼块的顶面颜色. (默认[UIColor lightGrayColor], 不支持透明度)
///The top color of the building block. (Default [UIColor lightGrayColor], transparency not supported)
@property (nonatomic, strong) UIColor *topColor;

///楼块的侧面颜色. (默认[UIColor darkGrayColor], 不支持透明度)
///The side color of the building block. (Default [UIColor darkGrayColor], transparency not supported)
@property (nonatomic, strong) UIColor *sideColor;

///option选项是否可见. (默认YES)
///Whether the option is visible. (Default: YES)
@property (nonatomic, assign) BOOL visibile;

/**
 * @brief 根据经纬度坐标数据生成楼块显示选项option
 * Generate building block display options based on latitude and longitude coordinate data
 * @param coords 经纬度坐标点数据,coords对应的内存会拷贝,调用者负责该内存的释放
 * Latitude and longitude coordinate point data, the memory corresponding to coords will be copied, the caller is responsible for releasing this memory
 * @param count  经纬度坐标点数组个数
 * Number of latitude and longitude coordinate points array
 * @return 新生成的楼块显示选项option
 * Newly generated building block display option
 */
+ (instancetype)optionWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count;

/**
 * @brief 重新设置option范围.
 * Reset the option range
 * @param coords 指定的经纬度坐标点数组, C数组，内部会做copy，调用者负责内存管理
 * Specified latitude and longitude coordinate points array, C array, internal copy will be made, caller is responsible for memory management
 * @param count 坐标点的个数
 * Number of coordinate points
 * @return 是否设置成功
 * Whether the setup was successful
 */
- (BOOL)setOptionWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count;

@end


#pragma mark - MACustomBuildingOverlay

///该类用于定义一个自定义楼块MACustomBuildingOverlay, 通常MACustomBuildingOverlay是MACustomBuildingOverlayRenderer的model.(注意: 自定义楼块仅支持在zoomLevel>=15级时显示) since 6.3.0
///This class is used to define a custom building block MACustomBuildingOverlay,Generally, MACustomBuildingOverlay is the model of MACustomBuildingOverlayRenderer. (Note: Custom buildings are only displayed when zoomLevel>=15)   since 6.3.0
@interface MACustomBuildingOverlay : MAShape<MAOverlay>

///默认的楼块显示option, 将显示所有的楼块. (如果不需要显示所有的楼块,可以设置defaultOption.visibile = NO)
///The default building block display option will show all building blocks. (If you do not need to display all building blocks, you can set defaultOption.visible = NO)
@property (nonatomic, readonly) MACustomBuildingOverlayOption *defaultOption;

///当前自定义的楼块显示options. (options按添加顺序, 后添加的在最上层显示)
///Current customized building block display options. (Options are displayed in the order they are added, with the last added on top)
@property (nonatomic, readonly) NSArray<MACustomBuildingOverlayOption *> *customOptions;

/**
 * @brief 增加自定义楼块显示的option
 * Add custom building display options
 * @param option 要增加的自定义楼块显示option
 * Custom building display options to be added
 */
- (void)addCustomOption:(MACustomBuildingOverlayOption *)option;

/**
 * @brief 移除自定义楼块显示的option
 * Remove the option for displaying custom building blocks
 * @param option 要移除的自定义楼块显示option
 * The custom building block display option to be removed
 */
- (void)removeCustomOption:(MACustomBuildingOverlayOption *)option;

@end

#endif
