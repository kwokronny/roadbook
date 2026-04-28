//
//  MAParticleOverlayOptions.h
//  MAMapKit
//
//  Created by liubo on 2018/9/18.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "MAConfig.h"
#if MA_INCLUDE_OVERLAY_ParticleSystem

#import "MAShape.h"
#import "MAOverlay.h"

#pragma mark - MAParticleOverlayType

///天气类型
///Weather types
typedef NS_ENUM(NSInteger, MAParticleOverlayType)
{
    MAParticleOverlayTypeSunny = 1, ///<晴天  Sunny
    MAParticleOverlayTypeRain,      ///<雨天  Rainy
    MAParticleOverlayTypeSnowy,     ///<雪天  Snowy
    MAParticleOverlayTypeHaze,      ///<雾霾  Haze
};

#pragma mark - MAParticleVelocityGenerate

///粒子的速度生成类. since 6.5.0
///Particle velocity generation class. since 6.5.0
@protocol MAParticleVelocityGenerate <NSObject>
@required

///X轴方向上的速度变化率
///Velocity variation rate in X-axis direction
- (CGFloat)getX;

///Y轴方向上的速度变化率
///Velocity variation rate in Y-axis direction
- (CGFloat)getY;

///Z轴方向上的速度变化率
///Velocity variation rate in Z-axis direction
- (CGFloat)getZ;
@end

#pragma mark - MAParticleRandomVelocityGenerate

///粒子的随机速度生成类. since 6.5.0
///Random speed generation class for particles   since 6.5.0
@interface MAParticleRandomVelocityGenerate : NSObject <MAParticleVelocityGenerate>

/**
 * @brief 根据速度范围值生成粒子的速度变化类
 * Speed variation class for particles based on speed range values
 * @param x1 起始的速度x值
 * Initial speed x value
 * @param y1 起始的速度y值
 * Initial speed y value
 * @param z1 起始的速度z值
 * Initial speed z value
 * @param x2 结束的速度x值
 * Final speed x value
 * @param y2 结束的速度y值
 * Final speed y value
 * @param z2 结束的速度z值
 * Final speed z value
 * @return 生成粒子的颜色变化类
 * Color variation class for particle generation
 */
- (instancetype)initWithBoundaryValueX1:(float)x1 Y1:(float)y1 Z1:(float)z1 X2:(float)x2 Y2:(float)y2 Z2:(float)z2;

@end

#pragma mark - MAParticleColorGenerate

///粒子的颜色生成类. since 6.5.0
///Particle color generation class.  since 6.5.0
@protocol MAParticleColorGenerate <NSObject>
@required
///生成的颜色值，需为包含四个float值的数组。
///The generated color value should be an array containing four float values.
- (float *)getColor;
@end

#pragma mark - MAParticleRandomColorGenerate

///粒子的随机颜色生成类. since 6.5.0
///Random color generation class for particles.  since 6.5.0
@interface MAParticleRandomColorGenerate : NSObject <MAParticleColorGenerate>

/**
 * @brief 根据颜色范围值生成粒子的颜色变化类
 * Particle color variation class based on color range values
 * @param r1 起始的颜色r值
 * Starting color r value
 * @param g1 起始的颜色g值
 * Starting color g value
 * @param b1 起始的颜色b值
 * Starting color b value
 * @param a1 起始的颜色a值
 * Starting color a value
 * @param r2 结束的颜色r值
 * Ending color r value
 * @param g2 结束的颜色g值
 * Ending color g value
 * @param b2 结束的颜色b值
 * Ending color b value
 * @param a2 结束的颜色a值
 * Ending color a value
 * @return 生成粒子的颜色变化类
 * Particle color variation class
 */
- (instancetype)initWithBoundaryColorR1:(float)r1 G1:(float)g1 B1:(float)b1 A1:(float)a1 R2:(float)r2 G2:(float)g2 B2:(float)b2 A2:(float)a2;

@end

#pragma mark - MAParticleRotationGenerate

///粒子的角度生成类. since 6.5.0
///Particle angle generation class.  since 6.5.0
@protocol MAParticleRotationGenerate <NSObject>
@required
///生成的角度值
///Generated angle value
- (float)getRotate;
@end

#pragma mark - MAParticleConstantRotationGenerate

///粒子的固定角度生成类. since 6.5.0
///Particle fixed angle generation class.  since 6.5.0
@interface MAParticleConstantRotationGenerate : NSObject <MAParticleRotationGenerate>

/**
 * @brief 根据角度生成粒子的角度变化类
 * Angle variation class for generating particles based on angle
 * @param rotate 固定的角度
 * Fixed angle
 * @return 生成粒子的角度变化类
 * Angle variation class for generating particles
 */
- (instancetype)initWithRotate:(float)rotate;

@end

#pragma mark - MAParticleSizeGenerate

///粒子的大小生成类. since 6.5.0
///Particle size generation class.  since 6.5.0
@protocol MAParticleSizeGenerate <NSObject>
@required

