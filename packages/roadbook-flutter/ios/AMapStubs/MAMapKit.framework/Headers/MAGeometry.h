//
//  MAGeometry.h
//  MAMapKit
//
//  Created by AutoNavi.
//  Copyright (c) 2013年 Amap. All rights reserved.
//

#import "MAConfig.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>


#ifdef __cplusplus
extern "C" {
#endif
    
    ///东北、西南两个点定义的四边形经纬度范围
    ///Latitude and longitude range of the quadrilateral defined by the northeast and southwest points
    typedef struct MACoordinateBounds{
        CLLocationCoordinate2D northEast; ///< 东北角经纬度   Latitude and longitude of the northeast corner
        CLLocationCoordinate2D southWest; ///< 西南角经纬度   Latitude and longitude of the southwest corner
    } MACoordinateBounds;
    
    ///经度、纬度定义的经纬度跨度范围
    ///Latitude and longitude span range defined by longitude and latitude
    typedef struct MACoordinateSpan{
        CLLocationDegrees latitudeDelta;  ///< 纬度跨度   Latitude span
        CLLocationDegrees longitudeDelta; ///< 经度跨度   Longitude span
    } MACoordinateSpan;
    
    ///中心点、跨度范围定义的四边形经纬度范围
    ///Quadrilateral latitude and longitude range defined by center point and span
    typedef struct MACoordinateRegion{
        CLLocationCoordinate2D center;  ///< 中心点经纬度   Center point latitude and longitude
        MACoordinateSpan span;          ///< 跨度范围   Span range
    } MACoordinateRegion;
    
    ///平面投影坐标结构定义
    ///Plane projection coordinate structure definition
    typedef struct MAMapPoint{
        double x; ///<x坐标   x coordinate
        double y; ///<y坐标   y coordinate
    } MAMapPoint;
    
    ///平面投影大小结构定义
    ///Plane projection size structure definition
    typedef struct MAMapSize{
        double width;   ///<宽度   Width
        double height;  ///<高度   Height
    } MAMapSize;
    
    ///平面投影矩形结构定义
    ///Planar projection rectangle structure definition
    typedef struct MAMapRect{
        MAMapPoint origin;  ///<左上角坐标   Top-left corner coordinates
        MAMapSize size;     ///<大小   Size
    } MAMapRect;
    
    typedef NS_OPTIONS(NSUInteger, MAMapRectCorner) {
        MAMapRectCornerTopLeft     = 1 << 0,
        MAMapRectCornerTopRight    = 1 << 1,
        MAMapRectCornerBottomLeft  = 1 << 2,
        MAMapRectCornerBottomRight = 1 << 3,
        MAMapRectCornerAllCorners  = ~0UL
    };
    
    ///比例关系:MAZoomScale = Screen Point / MAMapPoint, 当MAZoomScale = 1时, 1 screen point = 1 MAMapPoint, 当MAZoomScale = 0.5时, 1 screen point = 2 MAMapPoints
    ///Proportional relationship: MAZoomScale = Screen Point / MAMapPoint, when MAZoomScale = 1, 1 screen point = 1 MAMapPoint, when MAZoomScale = 0.5, 1 screen point = 2 MAMapPoints
    typedef double MAZoomScale;
    
    ///世界范围大小
    ///World extent size
    extern const MAMapSize MAMapSizeWorld;
    ///世界范围四边形
    ///World extent quadrilateral
    extern const MAMapRect MAMapRectWorld;
    ///(MAMapRect){{INFINITY, INFINITY}, {0, 0}};
    extern const MAMapRect MAMapRectNull;
    ///(MAMapRect){{0, 0}, {0, 0}}
    extern const MAMapRect MAMapRectZero;
    
    static inline MACoordinateBounds MACoordinateBoundsMake(CLLocationCoordinate2D northEast,CLLocationCoordinate2D southWest)
    {
        return (MACoordinateBounds){northEast, southWest};
    }
    
    static inline MACoordinateSpan MACoordinateSpanMake(CLLocationDegrees latitudeDelta, CLLocationDegrees longitudeDelta)
    {
        return (MACoordinateSpan){latitudeDelta, longitudeDelta};
    }
    
    static inline MACoordinateRegion MACoordinateRegionMake(CLLocationCoordinate2D centerCoordinate, MACoordinateSpan span)
    {
        return (MACoordinateRegion){centerCoordinate, span};
    }

    /**
     * @brief 生成一个新的MACoordinateRegion
     * Generate a new MACoordinateRegion
     * @param centerCoordinate   中心点坐标
     * center coordinate
     * @param latitudinalMeters  垂直跨度(单位 米)
     * vertical span (in meters)
     * @param longitudinalMeters 水平跨度(单位 米)
     * horizontal span (in meters)
     * @return 新的MACoordinateRegion
     * new MACoordinateRegion
     */
    extern MACoordinateRegion MACoordinateRegionMakeWithDistance(CLLocationCoordinate2D centerCoordinate, CLLocationDistance latitudinalMeters, CLLocationDistance longitudinalMeters);
    
    /**
     * @brief 经纬度坐标转平面投影坐标
     * Convert latitude and longitude coordinates to planar projection coordinates
     * @param coordinate 要转化的经纬度坐标
     * Latitude and longitude coordinates to be converted
     * @return 平面投影坐标
     * Planar projection coordinates
     */
    extern MAMapPoint MAMapPointForCoordinate(CLLocationCoordinate2D coordinate);
    
    /**
     * @brief 平面投影坐标转经纬度坐标
     * Convert planar projection coordinates to latitude and longitude coordinates
     * @param mapPoint 要转化的平面投影坐标
     * Planar projection coordinates to be converted
     * @return 经纬度坐标
     * Latitude and longitude coordinates
     */
    extern CLLocationCoordinate2D MACoordinateForMapPoint(MAMapPoint mapPoint);
    
    /**
     * @brief 平面投影矩形转region
     * Planar projection rectangle to region
     * @param rect 要转化的平面投影矩形
     * Planar projection rectangle to be converted
     * @return region
     */
    extern MACoordinateRegion MACoordinateRegionForMapRect(MAMapRect rect);
    
    /**
     * @brief region转平面投影矩形
     * Region to planar projection rectangle
     * @param region region 要转化的region
     * Region to be converted
     * @return 平面投影矩形
     * Planar projection rectangle
     */
    extern MAMapRect MAMapRectForCoordinateRegion(MACoordinateRegion region);
    
    /**
     * @brief 单位投影的距离
     * Unit projection distance
     * @param latitude 经纬度
     * Latitude and longitude
     * @return 距离
     * Distance
     */
    extern CLLocationDistance MAMetersPerMapPointAtLatitude(CLLocationDegrees latitude);
    
    /**
     * @brief 1米对应的投影
     * Projection corresponding to 1 meter
     * @param latitude 经纬度
     * Latitude and longitude
     * @return 1米对应的投影
     * Projection corresponding to 1 meter
     */
    extern double MAMapPointsPerMeterAtLatitude(CLLocationDegrees latitude);

    /**
     * @brief 投影两点之间的距离
     * Distance between two projection points
     * @param a a点
     * Point a
     * @param b b点
     * Point b
     * @return 距离
     * Distance
     */
    extern CLLocationDistance MAMetersBetweenMapPoints(MAMapPoint a, MAMapPoint b);
    
    /**
     * @brief 经纬度间的面积(单位 平方米)
     * Area between latitude and longitude (unit: square meters)
     * @param northEast 东北经纬度
     * Northeast latitude and longitude
     * @param southWest 西南经纬度
     * Southwest latitude and longitude
     * @return 面积
     * Area
     */
    extern double MAAreaBetweenCoordinates(CLLocationCoordinate2D northEast, CLLocationCoordinate2D southWest);
    
    /**
     * @brief 获取Inset后的MAMapRect
     * Get the MAMapRect after Inset
     * @param rect rect
     * @param dx   x点
     * Point x
     * @param dy   y点
     * Point y
     * @return MAMapRect
     */
    extern MAMapRect MAMapRectInset(MAMapRect rect, double dx, double dy);
    
    /**
     * @brief 合并两个MAMapRect
     * Merge two MAMapRects
     * @param rect1 rect1
     * @param rect2 rect2
     * @return 合并后的rect
     * Merged rect
     */
    extern MAMapRect MAMapRectUnion(MAMapRect rect1, MAMapRect rect2);
    
    /**
     * @brief 判断size1是否包含size2
     * Determine if size1 contains size2
     * @param size1 size1
     * @param size2 size2
     * @return 判断结果
     * Judgment result
     */
    extern BOOL MAMapSizeContainsSize(MAMapSize size1, MAMapSize size2);
    
    /**
     * @brief 判断点是否在矩形内
     * Determine if the point is inside the rectangle
     * @param rect  矩形rect
     * Rectangle rect
     * @param point 点
     * Point
     * @return 判断结果
     * Judgment result
     */
    extern BOOL MAMapRectContainsPoint(MAMapRect rect, MAMapPoint point);
    
    /**
     * @brief 判断两矩形是否相交
     * Determine if two rectangles intersect
     * @param rect1 rect1
     * @param rect2 rect2
     * @return 判断结果
     * Judgment result
     */
    extern BOOL MAMapRectIntersectsRect(MAMapRect rect1, MAMapRect rect2);
    
    /**
     * @brief 判断矩形rect1是否包含矩形rect2
     * Determine if rectangle rect1 contains rectangle rect2
     * @param rect1 rect1
     * @param rect2 rect2
     * @return 判断结果
     * Judgment result
     */
    extern BOOL MAMapRectContainsRect(MAMapRect rect1, MAMapRect rect2);
    
    /**
     * @brief 判断点是否在圆内
     * Determine if a point is inside a circle
     * @param point  点
     * Point
     * @param center 圆的中心点
     * Center point of the circle
     * @param radius 圆的半径，单位米
     * Radius of the circle, in meters
     * @return 判断结果
     * Judgment result
     */
    extern BOOL MACircleContainsPoint(MAMapPoint point, MAMapPoint center, double radius);
    
    /**
     * @brief 判断经纬度点是否在圆内
     * Determine if a latitude and longitude point is within a circle
     * @param point  经纬度
     * Latitude and longitude
     * @param center 圆的中心经纬度
     * Center latitude and longitude of the circle
     * @param radius 圆的半径，单位米
     * Radius of the circle, in meters
     * @return 判断结果
     * Judgment result
     */
    extern BOOL MACircleContainsCoordinate(CLLocationCoordinate2D point, CLLocationCoordinate2D center, double radius);
    
    /**
     * @brief 获取某坐标点距线上最近的坐标点
     * Get the nearest point on a line from a coordinate point
     * @param point     点
     * Point
     * @param polyline  线
     * Line
     * @param count     线里点的数量
     * Number of points in the line
     * @return 某点到线上最近的点
     * Nearest point on the line from a point
     */
    extern MAMapPoint MAGetNearestMapPointFromPolyline(MAMapPoint point, MAMapPoint *polyline, NSUInteger count);

    /**
     * @brief 判断点是否在多边形内
     * Determine if a point is inside a polygon
     * @param point   点
     * Point
     * @param polygon 多边形
     * Polygon
     * @param count   多边形点的数量
     * Number of polygon points
     * @return 判断结果
     * Judgment result
     */
    extern BOOL MAPolygonContainsPoint(MAMapPoint point, MAMapPoint *polygon, NSUInteger count);

    /**
     * @brief 判断经纬度点是否在多边形内
     * Determine if a latitude and longitude point is inside a polygon
     * @param point   经纬度点
     * Latitude and longitude point
     * @param polygon 多边形
     * Polygon
     * @param count   多边形点的数量
     * Number of polygon points
     * @return 判断结果
     * Judgment result
     */
    extern BOOL MAPolygonContainsCoordinate(CLLocationCoordinate2D point, CLLocationCoordinate2D *polygon, NSUInteger count);
    
    /**
     * @brief 取在lineStart和lineEnd组成的线段上距离point距离最近的点
     * Take the point on the line segment formed by lineStart and lineEnd that is closest to point
     * @param lineStart 线段起点
     * Line segment starting point
     * @param lineEnd   线段终点
     * Line segment ending point
     * @param point     测试点
     * Test point
     * @return 距离point最近的点坐标
     * Coordinates of the point closest to point
     */
    extern MAMapPoint MAGetNearestMapPointFromLine(MAMapPoint lineStart, MAMapPoint lineEnd, MAMapPoint point);
    
    /**
     * @brief 获取墨卡托投影切块回调block，如果是无效的映射，则返回(-1, -1, 0, 0, 0, 0)
     * Get the Mercator projection tile callback block, if it is an invalid mapping, return (-1, -1, 0, 0, 0, 0);
     * @param offsetX 左上点距离所属tile的位移X, 单位像素
     * The displacement X of the top-left point from the tile it belongs to, in pixels
     * @param offsetY 左上点距离所属tile的位移Y, 单位像素
     * The displacement Y of the top-left point from the tile it belongs to, in pixels
     * @param minX    覆盖tile的最小x
     * Minimum x of the covered tile
     * @param maxX    覆盖tile的最大x
     * Maximum x of the covered tile
     * @param minY    覆盖tile的最小y
     * Minimum y of the covered tile
     * @param maxY    覆盖tile的最大y
     * Maximum y of the covered tile
     */
    typedef void (^AMapTileProjectionBlock)(int offsetX, int offsetY, int minX, int maxX, int minY, int maxY);
    
    /**
     * @brief 根据所给经纬度区域获取墨卡托投影切块信息
     * Obtain Mercator projection tile information based on the given latitude and longitude area
     * @param bounds         经纬度区域
     * Latitude and longitude area
     * @param levelOfDetails 对应缩放级别, 取值0-20
     * Corresponding zoom level, value range 0-20
     * @param tileProjection 返回的切块信息block
     * Returned tile information block
     */
    extern void MAGetTileProjectionFromBounds(MACoordinateBounds bounds, int levelOfDetails, AMapTileProjectionBlock tileProjection);
    
    /**
     * @brief 计算多边形面积，点与点之间按顺序尾部相连, 第一个点与最后一个点相连
     * Calculate the area of a polygon, where points are connected sequentially from tail to head, and the first point is connected to the last point
     * @param coordinates 指定的经纬度坐标点数组，C数组，调用者负责内存管理
     * The specified array of latitude and longitude coordinate points, a C array, memory management is the responsibility of the caller
     * @param count 坐标点的个数
     * The number of coordinate points
     * @return 多边形的面积
     * The area of the polygon
     */
    extern double MAAreaForPolygon(CLLocationCoordinate2D *coordinates, int count);
    
    static inline MAMapPoint MAMapPointMake(double x, double y)
    {
        return (MAMapPoint){x, y};
    }
    
    static inline MAMapSize MAMapSizeMake(double width, double height)
    {
        return (MAMapSize){width, height};
    }
    
    static inline MAMapRect MAMapRectMake(double x, double y, double width, double height)
    {
        return (MAMapRect){MAMapPointMake(x, y), MAMapSizeMake(width, height)};
    }
    
    static inline double MAMapRectGetMinX(MAMapRect rect)
    {
        return rect.origin.x;
    }
    
    static inline double MAMapRectGetMinY(MAMapRect rect)
    {
        return rect.origin.y;
    }
    
    static inline double MAMapRectGetMidX(MAMapRect rect)
    {
        return rect.origin.x + rect.size.width / 2.0;
    }
    
    static inline double MAMapRectGetMidY(MAMapRect rect)
    {
        return rect.origin.y + rect.size.height / 2.0;
    }
    
    static inline double MAMapRectGetMaxX(MAMapRect rect)
    {
        return rect.origin.x + rect.size.width;
    }
    
    static inline double MAMapRectGetMaxY(MAMapRect rect)
    {
        return rect.origin.y + rect.size.height;
    }
    
    static inline double MAMapRectGetWidth(MAMapRect rect)
    {
        return rect.size.width;
    }
    
    static inline double MAMapRectGetHeight(MAMapRect rect)
    {
        return rect.size.height;
    }
    
    static inline BOOL MAMapPointEqualToPoint(MAMapPoint point1, MAMapPoint point2) {
        return point1.x == point2.x && point1.y == point2.y;
    }
    
    static inline BOOL MAMapSizeEqualToSize(MAMapSize size1, MAMapSize size2) {
        return size1.width == size2.width && size1.height == size2.height;
    }
    
    static inline BOOL MAMapRectEqualToRect(MAMapRect rect1, MAMapRect rect2) {
        return
        MAMapPointEqualToPoint(rect1.origin, rect2.origin) &&
        MAMapSizeEqualToSize(rect1.size, rect2.size);
    }
    
    static inline BOOL MAMapRectIsNull(MAMapRect rect) {
        return isinf(rect.origin.x) || isinf(rect.origin.y);
    }
    
    static inline BOOL MAMapRectIsEmpty(MAMapRect rect) {
        return MAMapRectIsNull(rect) || (rect.size.width == 0.0 && rect.size.height == 0.0);
    }
    
    static inline NSString *MAStringFromMapPoint(MAMapPoint point) {
        return [NSString stringWithFormat:@"{%.1f, %.1f}", point.x, point.y];
    }
    
    static inline NSString *MAStringFromMapSize(MAMapSize size) {
        return [NSString stringWithFormat:@"{%.1f, %.1f}", size.width, size.height];
    }
    
    static inline NSString *MAStringFromMapRect(MAMapRect rect) {
        return [NSString stringWithFormat:@"{%@, %@}", MAStringFromMapPoint(rect.origin), MAStringFromMapSize(rect.size)];
    }
    
    ///坐标系类型枚举
    ///Coordinate system type enumeration
    typedef NS_ENUM(NSUInteger, MACoordinateType)
    {
        MACoordinateTypeBaidu = 0,  ///< Baidu
        MACoordinateTypeMapBar,     ///< MapBar
        MACoordinateTypeMapABC,     ///< MapABC
        MACoordinateTypeSoSoMap,    ///< SoSoMap
        MACoordinateTypeAliYun,     ///< AliYun
        MACoordinateTypeGoogle,     ///< Google
        MACoordinateTypeGPS,        ///< GPS
    };
    
    /**
     * @brief 转换目标经纬度为高德坐标系
     * Convert target coordinates to AutoNavi coordinate system
     * @param coordinate 待转换的经纬度
     * Coordinates to be converted
     * @param type       坐标系类型
     * Coordinate system type
     * @return 高德坐标系经纬度
     * AutoNavi coordinate system coordinates
     */
    extern CLLocationCoordinate2D MACoordinateConvert(CLLocationCoordinate2D coordinate, MACoordinateType type) __attribute((deprecated("Deprecated, use the coordinate conversion interface in AMapFoundation")));
    
    /**
     * @brief 获取矢量坐标方向
     * Get vector coordinate direction
     * @param fromCoord 矢量坐标起点
     * Vector coordinate start point
     * @param toCoord   矢量坐标终点
     * Vector coordinate end point
     * @return 方向，详情参考系统 CLLocationDirection
     * Direction, refer to system CLLocationDirection for details
     */
    extern CLLocationDirection MAGetDirectionFromCoords(CLLocationCoordinate2D fromCoord, CLLocationCoordinate2D toCoord);
    
    /**
     * @brief 获取矢量坐标方向
     * Get vector coordinate direction
     * @param fromPoint 矢量坐标起点
     * Vector coordinate start point
     * @param toPoint   矢量坐标终点
     * Vector coordinate end point
     * @return 方向，详情参考系统 CLLocationDirection
     * Direction, refer to system CLLocationDirection for details
     */
    extern CLLocationDirection MAGetDirectionFromPoints(MAMapPoint fromPoint, MAMapPoint toPoint);
    
    /**
     * @brief 获取点到线的垂直距离
     * Get perpendicular distance from point to line
     * @param point 起点
     * Start point
     * @param lineBegin 线的起点
     * Start point of the line
     * @param lineEnd   线的终点
     * End point of the line
     * @return 距离，单位米
     * Distance in meters
     */
    extern double MAGetDistanceFromPointToLine(MAMapPoint point, MAMapPoint lineBegin, MAMapPoint lineEnd);

    /**
     * @brief 判断线是否被点击选中
     * Determine if the line is clicked and selected
     * @param linePoints 构成线的点
     * Points that form the line
     * @param count 点的个数
     * Number of points
     * @param tappedPoint   点击点
     * Click point
     * @param lineWidth   线宽，单位：MAMapPoint点
     * Line width, unit: MAMapPoint
     * @return 是否选中
     * Whether selected
     */
    extern BOOL MAPolylineHitTest(MAMapPoint *linePoints, NSUInteger count, MAMapPoint tappedPoint, CGFloat lineWidth);
    
#ifdef __cplusplus
}
#endif

