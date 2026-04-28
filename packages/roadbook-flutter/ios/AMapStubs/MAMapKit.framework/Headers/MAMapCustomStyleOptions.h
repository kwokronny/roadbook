//
//  MAMapCustomStyleOptions.h
//  MAMapKit
//
//  Created by ldj on 2018/11/27.
//  Copyright © 2018 Amap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAMapCustomStyleOptions : NSObject

///自定义样式二进制
///Custom style binary
@property (nonatomic, strong) NSData *styleData;

///海外自定义样式文件路径
///Overseas custom style file path
@property (nonatomic, strong) NSString *styleDataOverseaPath;

///设置地图自定义样式对应的styleID，从官网获取
///Set the styleID corresponding to the map custom style, obtained from the official website
@property (nonatomic, strong) NSString *styleId;

///设置自定义纹理文件二进制
///Set custom texture file binary
@property (nonatomic, strong) NSData *styleTextureData;

///样式额外的配置，比如路况，背景颜色等  since 6.7.0
///Additional style configurations, such as traffic conditions, background color, etc.   since 6.7.0
@property (nonatomic, strong) NSData *styleExtraData;

@end

