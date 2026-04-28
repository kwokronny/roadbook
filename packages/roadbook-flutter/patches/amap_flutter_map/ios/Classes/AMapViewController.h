//
//  AMapViewController.h
//  amap_flutter_map
//
//  Created by lly on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#if !TARGET_OS_SIMULATOR
#import <MAMapKit/MAMapKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface AMapViewController : NSObject<FlutterPlatformView>

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
                    registrar:(NSObject<FlutterPluginRegistrar>*)registrar;

@end

NS_ASSUME_NONNULL_END
