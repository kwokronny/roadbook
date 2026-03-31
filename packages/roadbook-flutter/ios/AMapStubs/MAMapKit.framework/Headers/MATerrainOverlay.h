//
//  MATopographyOverlay.h
//  MAMapKit
//
//  Created by JZ on 2021/3/17.
//  Copyright © 2021 Amap. All rights reserved.
//

#import "MAMapKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface MATerrainOverlay : MATileOverlay

///terrainURLTemplate获取地形数据，默认使用高德地形数据
///terrainURLTemplate obtains terrain data, defaulting to AutoNavi terrain data
@property (readonly) NSString *terrainURLTemplate;

///terrainTextureURLTemplate获取地形纹理数据，默认使用高德卫星数据
///terrainTextureURLTemplate obtains terrain texture data, defaulting to AutoNavi satellite imagery
@property (readonly) NSString *terrainTextureURLTemplate;

@property (strong, nonatomic) UIImage *terrainDefalutImage;

/**
 * @brief 初始化地形overlay
 * initialize terrain overlay
 */
- (instancetype)initDefaultTerrainOverlay;

@end

NS_ASSUME_NONNULL_END
