//
//  Tracking.m
//  Tracking
//
//  Created by xiaojian on 14-7-30.
//  Copyright (c) 2014年 Tab. All rights reserved.
//

#import "Tracking.h"

@interface Tracking ()<CAAnimationDelegate>
{
    CLLocationCoordinate2D *_coordinates;
    CLLocationCoordinate2D * _animations;
    NSUInteger              _count;
}

/**
 轨迹路径动画.
 */
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

/**
 渐变轨迹layer
 */
@property (nonatomic, strong) CALayer * gradientLayer ;

/**
 整条路径的颜色值
 */
@property (nonatomic, strong) NSArray * gradientColors ;

/**
 大头针 - 移动的大头针
 */
@property (nonatomic, strong, readwrite) MAPointAnnotation *annotation;

/**
 大头针 - 移动的大头针视图
 */
@property (nonatomic, weak) MAAnnotationView *annotationView ;

/**
 轨迹视图.怎么将其替换成一个渐变的效果
 */
@property (nonatomic, strong, readwrite) MAPolyline *polyline;

//当开始进行轨迹回放时.开始定时.并且返回对应的点.
@property (nonatomic, strong) CADisplayLink * displayLink ;

//当前走动的时长.
@property (nonatomic, assign) NSInteger timeCount;

@end

@implementation Tracking
@synthesize mapView     = _mapView;
@synthesize shapeLayer  = _shapeLayer;

@synthesize annotation  = _annotation;
@synthesize polyline    = _polyline;

#pragma mark - CoreAnimation Delegate

- (void)animationDidStart:(CAAnimation *)anim
{
    [self makeMapViewEnable:NO];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(willBeginTracking:)])
    {
        [self.delegate willBeginTracking:self];
    }
}

-(void)updateDisplay{
 
    self.timeCount ++;
    if (self.timeCount == 60) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(animationTracking:andCoordinates:)])
        {
            [self.delegate animationTracking:self andCoordinates:_coordinates[1]];
        }
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        [self.mapView addOverlay:self.polyline];
        [self.gradientLayer removeFromSuperlayer];
        [self.shapeLayer removeFromSuperlayer];
        self.displayLink.paused = YES;
        [self.displayLink invalidate];
        self.displayLink = nil;
        [self.annotationView removeFromSuperview];
    }
    
    [self makeMapViewEnable:YES];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didEndTracking:)])
    {
        [self.delegate didEndTracking:self];
    }
}

#pragma mark - Utility

/* Enable/Disable mapView. */
- (void)makeMapViewEnable:(BOOL)enabled
{
    self.mapView.scrollEnabled          = enabled;
    self.mapView.zoomEnabled            = enabled;
    self.mapView.rotateEnabled          = enabled;
    self.mapView.rotateCameraEnabled    = enabled;
}

/* 经纬度转屏幕坐标, 调用着负责释放内存. */
- (CGPoint *)pointsForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count
{
    if (coordinates == NULL || count <= 1)
    {
        return NULL;
    }
    
    /* 申请屏幕坐标存储空间. */
    CGPoint *points = (CGPoint *)malloc(count * sizeof(CGPoint));
    
    /* 经纬度转换为屏幕坐标. */
    for (int i = 0; i < count; i++)
    {
        points[i] = [self.mapView convertCoordinate:coordinates[i] toPointToView:self.mapView];
    }
    
    return points;
}

