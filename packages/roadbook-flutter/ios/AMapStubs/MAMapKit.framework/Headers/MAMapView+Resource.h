//
//  MAMapView+Resource.h
//  MAMapKit
//
//  Created by caowei on 2025/4/8.
//  Copyright © 2025 Amap. All rights reserved.
//

#import "MAMapView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MAMapView (Resource)

/// 设置地图资源路径
/// @note 在初始化地图前使用
/// - Parameter path: Amap.bundle的路径
/// - Returns:  返回值 0:成功  1:版本号校验失败  2 路径不存在
/// @since 10.5.0
+ (NSInteger)setBundlePath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
