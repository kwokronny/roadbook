//
//  MAMultiPointOverlayRenderer.h
//  MAMapKit
//
//  Created by hanxiaoming on 2017/4/11.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_MAMultiPoint

#import "MAMultiPointOverlay.h"
#import "MAOverlayRenderer.h"

@class MAMultiPointOverlayRenderer;

///MAMultiPointOverlayRenderer代理（since 5.1.0）
///MAMultiPointOverlayRenderer delegate  since 5.1.0
@protocol MAMultiPointOverlayRendererDelegate <NSObject>
@optional

/**
 @brief 点击海量点图层回调
 Callback for clicking on a massive point layer

 @param renderer 海量点图层渲染器
 Massive point layer renderer
 @param item 被点击的单个点对象
 The single point object that was clicked
 */
- (void)multiPointOverlayRenderer:(MAMultiPointOverlayRenderer *)renderer didItemTapped:(MAMultiPointItem *)item;

@end

///海量点渲染renderer（since 5.1.0）。 注意：为了保证渲染效率，纹理不受alpha参数影响，如果需要设置透明度，请更换icon。
///Massive point rendering renderer (since 5.1.0).   Note: To ensure rendering efficiency, textures are not affected by the alpha parameter. If you need to set transparency, please change the icon.
@interface MAMultiPointOverlayRenderer : MAOverlayRenderer

///MAMultiPointOverlayRendererDelegate代理对象
///MAMultiPointOverlayRendererDelegate delegate object
@property (nonatomic, weak) id<MAMultiPointOverlayRendererDelegate> delegate;

///标注纹理图片
///Label texture image
@property (nonatomic, strong) UIImage *icon;

///纹理渲染大小，默认为icon图片大小
///texture rendering size, default is the icon image size
@property (nonatomic, assign) CGSize pointSize;

///经纬度对应图片中的位置，默认为(0.5,0.5)，范围[0-1] 负值自动取其绝对值 左上角为 (0,0) 右下角为 (1,1)
///latitude and longitude correspond to the position in the image, default is (0.5,0.5), range [0-1] negative values automatically take their absolute value, top-left corner is (0,0) bottom-right corner is (1,1)
@property (nonatomic, assign) CGPoint anchor;

///对应的overlay
///Corresponding overlay
@property (nonatomic, readonly) MAMultiPointOverlay *multiPointOverlay;

///初始化方法
///Initialization method
- (instancetype)initWithMultiPointOverlay:(MAMultiPointOverlay *)multiPointOverlay;

@end

#endif
