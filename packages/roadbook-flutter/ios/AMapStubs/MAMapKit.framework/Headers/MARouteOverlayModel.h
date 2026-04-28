//
//  MARouteOverlayModel.h
//  MAMapKit
//
//  Created by linshiqing on 2024/1/18.
//  Copyright © 2024 Amap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#if FEATURE_ROUTE_OVERLAY
NS_ASSUME_NONNULL_BEGIN
/**
 * @brief   路线纹理枚举   Route texture enumeration
 */
typedef NS_ENUM(NSInteger, MAMapRouteTexture) {
    MAMapRouteTextureNonavi     = 0,       //!< 非导航道路，步行代表不绘制路段  non-navigation roads, walking represents not drawing the road section
    MAMapRouteTextureNavi       = 1,       //!< 导航道路，骑步行代表高亮路段  navigation roads, walking and cycling represent highlighted road sections
    MAMapRouteTextureDefault    = 2,       //!< 实时交通默认状态，步行代表置灰路段  real-time traffic default state, walking represents grayed-out road sections
    MAMapRouteTextureOpen       = 3,       //!< 实时交通畅通状态  real-time traffic smooth state
    MAMapRouteTextureAmble      = 4,       //!< 实时交通缓行状态  Real-time traffic slow status
    MAMapRouteTextureJam        = 5,       //!< 实时交通拥堵状态  Real-time traffic congestion status
    MAMapRouteTextureCongested  = 6,       //!< 实时交通极其拥堵状态  Real-time traffic extremely congested status
    MAMapRouteTextureArrow      = 7,       //!< 路线上鱼骨箭头  Fishbone arrows on the route
    MAMapRouteTextureCustom1    = 8,       //!< 自定义路线纹理1, 与status值对应  Custom route texture 1, corresponding to status value
    MAMapRouteTextureCustom2    = 9,       //!< 自定义路线纹理2, 与status值对应  Custom route texture 2, corresponding to status value
    MAMapRouteTextureCustom3    = 10,      //!< 自定义路线纹理3, 与status值对应  Custom route texture 3, corresponding to status value
    MAMapRouteTextureCustom4    = 11,      //!< 自定义路线纹理4, 与status值对应  Custom route texture 4, corresponding to status value
    MAMapRouteTextureCustom5    = 12,      //!< 自定义路线纹理5, 与status值对应  Custom route texture 5, corresponding to status value
    MAMapRouteTextureCustom6    = 13,      //!< 自定义路线纹理6, 与status值对应  Custom route texture 6, corresponding to status value
    MAMapRouteTextureRapider    = 16,      //!< 自定义路线纹理16,极其畅通  Custom route texture 16, extremely smooth
    MAMapRouteTextureRestrain   = 30,      //!< 自定义路线纹理30, 导航抑制状态  Custom route texture 30, navigation suppression status
    MAMapRouteTextureCustomMax  = 31,      //!< 自定义路线纹理最大值, 与status值对应  Maximum custom route texture value, corresponding to the status value
    MAMapRouteTextureCharge     = 32,      //!< 收费道路  Toll road
    MAMapRouteTextureFree       = 33,      //!< 免费道路  Free road
    MAMapRouteTextureLimit      = 34,      //!< 限行道路  Restricted road
    MAMapRouteTextureSlower     = 35,      //!< 通勤场景下更拥堵道路  More congested road in commuting scenarios
    MAMapRouteTextureFaster     = 36,      //!< 通勤场景下更畅通道路  Smoother roads in commuting scenarios
    MAMapRouteTextureWrong      = 37,      //!< 报错道路  Error roads
    MAMapRouteTextureFerry      = 38,      //!< 轮渡线  Ferry lines
    MAMapRouteTextureNumber,               //!< 纹理个数  Number of textures
};

@interface MAPolylineCapTextureInfo : NSObject
@property (nonatomic, assign) float x1;                                //!< 纹理左上角X  Top-left X of texture
@property (nonatomic, assign) float y1;                                //!< 纹理左上角Y  Top-left Y of texture
@property (nonatomic, assign) float x2;                                //!< 纹理右下角X  Bottom-right X of texture
@property (nonatomic, assign) float y2;                                //!< 纹理右上角Y  Top-right Y of texture
@end