/* 构建path, 调用着负责释放内存. */
- (CGMutablePathRef)pathForPoints:(CGPoint *)points count:(NSUInteger)count
{
    if (points == NULL || count <= 1)
    {
        return NULL;
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddLines(path, NULL, points, count);
    
    return path;
}

        #pragma mark - 构造gradientLayer
        - (void)initGradientLayerWithPoints:(CGPoint *)points Count:(NSUInteger)count{
            if(count<1){
                return;
            }
            self.gradientLayer = [[CALayer alloc] init];
            for(int i=0;i<count-1;i++){
                @autoreleasepool {
                    CGPoint point1 = points[i];
                    CGPoint point2 = points[i+1];
                    
                    double xDiff = point2.x-point1.x; //正向差距多少
                    double yDiff = point2.y-point1.y; //y轴正向差距多少.
                    CGPoint startPoint,endPoint;
                    double offset = 0.;
                    
                    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
                    //相邻两个最标点 构造一个渐变图层
                    [gradientLayer setFrame:CGRectMake(MIN(point1.x, point2.x)-3, MIN(point1.y, point2.y)-3, fabs(xDiff)+6, fabs(yDiff)+6)];
                    
                    //渐变方向
                    if (xDiff > 0 && yDiff > 0) {
                        if (xDiff >= yDiff) {
                            startPoint = CGPointMake(0, 0);
                            endPoint =  CGPointMake(1, yDiff / xDiff);
                        }else{
                            offset = xDiff/yDiff;
                            startPoint = CGPointMake(0, 0);
                            endPoint =  CGPointMake(xDiff / yDiff, 1);
                        }
                    }else if (xDiff > 0 && yDiff == 0){
                        startPoint = CGPointMake(0, 0);
                        endPoint = CGPointMake(1, 0);
                    }else if (xDiff < 0 && yDiff == 0){
                        startPoint = CGPointMake(1, 0);
                        endPoint = CGPointMake(0, 0);
                    }else if (xDiff == 0 && yDiff > 0){
                        startPoint = CGPointMake(0, 0);
                        endPoint = CGPointMake(0, 1);
                    }else if (xDiff == 0 && yDiff < 0){
                        startPoint = CGPointMake(0, 1);
                        endPoint = CGPointMake(0, 0);
                    }else if (xDiff > 0 && yDiff < 0){
                        if (fabs(xDiff) >= fabs(yDiff)) {
                            startPoint = CGPointMake(0, fabs(yDiff / xDiff));
                            endPoint =  CGPointMake(1, 0);
                        }else{
                            startPoint = CGPointMake(0, 1);
                            endPoint = CGPointMake(fabs(xDiff/yDiff), 0);
                        }
                    }else if (xDiff < 0 && yDiff < 0){
                        if (fabs(xDiff) >= fabs(yDiff)){
                            startPoint = CGPointMake(1, 1);
                            endPoint = CGPointMake(0, 1 - fabs(yDiff) / fabs(xDiff));
                        }else{
                            startPoint = CGPointMake(fabs(xDiff)/fabs(yDiff), 1);
                            endPoint = CGPointMake(0, 0);
                        }
                    }else{
                        if(fabs(xDiff) >= fabs(yDiff)){
                            startPoint = CGPointMake(1, 0);
                            endPoint = CGPointMake(0, fabs(yDiff) / fabs(xDiff));
                        }else{
                            startPoint = CGPointMake(fabs(xDiff)/fabs(yDiff), 0);
                            endPoint = CGPointMake(0, 1);
                        }
                    }
                    gradientLayer.cornerRadius = 6;
                    gradientLayer.startPoint = startPoint;
                    gradientLayer.endPoint = endPoint;
                    
                    gradientLayer.colors = @[[self.gradientColors objectAtIndex:i],
                                             [self.gradientColors objectAtIndex:i+1]];
                    //调试

                    [self.gradientLayer insertSublayer:gradientLayer atIndex:0];
                }
            }
            [self.gradientLayer setMask:self.shapeLayer];
            [self.mapView.layer insertSublayer:self.gradientLayer atIndex:1];
        }

//获取颜色值
//- (void) velocity:(float*)velocity ToHue:(float**)_hue count:(int)count{
//    *_hue = malloc(sizeof(float)*count);
//    for (int i=0;i<count;i++){
//        float curVelo = velocity[i];
//        if(curVelo>0.){
//            curVelo = ((curVelo < V_MIN) ? V_MIN : (curVelo  > V_MAX) ? V_MAX : curVelo);
//            (*_hue)[i] = H_MIN + ((curVelo-V_MIN)*(H_MAX-H_MIN))/(V_MAX-V_MIN);
//        }else if(curVelo==kPauseSpeed){
//            //暂停颜色
//            (*_hue)[i] = kPauseSpeed;
//        }else{
//            //超速颜色
//            (*_hue)[i] = 0.;
//        }
//
//        //填充轨迹渐变数组
//        UIColor *color;
//        if(curVelo>0.){
//            color = [UIColor colorWithHue:(*_hue)[i] saturation:1.0f brightness:1.0f alpha:1.0f];
//        }else{
//            color = [UIColor colorWithHue:(*_hue)[i] saturation:1.0f brightness:1.0f alpha:0.0f];
//        }
//        [[StaticVariable sharedInstance].gradientColors addObject:(__bridge id)color.CGColor];
//    }
//}

#pragma mark - Interface

        - (void)execute
        {
            [self clear];
            
            [self.mapView addOverlay:self.polyline];
            
            /* 使轨迹在地图可视范围内. */
            [self.mapView setVisibleMapRect:self.polyline.boundingMapRect edgePadding:self.edgeInsets animated:NO];
            
            self.displayLink = [CADisplayLink displayLinkWithTarget:self

                                                           selector:@selector(updateDisplay)];

            [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop]

                                   forMode:NSDefaultRunLoopMode];
            self.timeCount = 0;
            
            
            /* 构建path. */
            CGPoint *points = [self pointsForCoordinates:_coordinates count:_count];
            CGPathRef path = [self pathForPoints:points count:_count];
            self.shapeLayer.path = path;
            [self.mapView.layer insertSublayer:self.shapeLayer atIndex:1];

            self.gradientColors = @[(id)UIColor.redColor.CGColor,(id)UIColor.orangeColor.CGColor,(id)UIColor.blueColor.CGColor,(id)UIColor.greenColor.CGColor];
            [self initGradientLayerWithPoints:points Count:_count];

            [self.mapView addAnnotation:self.annotation];

            MAAnnotationView *annotationView = [self.mapView viewForAnnotation:self.annotation];
            annotationView.image = [UIImage imageNamed:@"icon24／sport_details_route_head"];
            self.annotationView = annotationView;

            if (annotationView != nil)
            {
                /* Annotation animation. */
                CAAnimation *annotationAnimation = [self constructAnnotationAnimationWithPath:path];
                [annotationView.layer addAnimation:annotationAnimation forKey:@"annotation"];

                [annotationView.annotation setCoordinate:_coordinates[_count - 1]];

                /* ShapeLayer animation. */
                CAAnimation *shapeLayerAnimation = [self constructShapeLayerAnimation];
                shapeLayerAnimation.delegate = self;
                [self.shapeLayer addAnimation:shapeLayerAnimation forKey:@"shape"];
            }

            (void)(free(points)),           points  = NULL;
            (void)(CGPathRelease(path)),    path    = NULL;
        }

