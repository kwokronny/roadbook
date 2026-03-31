//
//  MAUserLocationRepresentation.h
//  MAMapKit
//
//  Created by shaobin on 16/12/27.
//  Copyright © 2016年 Amap. All rights reserved.
//

#import "MAConfig.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kAccuracyCircleDefaultColor [UIColor colorWithRed:136/255.0 green:166/255.0 blue:227/255.0 alpha:.3]

///用户位置显示样式控制
///User location display style control
@interface MAUserLocationRepresentation : NSObject

///精度圈是否显示，默认YES
///Whether to show the accuracy circle, default is YES
@property (nonatomic, assign) BOOL showsAccuracyRing;
///是否显示方向指示(MAUserTrackingModeFollowWithHeading模式开启)。默认为YES
///Whether to show the direction indicator (MAUserTrackingModeFollowWithHeading mode enabled). Default is YES
@property (nonatomic, assign) BOOL showsHeadingIndicator;
///精度圈 填充颜色, 默认 kAccuracyCircleDefaultColor
///Accuracy circle fill color, default is kAccuracyCircleDefaultColor
@property (nonatomic, strong) UIColor *fillColor;
///精度圈 边线颜色, 默认 kAccuracyCircleDefaultColor
///Accuracy circle border color; default is kAccuracyCircleDefaultColor
@property (nonatomic, strong) UIColor *strokeColor;
///精度圈 边线宽度，默认0
///Accuracy circle border width, default is 0
@property (nonatomic, assign) CGFloat lineWidth;

///定位点背景色，不设置默认白色
///Positioning point background color, default white if not set
@property (nonatomic, strong) UIColor *locationDotBgColor;
///定位点蓝色圆点颜色，不设置默认蓝色
///Positioning point blue dot color, default blue if not set
@property (nonatomic, strong) UIColor *locationDotFillColor;
///内部蓝色圆点是否使用律动效果, 默认YES
///Whether to use pulsating effect for inner blue dot, default YES
@property (nonatomic, assign) BOOL enablePulseAnnimation;
///定位图标, 与蓝色原点互斥
///Location icon, mutually exclusive with the blue dot
@property (nonatomic, strong) UIImage* image;

@end
