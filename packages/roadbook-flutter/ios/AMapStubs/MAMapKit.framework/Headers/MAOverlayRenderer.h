//
//  MAOverlayRenderer.h
//  MAMapKit
//
//
//  Copyright (c) 2011年 Amap. All rights reserved.
//

#import "MAConfig.h"
#import <UIKit/UIKit.h>
#import "MAOverlay.h"
#import "MALineDrawType.h"

#define kMAOverlayRendererDefaultStrokeColor [UIColor colorWithRed:0.3 green:0.63 blue:0.89 alpha:0.8]
#define kMAOverlayRendererDefaultFillColor [UIColor colorWithRed:0.77 green:0.88 blue:0.94 alpha:0.8]

@protocol MAOverlayRenderDelegate,MTLRenderCommandEncoder;

///该类是地图覆盖物Renderer的基类, 提供绘制overlay的接口但并无实际的实现（render相关方法只能在重写后的glRender方法中使用）
///This class is the base class of the map overlay Renderer, providing an interface for drawing overlays but without actual implementation (render-related methods can only be used in the overridden glRender method)
@interface MAOverlayRenderer : NSObject {
    @protected
    GLuint _strokeTextureID;
    CGSize _strokeTextureSize;
    BOOL _needsUpdate;
    BOOL _needsLoadStrokeTexture;
}

///由地图添加时，不要手动设置。如果不是使用mapview进行添加，则需要手动设置。（since 5.1.0）
///When added by the map, do not set manually. If not added using mapview, manual setting is required.（since 5.1.0）
@property (nonatomic, weak) id<MAOverlayRenderDelegate> rendererDelegate;

///关联的overlay对象
///Associated overlay object
@property (nonatomic, readonly, retain) id <MAOverlay> overlay;

///用于生成笔触纹理id的图片（支持非PowerOfTwo图片; 如果您需要减轻绘制产生的锯齿,您可以参考AMap.bundle中的traffic_texture_blue.png的方式,在image两边增加部分透明像素.)。（since 5.3.0）
///Images used to generate brush stroke texture IDs (supports non-PowerOfTwo images; if you need to reduce aliasing caused by drawing, you can refer to the method in AMap.bundle's traffic_texture_blue.png, adding partially transparent pixels on both sides of the image.). （since 5.3.0）
@property (nonatomic, strong) UIImage *strokeImage;

///笔触纹理id, 修改纹理id参考, 如果strokeImage未指定、尚未加载或加载失败返回0. 注意：仅使用gles环境
///Stroke texture ID, modify texture ID reference, returns 0 if strokeImage is not specified, not yet loaded, or fails to load. Note: Only use gles environment.
@property (nonatomic, readonly) GLuint strokeTextureID __attribute((deprecated("Deprecated, since 7.9.0")));

///透明度[0，1]，默认为1. 使用MAOverlayRenderer类提供的渲染接口会自动应用此属性。（since 5.1.0）
///Opacity [0, 1], default is 1. This property will be automatically applied when using the rendering interface provided by the MAOverlayRenderer class. (since 5.1.0)
@property (nonatomic, assign) CGFloat alpha;

///overlay渲染的scale。（since 5.1.0）
///Scale of overlay rendering.（since 5.1.0）
@property (nonatomic, readonly) CGFloat contentScale;

/**
 * @brief 初始化并返回一个Overlay Renderer
 * initialize and return an Overlay Renderer
 * @param overlay 关联的overlay对象
 * associated overlay object
 * @return 初始化成功则返回overlay view,否则返回nil
 * return the overlay view if initialization is successful, otherwise return nil
 */
- (instancetype)initWithOverlay:(id<MAOverlay>)overlay;

/**
 *  @brief 获取当前地图view矩阵，数组长度为16，无需外界释放. 需要添加至地图后，才能获取有效矩阵数据，否则返回NULL
 *  Get the current map view matrix with an array length of 16, no external release required. Valid matrix data can only be obtained after adding to the map, otherwise returns NULL.
 *  @return 矩阵数组
 *  matrix array
 */
- (float *)getViewMatrix;

