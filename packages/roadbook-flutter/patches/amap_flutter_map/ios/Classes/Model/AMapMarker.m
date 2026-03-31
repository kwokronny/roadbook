//
//  AMapMarker.m
//  amap_flutter_map
//
//  Created by lly on 2020/11/3.
//

#import "AMapMarker.h"
#import "AMapInfoWindow.h"
#if !TARGET_OS_SIMULATOR
#import "MAPointAnnotation+Flutter.h"

@interface AMapMarker ()

@property (nonatomic, strong, readwrite) MAPointAnnotation *annotation;

@end
#endif // !TARGET_OS_SIMULATOR

@implementation AMapMarker

- (instancetype)init {
    self = [super init];
    if (self) {
        _alpha = 1.0;
        _clickable = YES;
        _draggable = NO;
        _visible = YES;
    }
    return self;
}

#if !TARGET_OS_SIMULATOR
- (MAPointAnnotation *)annotation {
    if (_annotation == nil) {
        NSAssert(self.id_ != nil, @"markerid不能为空");
        _annotation = [[MAPointAnnotation alloc] initWithMarkerId:self.id_];
        [self _updateAnnotation];
    }
    return  _annotation;
}
#endif // !TARGET_OS_SIMULATOR

/// 更新marker的信息
/// @param changedMarker 带修改信息的marker
- (void)updateMarker:(AMapMarker *)changedMarker {
    NSAssert((changedMarker != nil && [self.id_ isEqualToString:changedMarker.id_]), @"更新marker数据异常");
    self.alpha = changedMarker.alpha;
    self.anchor = changedMarker.anchor;
    self.clickable = changedMarker.clickable;
    self.draggable = changedMarker.draggable;
    self.flat = changedMarker.flat;
    self.infoWindowEnable = changedMarker.infoWindowEnable;
    self.infoWindow = changedMarker.infoWindow;
    self.position = changedMarker.position;
    self.rotation = changedMarker.rotation;
    self.visible = changedMarker.visible;
    self.zIndex = changedMarker.zIndex;
    
#if !TARGET_OS_SIMULATOR
    if (_annotation) {//Annotation已经被添加，则直接更新其数据
        [self _updateAnnotation];
    }
#endif
}

- (void)_updateAnnotation {
#if !TARGET_OS_SIMULATOR
    _annotation.title = self.infoWindow.title;
    _annotation.subtitle = self.infoWindow.snippet;
    _annotation.coordinate = self.position;
#endif
}


@end
