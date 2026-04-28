//
//  AMapFlutterFactory.m
//  amap_flutter_map
//
//  Created by lly on 2020/10/29.
//

#import "AMapFlutterFactory.h"
#if !TARGET_OS_SIMULATOR
#import <MAMapKit/MAMapKit.h>
#import "AMapViewController.h"
#endif

#if TARGET_OS_SIMULATOR

/// Minimal FlutterPlatformView stub that shows a placeholder label on simulator.
@interface AMapSimulatorPlaceholderView : NSObject <FlutterPlatformView>
- (instancetype)initWithFrame:(CGRect)frame;
@end

@implementation AMapSimulatorPlaceholderView {
    UILabel *_label;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:frame];
        _label.text = @"Map not available on simulator";
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        _label.textColor = [UIColor darkGrayColor];
        _label.numberOfLines = 0;
    }
    return self;
}

- (UIView *)view {
    return _label;
}

@end

#endif // TARGET_OS_SIMULATOR

@implementation AMapFlutterFactory {
  NSObject<FlutterPluginRegistrar>* _registrar;
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
  }
  return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
#if TARGET_OS_SIMULATOR
    return [[AMapSimulatorPlaceholderView alloc] initWithFrame:frame];
#else
    return [[AMapViewController alloc] initWithFrame:frame
                                      viewIdentifier:viewId
                                           arguments:args
                                           registrar:_registrar];
#endif
}
@end