/**
 *  @brief 获取当前地图projection矩阵，数组长度为16，无需外界释放. 需要添加至地图后，才能获取有效矩阵数据，否则返回NULL
 *  Get the current map projection matrix with an array length of 16, no need for external release. Valid matrix data can only be obtained after adding it to the map, otherwise returns NULL.
 *  @return 矩阵数组
 *  matrix array
 */
- (float *)getProjectionMatrix;

/**
 *  @brief 获取当前地图中心点偏移，用以把地图坐标转换为gl坐标。需要添加到地图获取才有效。（since 5.1.0）
 *  Get the current map center offset to convert map coordinates to gl coordinates. It only takes effect when added to map acquisition （since 5.1.0）
 *  @return 偏移
 *  offset
 */
- (MAMapPoint)getOffsetPoint;

/**
 *  @brief 获取Metal渲染MTLRenderCommandEncoder对象。注意：打开地图MetalEnable时有效，否则为nil（since 7.9.0）
 *  Obtain the Metal rendering MTLRenderCommandEncoder object. Note: It is valid when MetalEnable is turned on for the map, otherwise it is nil.（since 7.9.0）
 *  @return 偏移
 *  offset
 */
- (id<MTLRenderCommandEncoder>)getCommandEncoder;

/**
 *  @brief 获取当前地图缩放级别，需要添加到地图获取才有效。（since 5.1.0）
 *  Get the current map zoom level, which is only valid when added to the map（since 5.1.0）
 *  @return 缩放级别
 *  Zoom level
 */
- (CGFloat)getMapZoomLevel;

/**
 * @brief 将MAMapPoint转换为opengles可以直接使用的坐标
 * Convert MAMapPoint to coordinates that can be directly used by OpenGLES
 * @param mapPoint MAMapPoint坐标
 * MAMapPoint coordinates
 * @return 直接支持的坐标
 * Directly supported coordinates
 */
- (CGPoint)glPointForMapPoint:(MAMapPoint)mapPoint;

/**
 * @brief 批量将MAMapPoint转换为opengles可以直接使用的坐标
 * Batch convert MAMapPoint to coordinates that can be directly used by opengles
 * @param mapPoints MAMapPoint坐标数据指针
 * MAMapPoint coordinate data pointer
 * @param count     个数
 * count
 * @return 直接支持的坐标数据指针(需要调用者手动释放)
 * Directly supported coordinate data pointer (requires manual release by the caller)
 */
- (CGPoint *)glPointsForMapPoints:(MAMapPoint *)mapPoints count:(NSUInteger)count;

/**
 * @brief 将屏幕尺寸转换为OpenGLES尺寸
 * Convert screen size to OpenGLES size
 * @param windowWidth 屏幕尺寸
 * Screen size
 * @return OpenGLES尺寸
 * OpenGLES size
 */
- (CGFloat)glWidthForWindowWidth:(CGFloat)windowWidth;

/**
 * @brief 绘制函数(子类需要重载来实现)
 * Drawing function (subclasses need to override to implement)
 */
- (void)glRender;

/**
 * @brief 加载纹理图片. 注意：仅使用gles环境（since 5.1.0）
 * Load texture image. Note: Only use gles environment （since 5.1.0）
 * @param textureImage 纹理图片（需满足：长宽相等，且宽度值为2的次幂)
 * Texture image (must meet: width and height are equal, and width value is a power of 2)
 * @return openGL纹理ID, 若纹理加载失败返回0
 * openGL texture ID, if texture loading fails, return 0
 */
- (GLuint)loadTexture:(UIImage *)textureImage __attribute((deprecated("Deprecated, since 7.9.0")));

/**
 * @brief 删除纹理.  注意：仅使用gles环境（since 5.1.0）
 * Delete texture. Note: Only use in GLES environment（since 5.1.0）
 * @param textureId 纹理ID
 * Texture ID
 */
- (void)deleteTexture:(GLuint)textureId __attribute((deprecated("Deprecated, since 7.9.0")));

/**
 * @brief 当关联overlay对象有更新时，调用此接口刷新. since 5.0.0
 * Call this interface to refresh when the associated overlay object is updated. since 5.0.0
 */
- (void)setNeedsUpdate;

@end