@interface MAPolylineTextureInfo : MAPolylineCapTextureInfo
@property (nonatomic, assign) float textureLen;                        //!< 纹理长度，仅在绘制虚线线型时设置  Texture length, only set when drawing dashed line types
@end

typedef NS_ENUM(NSInteger, MAMapRouteLineWidthType) {
    MAMapRouteLineWidthTypePixel = 0,
    MAMapRouteLineWidthTypeMeter = 1,
};

@interface MARouteOverlayParam : NSObject
@property (nonatomic, assign) BOOL lineExtract;            //!< 是否抽稀  Whether to thin out
@property (nonatomic, assign) BOOL useColor;               //!< 是否使用颜色  Whether to use color
@property (nonatomic, assign) BOOL usePoint;               //!< 是否使用Point点  Whether to use Point
@property (nonatomic, assign) BOOL useCap;                 //!< 是否使用线帽  Whether to use line caps
@property (nonatomic, assign) BOOL canBeCovered;           //!< 能否被覆盖  Whether it can be covered
@property (nonatomic, assign) BOOL showArrow;              //!< 是否显示箭头 上层控制箭头是否显示  Whether to display arrows Upper layer controls whether arrows are displayed
@property (nonatomic, assign) BOOL needColorGradient;      //!< 是否需要渐变  Whether gradient is needed
@property (nonatomic, assign) BOOL clickable;               //!< 是否可点击  Is it clickable
@property (nonatomic, assign) int32_t lineWidth;          //!< 线宽  Line width
@property (nonatomic, assign) int32_t borderLineWidth;    //!< 边线宽  Border width
@property (nonatomic, strong) UIImage *fillMarkerImage;     //!< 里线纹理id  Inner line texture ID
@property (nonatomic, strong) UIImage *simple3DFillMarkerImage; //!< 简易三维下里线纹理  Inner line texture in simple 3D
@property (nonatomic, strong) UIImage *borderMarkerImage;   //!< 边线纹理id  Border texture ID
@property (nonatomic, assign) uint32_t fillColor;          //!< 填充颜色  Fill color
@property (nonatomic, assign) uint32_t borderColor;        //!< 边颜色  Border color
@property (nonatomic, assign) uint32_t selectFillColor;    //!< 选中的填充颜色  Selected fill color
@property (nonatomic, assign) uint32_t unSelectFillColor;  //!< 未选中的填充颜色  Unselected fill color
@property (nonatomic, assign) uint32_t selectBorderColor;  //!< 选中的边线颜色  Selected border color
@property (nonatomic, assign) uint32_t unSelectBorderColor;//!< 未选中的边线颜色  Unselected border color
@property (nonatomic, assign) uint32_t pointDistance;      //!< 两点间距离  Distance between two points
@property (nonatomic, assign) uint32_t priority;           //!< 设置item的优先级(只有usePoint为true有效)  Set the priority of the item (only valid when usePoint is true)
@property (nonatomic, assign) MAMapRouteTexture routeTexture;           //!< 路线纹理枚举 具体参考MapRouteTexture  Route texture enumeration, refer to MapRouteTexture for details
@property (nonatomic, strong) MAPolylineTextureInfo *lineTextureInfo;        //!< 纹理坐标参数  Texture coordinate parameters
@property (nonatomic, strong) MAPolylineTextureInfo *lineSimple3DTextureInfo;//!< 简易三维下纹理坐标参数  Simplified 3D texture coordinate parameters
@property (nonatomic, strong) MAPolylineCapTextureInfo *lineCapTextureInfo;  //!< 线帽纹理参数  Line cap texture parameters
@property (nonatomic, assign) NSString *lineBorderQuery;                //!< 边线纹理资源URL地址  Edge texture resource URL
@property (nonatomic, assign) NSString *lineFillQuery;                  //!< 中心线纹理资源URL地址  Centerline texture resource URL
@property (nonatomic, assign) MAMapRouteLineWidthType lineWidthType;        //!< 线宽类型  Line width type
@end


typedef NS_ENUM(NSInteger,  MAMapRouteHighLightType) {
    MAMapRouteHighLightTypeNone = 0,        //!< 无高亮效果  No highlight effect
    MAMapRouteHighLightTypeSegment          //!< 有一段路高亮，其他路段非高亮显示  One section of the road is highlighted, while other sections are not highlighted
};