///utils方法，方便c结构体对象和NSValue对象间相互转化
///utils method for convenient conversion between C struct objects and NSValue objects
@interface NSValue (NSValueMAGeometryExtensions)

/**
 * @brief 创建 MAMapPoint 的NSValue对象
 * Create NSValue object for MAMapPoint
 * @param mapPoint MAMapPoint结构体对象
 * MAMapPoint struct object
 * @return NSValue对象
 * NSValue object
 */
+ (NSValue *)valueWithMAMapPoint:(MAMapPoint)mapPoint;

/**
 * @brief 创建 MAMapSize 的NSValue对象
 * Create NSValue object for MAMapSize
 * @param mapSize MAMapSize结构体对象
 * MAMapSize struct object
 * @return NSValue对象
 * NSValue object
 */
+ (NSValue *)valueWithMAMapSize:(MAMapSize)mapSize;

/**
 * @brief 创建 MAMapRect 的NSValue对象
 * Create NSValue object for MAMapRect
 * @param mapRect MAMapRect结构体对象
 * MAMapRect struct object
 * @return NSValue对象
 * NSValue object
 */
+ (NSValue *)valueWithMAMapRect:(MAMapRect)mapRect;

/**
 * @brief 创建 CLLocationCoordinate2D 的NSValue对象
 * Create NSValue object for CLLocationCoordinate2D
 * @param coordinate CLLocationCoordinate2D结构体对象
 * CLLocationCoordinate2D struct object
 * @return NSValue对象
 * NSValue object
 */