///X轴上变化比例
///Variation ratio on the X-axis
- (float)getSizeX:(float)timeFrame;

///Y轴上变化比例
///Variation ratio on the Y-axis
- (float)getSizeY:(float)timeFrame;

///Z轴上变化比例
///Variation ratio on the Z-axis
- (float)getSizeZ:(float)timeFrame;
@end

#pragma mark - MAParticleCurveSizeGenerate

///粒子的大小变化类. since 6.5.0
///Particle size variation class. since 6.5.0
@interface MAParticleCurveSizeGenerate : NSObject <MAParticleSizeGenerate>

/**
 * @brief 根据三个轴上的变化比例生成粒子的大小变化类
 * Generate particle size variation class based on the scaling ratio on three axes
 * @param x X轴上变化比例
 * Variation ratio on the X-axis
 * @param y Y轴上变化比例
 * Variation ratio on the Y-axis
 * @param z Z轴上变化比例
 * Variation ratio on the Z-axis
 * @return 生成粒子的大小变化类
 * Generate particle size variation class
 */
- (instancetype)initWithCurveX:(float)x Y:(float)y Z:(float)z;

@end

#pragma mark - MAParticleEmissionModuleOC

///粒子的发射率类，每隔多少时间发射粒子数量，越多会越密集. since 6.5.0
///Particle emission rate class, the number of particles emitted per unit time, the more the denser.  since 6.5.0
@interface MAParticleEmissionModuleOC : NSObject

/**
 * @brief 根据发射数量和发射间隔生成粒子的发射率类。关系为:"发射数量为rate粒子->等待rateTime间隔->发射数量为rate粒子->等待rateTime间隔"循环
 * Generate the emission rate class of particles based on the number of emissions and the emission interval. The relationship is: "emit rate particles -> wait rateTime interval -> emit rate particles -> wait rateTime interval
 * @param rate 发射数量(不能为0)
 * Emission count (cannot be 0)
 * @param rateTime 发射间隔
 * Emission interval
 * @return 生成粒子的发射率类
 * Emission rate class of generated particles
 */
- (instancetype)initWithEmissionRate:(int)rate rateTime:(int)rateTime;

@end

#pragma mark - MAParticleShapeModule

///粒子的发射区域模型协议. since 6.5.0
///Emission area model protocol for particles. since 6.5.0
@protocol MAParticleShapeModule <NSObject>
@required

///新生成的发射点坐标，需为包含三个float值的数组。
///Newly generated emission point coordinates, must be an array containing three float values
- (float *)getPoint;

///坐标是否按比例生成
///Are coordinates generated proportionally
- (BOOL)isRatioEnable;
@end

#pragma mark - MAParticleSinglePointShapeModule

///粒子的发射单个点区域模型. since 6.5.0
///The emission single-point area model of particles. since 6.5.0
@interface MAParticleSinglePointShapeModule : NSObject <MAParticleShapeModule>

/**
 * @brief 生成粒子的发射矩形区域模型，以比例的形式设置发射区域
 * The emission rectangular area model of particles, setting the emission area in proportion
 * @param x x坐标比例
 * X-coordinate proportion
 * @param y y坐标比例
 * Y-coordinate proportion
 * @param z z坐标比例
 * Z-coordinate proportion
 * @param isUseRatio 是否按比例
 * Is it proportional
 * @return 新生成的粒子发射单个点区域模型
 * Newly generated particle emission single-point area model
 */
- (instancetype)initWithShapeX:(float)x Y:(float)y Z:(float)z useRatio:(BOOL)isUseRatio;

@end

#pragma mark - MAParticleRectShapeModule

///粒子的发射矩形区域模型. since 6.5.0
///Particle emission rectangular area model. since 6.5.0
@interface MAParticleRectShapeModule : NSObject <MAParticleShapeModule>

/**
 * @brief 生成粒子的发射矩形区域模型，以比例的形式设置发射区域。
 * Particle emission rectangular area model, setting the emission area in the form of proportions
 * @param left 左边距比例
 * Left margin ratio
 * @param top 上边距比例
 * Top margin ratio
 * @param right 右边距比例
 * Right margin ratio
 * @param bottom 下边距比例
 * Bottom margin ratio
 * @param isUseRatio 是否按比例
 * Is it proportional
 * @return 新生成的粒子发射矩形区域模型
 * Newly generated particle emission rectangular area model
 */
- (instancetype)initWithLeft:(float)left top:(float)top right:(float)right bottom:(float)bottom useRatio:(BOOL)isUseRatio;

@end

#pragma mark - MAParticleOverLifeModuleOC

///粒子生命周期过程中状态变化，包含速度、旋转和颜色的变化. since 6.5.0
///State changes during the particle life cycle, including changes in velocity, rotation, and color. since 6.5.0
@interface MAParticleOverLifeModuleOC : NSObject

/**
 * @brief 设置粒子生命周期过程中速度的变化
 * Set the change in speed during the particle's life cycle
 * @param velocity 遵循MAParticleVelocityGenerate协议的速度生成类
 * Speed generation class that follows the MAParticleVelocityGenerate protocol
 */