@interface MARouteOverlayHighLightParam : NSObject
@property (nonatomic, assign) uint32_t fillColorHightLight;              //!< 高亮路段的填充颜色  The fill color of the highlighted section
@property (nonatomic, assign) uint32_t borderColorHightLight;            //!< 高亮路段的边缘颜色  The edge color of the highlighted section
@property (nonatomic, assign) uint32_t fillColorNormal;                  //!< 非高亮路段的填充颜色  The fill color of the non-highlighted section
@property (nonatomic, assign) uint32_t borderColorNormal;                //!< 非高亮路段的边缘颜色  The edge color of the non-highlighted section
@property (nonatomic, assign) uint32_t arrowColorNormal;                 //!< 非高亮路段的鱼骨线颜色，高亮路段使用纹理原来的颜色  The color of the fishbone line in the non-highlighted section, the highlighted section uses the original color of the texture
@end


/**
 * @brief   路线交通状态  route traffic status
 */
@interface  MAMapRouteOverlayTrafficState : NSObject
@property (nonatomic, assign) uint32_t state;                            //!< 路线状态 4B  route status 4B
@property (nonatomic, assign) uint32_t point2DIndex;                     //!< 二维起始坐标点索引 4B  2D starting coordinate point index 4B
@property (nonatomic, assign) uint32_t point3DIndex;                     //!< 三维起始坐标点索引 4B  3D starting coordinate point index 4B
@property (nonatomic, assign) uint32_t point3DCount;                     //!< 三维坐标点个数 4B  number of 3D coordinate points 4B
@end

/**
 * @brief   路线颜色    Route color
 */
@interface MAMapRouteOverlayColorIndex : NSObject
@property (nonatomic, assign) uint32_t nColor;                           //!< 路线颜色(ARGB)  Route color(ARGB)
@property (nonatomic, assign) uint32_t point2DIndex;                     //!< 二维起始坐标点索引 (如无二维坐标)  2D starting coordinate point index (if no 2D coordinates)
@property (nonatomic, assign) uint32_t point3DIndex;                     //!< 三维起始坐标点索引 4B  3D starting coordinate point index 4B
@property (nonatomic, assign) uint32_t point3DCount;                     //!< 三维坐标点个数 4B  number of 3D coordinate points 4B
@end

/**
 * @brief   路线道路名称   Route road name
 */
@interface MAMapRouteOverlayRoadName : NSObject
@property (nonatomic, copy) NSString *name;                          //!< 道路名称字符串, UTF8编码  Road name string, UTF8 encoding
@property (nonatomic, assign) uint32_t point2DIndex;                     //!< 道路对应的二维形点起始索引 4B  Starting index of 2D shape points for road (4B)
@property (nonatomic, assign) uint32_t point2DSize;                      //!< 道路对应的二维形点个数 4B  Number of 2D shape points for road (4B)
@property (nonatomic, assign) uint32_t point3DIndex;                     //!< 道路对应的三维形点起始索引 4B  Starting index of 3D shape points for the road 4B
@property (nonatomic, assign) uint32_t point3DSize;                      //!< 道路对应的三维形点个数 4B  Number of 3D shape points for the road 4B
@property (nonatomic, assign) uint32_t roadLength;                       //!< 道路长度 4B  Road length 4B
@property (nonatomic, assign) uint32_t roadClass;                        //!< 道路等级 4B  Road level 4B
@end

@interface MAMapPoint2F : NSObject
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@end

@interface MAMapPoint3F : MAMapPoint2F
@property (nonatomic, assign) CGFloat z;
@end

@interface MAMapRouteOverlayData : NSObject
@property (nonatomic, assign) uint32_t checkFlag;
@property (nonatomic, assign) uint32_t routeType;
@property (nonatomic, copy) NSArray<MAMapPoint2F *> *point2DArray;
@property (nonatomic, copy) NSArray<MAMapRouteOverlayTrafficState *> *trafficStateArray;
@property (nonatomic, copy) NSArray<MAMapRouteOverlayRoadName *> *roadNameArray;
@property (nonatomic, copy) NSArray<NSNumber *> *point2DFlagArray;
@property (nonatomic, copy) NSArray<MAMapPoint3F *> *point3DArray;
@property (nonatomic, copy) NSArray<NSNumber *> *point3DFlagArray;
@property (nonatomic, copy) NSArray<MAMapRouteOverlayColorIndex *> *colorIndexArray;
@end

NS_ASSUME_NONNULL_END
#endif