+ (NSValue *)valueWithMACoordinate:(CLLocationCoordinate2D)coordinate;

/**
 @brief 返回NSValue对象包含的MAMapPoint结构体对象
 Returns the MAMapPoint structure contained in the NSValue object
 @return 当前对象包含的MAMapPoint结构体对象
 The MAMapPoint structure contained in the current object
 */
- (MAMapPoint)MAMapPointValue;

/**
 @brief 返回NSValue对象包含的MAMapSize结构体对象
 Returns the MAMapSize structure contained in the NSValue object
 @return 当前对象包含的MAMapSize结构体对象
 The MAMapSize structure contained in the current object
 */
- (MAMapSize)MAMapSizeValue;

/**
 @brief 返回NSValue对象包含的MAMapRect结构体对象
 Returns the MAMapRect structure contained in the NSValue object
 @return 当前对象包含的MAMapRect结构体对象
 The MAMapRect structure contained in the current object
 */
- (MAMapRect)MAMapRectValue;

/**
 @brief 返回NSValue对象包含的CLLocationCoordinate2D结构体对象
 Returns the CLLocationCoordinate2D structure contained in the NSValue object
 @return 当前对象包含的CLLocationCoordinate2D结构体对象
 The CLLocationCoordinate2D structure contained in the current object
 */
- (CLLocationCoordinate2D)MACoordinateValue;

@end
