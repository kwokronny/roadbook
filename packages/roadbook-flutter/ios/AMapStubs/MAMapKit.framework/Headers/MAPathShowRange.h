//
//  MAPathShowRange.h
//  MAMapKit
//
//  Created by shaobin on 2019/12/31.
//  Copyright © 2019 Amap. All rights reserved.
//

#ifndef MAPathShowRange_h
#define MAPathShowRange_h

struct MAPathShowRange {
    float begin;         ///<起点位置，整数部分表示起点索引，小数部分表示在线段上的位置   Start position, the integer part represents the start index, the decimal part represents the position on the segment
    float end;           ///<终点位置，整数部分表示起点索引，小数部分表示在线段上的位置   End position, the integer part represents the start index, the decimal part represents the position on the segment
};

typedef struct MAPathShowRange MAPathShowRange;

static inline MAPathShowRange MAPathShowRangeMake(float begin, float end) {
    return (MAPathShowRange){begin, end};
}


#endif /* MAPathShowRange_h */
