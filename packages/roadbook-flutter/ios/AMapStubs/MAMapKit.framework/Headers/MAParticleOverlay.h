//
//  MAParticleOverlay.h
//  MAMapKit
//
//  Created by liubo on 2018/9/19.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_ParticleSystem

#import "MAShape.h"
#import "MAOverlay.h"
#import "MAParticleOverlayOptions.h"

#pragma mark - MAParticleOverlay

///该类用于定义一个粒子MAParticleOverlay, 通常MAParticleOverlay是MAParticleOverlayRenderer的model. since 6.5.0
///This class is used to define a particle MAParticleOverlay, usually MAParticleOverlay is the model of MAParticleOverlayRenderer. since 6.5.0
@interface MAParticleOverlay : MAShape <MAOverlay>

/**
 * @brief 根据粒子覆盖物选项option生成MAParticleOverlay
 * Generate MAParticleOverlay based on the particle overlay option
 * @param option 粒子覆盖物选项option
 * Particle overlay option
 * @return 新生成的粒子覆盖物MAParticleOverlay
 * Newly generated MAParticleOverlay
 */
+ (instancetype)particleOverlayWithOption:(MAParticleOverlayOptions *)option;

///当前粒子覆盖物的option，如果需要修改option的配置，需要修改后重新调用setOverlayOption:方法。
///The option of the current particle overlay, if you need to modify the configuration of the option, you need to call the setOverlayOption: method again after modification
@property (nonatomic, strong, readonly) MAParticleOverlayOptions *overlayOption;

/**
 * @brief 更新粒子覆盖物选项option
 * Update the particle overlay option
 * @param overlayOption 要更新的粒子覆盖物选项
 * The particle overlay option to be updated
 */
- (void)updateOverlayOption:(MAParticleOverlayOptions *)overlayOption;

@end

#endif