/* 构建annotationView的keyFrameAnimation. */
- (CAAnimation *)constructAnnotationAnimationWithPath:(CGPathRef)path
{
    if (path == NULL)
    {
        return nil;
    }
    
    CAKeyframeAnimation *thekeyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    thekeyFrameAnimation.duration        = self.duration;
    thekeyFrameAnimation.path            = path;
    thekeyFrameAnimation.calculationMode = kCAAnimationPaced;
    
    return thekeyFrameAnimation;
}

/* 构建shapeLayer的basicAnimation. */
- (CAAnimation *)constructShapeLayerAnimation
{
    CABasicAnimation *theStrokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    theStrokeAnimation.duration         = self.duration;
    theStrokeAnimation.fromValue        = @0.f;
    theStrokeAnimation.toValue          = @1.f;
    
    return theStrokeAnimation;
}


- (void)clear
{
    /* 删除渐变图层 */
    [self.gradientLayer removeFromSuperlayer];
    
    self.gradientLayer = nil;
    
    /* 删除annotation. */
    [self.mapView removeAnnotation:self.annotation];
    
    /* 删除polyline. */
    [self.mapView removeOverlay:self.polyline];
    
    /* 删除shapeLayer. */
    [self.shapeLayer removeFromSuperlayer];
    
    self.displayLink.paused = YES;
    [self.displayLink invalidate];
    self.displayLink = nil;
    
    [self.annotationView removeFromSuperview];
    
}

#pragma mark - Initialization

/* 构建shapeLayer. */
- (void)initShapeLayer
{
    self.shapeLayer = [[CAShapeLayer alloc] init];
    self.shapeLayer.lineWidth         = 4;
    self.shapeLayer.strokeColor       = [UIColor redColor].CGColor;
    self.shapeLayer.fillColor         = [UIColor clearColor].CGColor;
    self.shapeLayer.lineJoin          = kCALineCapRound;
}

/* 构建annotation. */
- (void)initAnnotation
{
    self.annotation = [[MAPointAnnotation alloc] init];
    
    self.annotation.coordinate = _coordinates[0];

}

/* 构建annotation. */
- (void)initPolyline
{
    self.polyline = [MAPolyline polylineWithCoordinates:_coordinates count:_count];
}

- (void)initBaseData
{
    [self initAnnotation];
    
    [self initPolyline];
    
    [self initShapeLayer];
}

#pragma mark - Life Cycle

/*!
 @brief Tracking的初始化方法
 @param coordinates 轨迹经纬度数组
 @param animations 轨迹上待动画的经纬度数组
 @param count 经纬度个数
 @return Tracking
 */
- (instancetype)initWithCoordinates:(CLLocationCoordinate2D *)coordinates animations:(CLLocationCoordinate2D *)animations  count:(NSUInteger)count
{
    if (self = [self initWithCoordinates:coordinates count:count]) {
        _animations = animations;
    }
    return self;
}

- (instancetype)initWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count
{
    if (self = [super init])
    {
        if (coordinates == NULL || count <= 1)
        {
            return nil;
        }
        
        self.duration = 2.f;
        
        self.edgeInsets = UIEdgeInsetsMake(30, 30, 30, 30);
        
        _count = count;
        
        _coordinates = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
        
        if (_coordinates == NULL)
        {
            return nil;
        }
        
        /* 内存拷贝. */
        memcpy(_coordinates, coordinates, count * sizeof(CLLocationCoordinate2D));
        
        [self initBaseData];
    }
    
    return self;
}

- (void)dealloc
{
    [self clear];
    
    if (_coordinates != NULL)
    {
        (void)(free(_coordinates)), _coordinates = NULL;
    }
}


@end
