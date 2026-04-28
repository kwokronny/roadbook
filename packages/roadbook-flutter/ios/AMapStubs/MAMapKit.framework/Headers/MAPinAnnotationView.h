//
//  MAPinAnnotationView.h
//  MAMapKitDemo
//
//  Created by songjian on 13-1-7.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#import "MAMapView.h"
#import "MAAnnotationView.h"

///MAPinAnnotationColor
typedef NS_ENUM(NSInteger, MAPinAnnotationColor){
    MAPinAnnotationColorRed = 0,    ///< 红色大头针  Red pin
    MAPinAnnotationColorGreen,      ///< 绿色大头针  Green pin
    MAPinAnnotationColorPurple      ///< 紫色大头针  Purple pin
};

///提供类似大头针效果的annotation view
///Annotation view providing a pin-like effect
@interface MAPinAnnotationView : MAAnnotationView

///大头针的颜色
///The color of the pin
@property (nonatomic) MAPinAnnotationColor pinColor;

///添加到地图时是否使用下落动画效果
///Whether to use a drop animation effect when adding to the map
@property (nonatomic) BOOL animatesDrop;

@end
