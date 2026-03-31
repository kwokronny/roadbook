//
//  MALineDrawType.h
//  MapKit_static
//
//  Created by yi chen on 14-7-30.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"

#ifndef MapKit_static_MALineDrawType_h
#define MapKit_static_MALineDrawType_h

enum MALineJoinType
{
    kMALineJoinBevel,   ///< 斜面连接点   Bevel join
    kMALineJoinMiter,   ///< 斜接连接点   Miter join
    kMALineJoinRound    ///< 圆角连接点   Round join
};
typedef enum MALineJoinType MALineJoinType;

enum MALineCapType
{
    kMALineCapButt,     ///< 普通头   Butt cap
    kMALineCapSquare,   ///< 扩展头   Square cap
    kMALineCapArrow,    ///< 箭头   Arrow
    kMALineCapRound     ///< 圆形头   Round cap
};
typedef enum MALineCapType MALineCapType;

///虚线类型
enum MALineDashType
{
    kMALineDashTypeNone = 0,     ///<不画虚线   No dash
    kMALineDashTypeSquare,       ///<方块样式   Square style
    kMALineDashTypeDot,          ///<圆点样式   Dot style
};
typedef enum MALineDashType MALineDashType;

#endif
