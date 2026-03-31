//
//  MAShape.h
//  MAMapKit
//
//  
//  Copyright (c) 2011年 Amap. All rights reserved.
//

#import "MAConfig.h"
#import <Foundation/Foundation.h>
#import "MAAnnotation.h"
#import "MABaseOverlay.h"

///该类为一个抽象类，定义了基于MAAnnotation的MAShape类的基本属性和行为，不能直接使用，必须子类化之后才能使用
///This is an abstract class that defines the basic properties and behaviors of the MAShape class based on MAAnnotation. It cannot be used directly and must be subclassed before use.
@interface MAShape : MABaseOverlay <MAAnnotation> {

    NSString *_title;       ///<标题   Title
    NSString *_subtitle;    ///<副标题   Subtitle
}

///标题  Title
@property (nonatomic, copy) NSString *title;

///副标题  Subtitle
@property (nonatomic, copy) NSString *subtitle;

@end