- (void)setVelocityOverLife:(id<MAParticleVelocityGenerate>)velocity;

/**
 * @brief 设置粒子生命周期过程中角度的变化
 * Set the change in angle during the particle's life cycle
 * @param rotation 遵循MAParticleRotationGenerate协议的角度生成类
 * Angle generation class conforming to the MAParticleRotationGenerate protocol
 */
- (void)setRotationOverLife:(id<MAParticleRotationGenerate>)rotation;

/**
 * @brief 设置粒子生命周期过程中大小的变化
 * Set the size variation during the particle's lifecycle
 * @param size 遵循MAParticleSizeGenerate协议的大小生成类
 * Size generation class conforming to the MAParticleSizeGenerate protocol
 */
- (void)setSizeOverLife:(id<MAParticleSizeGenerate>)size;

/**
 * @brief 设置粒子生命周期过程中颜色的变化
 * Set color changes during the particle lifecycle
 * @param color 遵循MAParticleColorGenerate协议的颜色生成类
 * A color generation class conforming to the MAParticleColorGenerate protocol
 */
- (void)setColorOverLife:(id<MAParticleColorGenerate>)color;

@end

#pragma mark - MAParticleOverlayOptions

///该类用于定义一个粒子覆盖物显示选项. since 6.5.0
///This class is used to define display options for particle overlays. since 6.5.0
@interface MAParticleOverlayOptions : NSObject

///option选项是否可见. (默认YES)
///Whether the option is visible. (Default YES)
@property (nonatomic, assign) BOOL visibile;

///粒子系统存活时间. (默认5000,单位毫秒))
///Particle system lifetime. (Default 5000, unit milliseconds)
@property (nonatomic, assign) NSTimeInterval duration;

///粒子系统是否循环. (默认YES)
///Whether the particle system loops. (Default YES)
@property (nonatomic, assign) BOOL loop;

///粒子系统的粒子最大数量. (默认100)
///Maximum number of particles in the particle system. (Default 100)
@property (nonatomic, assign) NSInteger maxParticles;

///粒子系统的粒子图标. (默认nil)
///Particle icon of the particle system. (Default nil)
@property (nonatomic, strong) UIImage *icon;

///每个粒子的初始大小. (默认(32.f*[[UIScreen mainScreen] nativeScale], 32.f*[[UIScreen mainScreen] nativeScale]),单位:OpenGLESPixels数量，计算方式为: OpenGLESPixels = ScreenPoint数量 * [[UIScreen mainScreen] nativeScale])
///Initial size of each particle.(Default(32.f*[[UIScreen mainScreen] nativeScale], 32.f*[[UIScreen mainScreen] nativeScale]),Unit: OpenGLESPixels quantity, calculated as: OpenGLESPixels = ScreenPoint quantity * [[UIScreen mainScreen] nativeScale])
@property (nonatomic, assign) CGSize startParticleSize;

///每个粒子的存活时间. (默认5000,单位毫秒)
///Lifetime of each particle. (Default 5000, unit: milliseconds)
@property (nonatomic, assign) NSTimeInterval particleLifeTime;

///每个粒子的初始颜色. (默认nil)
///Initial color of each particle. (Default nil)
@property (nonatomic, strong) id<MAParticleColorGenerate> particleStartColor;

///每个粒子的初始速度. (默认nil)
///Initial velocity of each particle. (Default nil)
@property (nonatomic, strong) id<MAParticleVelocityGenerate> particleStartSpeed;

///粒子的发射率,参考 MAParticleEmissionModuleOC 类. (默认nil)
///The emission rate of particles, refer to the MAParticleEmissionModuleOC class. (default nil)
@property (nonatomic, strong) MAParticleEmissionModuleOC *particleEmissionModule;

///粒子的发射区域模型. (默认nil)
///The emission area model of particles. (default nil)
@property (nonatomic, strong) id<MAParticleShapeModule> particleShapeModule;

///粒子生命周期过程,参考 MAParticleOverLifeModuleOC 类. (默认nil)
///The life cycle process of particles, refer to the MAParticleOverLifeModuleOC class. (default nil)
@property (nonatomic, strong) MAParticleOverLifeModuleOC *particleOverLifeModule;

@end

#pragma mark - MAParticleOverlayOptionsFactory

///该类用于根据指定的天气类型，生成SDK内置的天气粒子覆盖物显示选项option. since 6.5.0
///This class is used to generate the built-in weather particle overlay display option based on the specified weather type. since 6.5.0
@interface MAParticleOverlayOptionsFactory : NSObject

/**
 * @brief 根据指定的天气类型生成粒子覆盖物显示选项option
 * Generate particle overlay display options based on specified weather types
 * @param particleType 天气类型
 * weather type
 * @return 新生成的粒子覆盖物显示选项option
 * newly generated particle overlay display options
 */
+ (NSArray<MAParticleOverlayOptions *> *)particleOverlayOptionsWithType:(MAParticleOverlayType)particleType;

@end

#endif
