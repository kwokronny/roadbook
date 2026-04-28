//
//  MAOverlayPathRenderer.h
//  MAMapKit
//
//
//  Copyright (c) 2011年 Amap. All rights reserved.
//

#import "MAConfig.h"
#import <UIKit/UIKit.h>
#import "MAOverlayRenderer.h"
#import "MAPathShowRange.h"

///该类设置overlay绘制的属性，可以使用该类的子类MACircleRenderer, MAPolylineRenderer, MAPolygonRenderer或者继承该类
///This class sets the properties for overlay drawing, and you can use its subclasses MACircleRenderer, MAPolylineRenderer, MAPolygonRenderer or inherit from this class
@interface MAOverlayPathRenderer : MAOverlayRenderer

///填充颜色,默认是kMAOverlayRendererDefaultFillColor
///Fill color, default is kMAOverlayRendererDefaultFillColor
@property (nonatomic, retain) UIColor *fillColor;

///笔触颜色,默认是kMAOverlayRendererDefaultStrokeColor
///stroke color, default is kMAOverlayRendererDefaultStrokeColor
@property (nonatomic, retain) UIColor *strokeColor;

///笔触宽度, 单位屏幕点坐标，默认是0
///stroke width, in screen points, default is 0
@property (nonatomic, assign) CGFloat lineWidth;

///LineJoin,默认是kMALineJoinBevel
///LineJoin, default is kMALineJoinBevel
@property (nonatomic, assign) MALineJoinType lineJoinType;

///LineCap,默认是kMALineCapButt
///LineCap, default is kMALineCapButt
@property (nonatomic, assign) MALineCapType lineCapType;

///MiterLimit,默认是2.f
///MiterLimit, default is 2.f
@property (nonatomic, assign) CGFloat miterLimit;

///虚线类型, since 5.5.0
///line dash pattern,  since 5.5.0
@property (nonatomic, assign) MALineDashType lineDashType;

///是否抽稀，默认为YES，since 10.0.8000
///Whether to thin, default is YES,  since 10.0.8000
@property (nonatomic, assign) BOOL reducePoint;
@end
