//
//  MAIndoorInfo.h
//  MAMapKit
//
//  Created by 翁乐 on 5/6/16.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"

#if MA_INCLUDE_INDOOR

#import <Foundation/Foundation.h>

///室内楼层信息
///Indoor floor information
@interface MAIndoorFloorInfo : NSObject
///楼层名
///Floor name
@property (nonatomic, readonly) NSString *floorName;
///楼层index
///Floor index
@property (nonatomic, readonly) int floorIndex;
///楼层别名
///Floor alias
@property (nonatomic, readonly) NSString *floorNona;
///是否属于停车场
///Whether it belongs to a parking lot
@property (nonatomic, readonly) BOOL isPark;
@end

///室内图信息
///Indoor map information
@interface MAIndoorInfo : NSObject
///室内地图中文名
///Indoor map Chinese name
@property (nonatomic, readonly) NSString *cnName;
///室内地图英文名
///Indoor map English name
@property (nonatomic, readonly) NSString *enName;
///室内地图poiID
///Indoor map poiID
@property (nonatomic, readonly) NSString *poiID;
///建筑类型
///Building type
@property (nonatomic, readonly) NSString *buildingType;
///当前楼层index，和floorInfo内部的index相关
///Current floor index, related to the index inside floorInfo
@property (nonatomic, readonly) int activeFloorIndex;
///当前激活的楼层，只和floorInfo相关，与floorInfo内部元素的index无关
///Currently active floor, only related to floorInfo, not related to the index of elements inside floorInfo
@property (nonatomic, readonly) int activeFloorInfoIndex;
///由 MAIndoorFloorInfo 组成，可直接通过 activeFloorInfoIndex 取出当前楼层
///Composed of MAIndoorFloorInfo, the current floor can be directly retrieved through activeFloorInfoIndex
@property (nonatomic, readonly) NSArray *floorInfo;
///楼层数量
///Number of floors
@property (nonatomic, readonly) int numberOfFloor;
///停车场楼层数量
///Number of parking floors
@property (nonatomic, readonly) int numberOfParkFloor;
@end

#endif
