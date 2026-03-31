//
//  MAAnnotationView.h
//  MAMapKitDemo
//
//  Created by songjian on 13-1-7.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "MAConfig.h"
#import <UIKit/UIKit.h>
#import "MACustomCalloutView.h"

///MAAnnotationView拖动状态
///MAAnnotationView drag state
typedef NS_ENUM(NSInteger, MAAnnotationViewDragState)
{
    MAAnnotationViewDragStateNone = 0,      ///< 静止状态   stationary state
    MAAnnotationViewDragStateStarting,      ///< 开始拖动   start dragging
    MAAnnotationViewDragStateDragging,      ///< 拖动中   dragging
    MAAnnotationViewDragStateCanceling,     ///< 取消拖动   cancel dragging
    MAAnnotationViewDragStateEnding         ///< 拖动结束   end dragging
};

@protocol MAAnnotation;

///标注view
///annotation view
@interface MAAnnotationView : UIView

///复用标识
///reuse identifier
@property (nonatomic, readonly, copy) NSString *reuseIdentifier;

///z值，大值在上，默认为0。类似CALayer的zPosition。zIndex属性只有在viewForAnnotation或者didAddAnnotationViews回调中设置有效。
///z-value, larger values on top, default is 0. Similar to CALayer's zPosition. The zIndex property only takes effect when set in the viewForAnnotation or didAddAnnotationViews callbacks.
@property (nonatomic, assign) NSInteger zIndex;

///关联的annotation
///associated annotation
@property (nonatomic, strong) id <MAAnnotation> annotation;

///显示的image
///Displayed image
@property (nonatomic, strong) UIImage *image;

///image所对应的UIImageView since 5.0.0
///UIImageView corresponding to the image.   since 5.0.0
@property (nonatomic, strong, readonly) UIImageView *imageView;

///自定制弹出框view, 用于替换默认弹出框. 注意:此弹出框不会触发-(void)mapView: didAnnotationViewCalloutTapped: since 5.0.0
///Custom pop-up view, used to replace the default pop-up. Note: This pop-up will not trigger -(void)mapView: didAnnotationViewCalloutTapped: since 5.0.0
@property (nonatomic, strong) MACustomCalloutView *customCalloutView;

///annotationView的中心默认位于annotation的坐标位置，可以设置centerOffset改变view的位置，正的偏移使view朝右下方移动，负的朝左上方，单位是屏幕坐标
///The center of the annotationView is by default located at the coordinate position of the annotation. You can set the centerOffset to change the position of the view. A positive offset moves the view towards the lower right, while a negative one moves it towards the upper left, with units in screen coordinates.
@property (nonatomic) CGPoint centerOffset;

///弹出框默认位于view正中上方，可以设置calloutOffset改变view的位置，正的偏移使view朝右下方移动，负的朝左上方，单位是屏幕坐标
///The pop-up box is by default located above the center of the view, and the position of the view can be changed by setting calloutOffset. A positive offset moves the view to the lower right, and a negative offset moves it to the upper left, in screen coordinates.
@property (nonatomic) CGPoint calloutOffset;

///默认为YES,当为NO时view忽略触摸事件
///Default is YES, when NO the view ignores touch events
@property (nonatomic, getter=isEnabled) BOOL enabled;

///是否高亮
///Whether to highlight
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

///设置是否处于选中状态, 外部如果要选中请使用mapView的selectAnnotation方法
///Set whether it is in the selected state. To select externally, use the selectAnnotation method of mapView
@property (nonatomic, getter=isSelected) BOOL selected;

///是否允许弹出callout
///Whether to allow callout to pop up
@property (nonatomic) BOOL canShowCallout;

///显示在默认弹出框左侧的view
///The view displayed on the left side of the default popup
@property (nonatomic, strong) UIView *leftCalloutAccessoryView;

///显示在默认弹出框右侧的view
///the view displayed on the right side of the default popup
@property (nonatomic, strong) UIView *rightCalloutAccessoryView;

///是否支持拖动
///whether dragging is supported
@property (nonatomic, getter=isDraggable) BOOL draggable;

///当前view的拖动状态
///the dragging state of the current view
@property (nonatomic) MAAnnotationViewDragState dragState;

///弹出默认弹出框时，是否允许地图调整到合适位置来显示弹出框，默认为YES
///whether the map is allowed to adjust to a suitable position to display the popup when the default popup is displayed, default is YES
@property (nonatomic) BOOL canAdjustPositon;

/**
 * @brief 设置是否处于选中状态, 外部如果要选中请使用mapView的selectAnnotation方法
 * Set whether it is in the selected state, if you want to select it externally, use the selectAnnotation method of mapView
 * @param selected 是否选中
 * whether it is selected
 * @param animated 是否使用动画效果
 * whether to use animation effects
 */
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

/**
 * @brief 初始化并返回一个annotation view
 * Initialize and return an annotation view
 * @param annotation      关联的annotation对象
 * associated annotation object
 * @param reuseIdentifier 如果要重用view,传入一个字符串,否则设为nil,建议重用view
 * if you want to reuse the view, pass a string, otherwise set it to nil, it is recommended to reuse the view
 * @return 初始化成功则返回annotation view,否则返回nil
 * Returns the annotation view if initialization is successful, otherwise returns nil
 */
- (id)initWithAnnotation:(id <MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

/**
 * @brief 当从reuse队列里取出时被调用, 子类重新必须调用super
 * Called when taken out of the reuse queue, the subclass must call super
 */
- (void)prepareForReuse;

/**
 * @brief 设置view的拖动状态
 * set the drag state of the view
 * @param newDragState 新的拖动状态
 * the new drag state
 * @param animated     是否使用动画动画
 * whether to use animation
 */
- (void)setDragState:(MAAnnotationViewDragState)newDragState animated:(BOOL)animated;

@end
