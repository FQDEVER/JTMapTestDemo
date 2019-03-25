//
//  ViewController.m
//  JTMapTestDemo
//
//  Created by 范奇 on 2019/3/18.
//  Copyright © 2019 范奇. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "CustomAnnotationView.h"
#import "CustomPointAnnotation.h"
#import "CustomPolyline.h"
#import "MainViewController.h"
#import "Tracking.h"

@interface ViewController ()<MAMapViewDelegate,TrackingDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *controlView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *animationControlView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dotControlView;
@property (weak, nonatomic) IBOutlet UIButton *runBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;

@property (nonatomic, strong) MAMapView *mapView ;

@property (nonatomic, strong) Tracking *tracking;

@property (nonatomic, strong) MAAnimatedAnnotation * animationAnnotation ;

@property (nonatomic, strong) MAAnnotationView * annotationView ;

@property (nonatomic, strong) MACircle * transparentCircle ;

@property (nonatomic, strong) NSMutableArray * dotAnnotationArr ;

//当开始进行轨迹回放时.开始定时.并且返回对应的点.
@property (nonatomic, strong) CADisplayLink * displayLink ;

//当前走动的时长.
@property (nonatomic, assign) NSInteger timeCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ///初始化地图
    MAMapView *mapView = [[MAMapView alloc]
                           initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [mapView addSubview:self.controlView];
    [mapView addSubview:self.animationControlView];
    [mapView addSubview:self.dotControlView];
    [mapView addSubview:self.runBtn];
    [mapView addSubview:self.stopBtn];
    self.controlView.frame = CGRectMake(16, 20, self.view.bounds.size.width - 16 * 2.0, 20);
    self.animationControlView.frame = CGRectMake(16, 40, self.view.bounds.size.width - 16 * 2.0, 20);
    self.dotControlView.frame = CGRectMake(16, 60, self.view.bounds.size.width - 16 * 2.0, 20);
    self.runBtn.frame = CGRectMake(16, 80, 100, 20);
    self.stopBtn.frame = CGRectMake(16 + 120, 80, 100, 20);
    self.mapView = mapView;
    mapView.delegate = self;
    [mapView setCompassImage:[UIImage imageNamed:@"ios_trace_home_my_compass"]];
    mapView.compassOrigin = CGPointMake(10, self.view.bounds.size.height - 40);
    ///把地图添加至view
    [self.view addSubview:mapView];
    
    
    
//    mapView.showsUserLocation = YES;
    mapView.userTrackingMode = MAUserTrackingModeFollow;
    
//    MAUserLocationRepresentation * r = [[MAUserLocationRepresentation alloc]init];
//    r.showsAccuracyRing = YES; //精度圈是否显示，默认YES
//    r.showsHeadingIndicator = YES;//是否显示方向指示(MAUserTrackingModeFollowWithHeading模式开启)。默认为YES
//    r.fillColor = [UIColor redColor];//精度圈 填充颜色, 默认 kAccuracyCircleDefaultColor
//    r.strokeColor = [UIColor blueColor];//精度圈 边线颜色, 默认 kAccuracyCircleDefaultColor
//    r.lineWidth = 100;///精度圈 边线宽度，默认0
//    r.enablePulseAnnimation = YES;///内部蓝色圆点是否使用律动效果, 默认YES
//    r.locationDotBgColor = [UIColor greenColor];///定位点背景色，不设置默认白色
//    r.locationDotFillColor = [UIColor grayColor];///定位点蓝色圆点颜色，不设置默认蓝色
//    r.image = [UIImage imageNamed:@"ios_sports_map_run_icon_annotation"]; ///定位图标, 与蓝色原点互斥
//    [mapView updateUserLocationRepresentation:r];
    [mapView setMapType:MAMapTypeStandard];
    
    [mapView bringSubviewToFront:self.controlView];
    
//    //添加大头针标注
//    CustomPointAnnotation * pointAnnotation = [[CustomPointAnnotation alloc]init];
//    pointAnnotation.coordinate = CLLocationCoordinate2DMake(22.548327, 114.031404);
//    pointAnnotation.title = @"开始点";
//    pointAnnotation.subtitle = @"深圳长跑马拉松起始点";
//    pointAnnotation.annotationType = CustomSportPointAnnotationType_Start;
//
//    //添加大头针标注
//    CustomPointAnnotation * pointAnnotation1 = [[CustomPointAnnotation alloc]init];
//    pointAnnotation1.coordinate= CLLocationCoordinate2DMake(22.558337, 114.231404);
//    pointAnnotation1.title = @"1公里打点";
//    pointAnnotation1.subtitle = @"该处为跑步1公里gps点";
//    pointAnnotation1.annotationType = CustomSportPointAnnotationType_Distance;
//    pointAnnotation1.distanceIndex = 1000;
//    [self.dotAnnotationArr addObject:pointAnnotation1];
//
//    //添加大头针标注
//    CustomPointAnnotation * pointAnnotation2 = [[CustomPointAnnotation alloc]init];
//    pointAnnotation2.coordinate= CLLocationCoordinate2DMake(22.949327, 114.131404);
//    pointAnnotation2.title = @"铁人三项跑步";
//    pointAnnotation2.subtitle = @"该段为铁人三项跑步段";
//    pointAnnotation2.annotationType = CustomSportPointAnnotationType_Sport;
//
//    //添加大头针标注
//    CustomPointAnnotation * pointAnnotation3 = [[CustomPointAnnotation alloc]init];
//    pointAnnotation3.coordinate = CLLocationCoordinate2DMake(22.548327, 114.331404);
//    pointAnnotation3.title = @"结束点";
//    pointAnnotation3.subtitle = @"该处为长跑马拉松结束点";
//    pointAnnotation3.annotationType = CustomSportPointAnnotationType_End;
    
//    MAAnimatedAnnotation * animationAnnotation = [[MAAnimatedAnnotation alloc]init];
//    animationAnnotation.coordinate = CLLocationCoordinate2DMake(22.548327, 114.031404);
//    self.animationAnnotation = animationAnnotation;
//    animationAnnotation.title = @"移动点";
//    animationAnnotation.subtitle = @"干啥";
    
//    [self.mapView addAnnotations:@[animationAnnotation,pointAnnotation,pointAnnotation1,pointAnnotation2,pointAnnotation3]];
//    [self.mapView setSelectedAnnotations:@[animationAnnotation]];
    
    //创建经纬度
//    CLLocationCoordinate2D polyLineCoords[4];
//    polyLineCoords[0].latitude = 22.548327;
//    polyLineCoords[0].longitude = 114.031404;
//
//    polyLineCoords[1].latitude = 22.558337;
//    polyLineCoords[1].longitude = 114.231404;
//
//    polyLineCoords[2].latitude = 22.949327;
//    polyLineCoords[2].longitude = 114.131404;
//
//    polyLineCoords[3].latitude = 22.548327;
//    polyLineCoords[3].longitude = 114.331404;

    
//    __weak typeof(self)weakSelf =self;
//    [animationAnnotation addMoveAnimationWithKeyCoordinates:polyLineCoords count:4 withDuration:5.0f withName:nil completeCallback:^(BOOL isFinished) {
//        if (isFinished) {
//            NSLog(@"-----------------完成");
//            [weakSelf.mapView removeAnnotation:weakSelf.animationAnnotation];
////            [weakSelf renderMapTrajectoryView];
//        }else{
//            for (MAAnnotationMoveAnimation * animation in weakSelf.animationAnnotation.allMoveAnimations) {
//                [animation cancel];
//            }
//        }
//
//    } stepCallback:^(MAAnnotationMoveAnimation *currentAni) {
//
//    }];
    [self addTransparentOverlay];
    
}

- (IBAction)clickRunBtn:(UIButton *)sender {
    if (self.tracking == nil)
    {
        [self setupTracking];
    }
    //清空所有的
    [self.mapView removeAnnotations:self.dotAnnotationArr];
    [self.tracking execute];
}
- (IBAction)clickStopBtn:(UIButton *)sender {
    
    if (self.tracking) {
        [self.tracking clear];
    }
    [self renderMapTrajectoryView];
}

/* 构建轨迹回放. */
- (void)setupTracking
{
//    NSString *trackingFilePath = [[NSBundle mainBundle] pathForResource:@"GuGong" ofType:@"tracking"];
//
//    NSData *trackingData = [NSData dataWithContentsOfFile:trackingFilePath];
//
//    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)malloc(trackingData.length);
//
//    /* 提取轨迹原始数据. */
//    [trackingData getBytes:coordinates length:trackingData.length];
//
////     构建tracking.
//    self.tracking = [[Tracking alloc] initWithCoordinates:coordinates count:trackingData.length / sizeof(CLLocationCoordinate2D)];
//    创建经纬度
    CLLocationCoordinate2D polyLineCoords[4];
    polyLineCoords[0].latitude = 22.548327;
    polyLineCoords[0].longitude = 114.031404;

    polyLineCoords[1].latitude = 22.558337;
    polyLineCoords[1].longitude = 114.231404;

    polyLineCoords[2].latitude = 22.949327;
    polyLineCoords[2].longitude = 114.131404;

    polyLineCoords[3].latitude = 22.548327;
    polyLineCoords[3].longitude = 114.331404;

    self.tracking = [[Tracking alloc] initWithCoordinates:polyLineCoords count:4];
    self.tracking.delegate = self;
    self.tracking.mapView  = self.mapView;
    self.tracking.duration = 5.f;
    self.tracking.edgeInsets = UIEdgeInsetsMake(50, 50, 50, 50);
    
    
}

#pragma mark - TrackingDelegate

- (void)willBeginTracking:(Tracking *)tracking
{
    NSLog(@"%s", __func__);
    
    //添加大头针标注
    CustomPointAnnotation * pointAnnotation = [[CustomPointAnnotation alloc]init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(22.548327, 114.031404);
    pointAnnotation.title = @"开始点";
    pointAnnotation.subtitle = @"深圳长跑马拉松起始点";
    pointAnnotation.annotationType = CustomSportPointAnnotationType_Start;
    
    [self.mapView addAnnotation:pointAnnotation];
    [self.dotAnnotationArr addObject:pointAnnotation];
    
//    //添加大头针标注
//    CustomPointAnnotation * pointAnnotation1 = [[CustomPointAnnotation alloc]init];
//    pointAnnotation1.coordinate= CLLocationCoordinate2DMake(22.558337, 114.231404);
//    pointAnnotation1.title = @"1公里打点";
//    pointAnnotation1.subtitle = @"该处为跑步1公里gps点";
//    pointAnnotation1.annotationType = CustomSportPointAnnotationType_Distance;
//    pointAnnotation1.distanceIndex = 1000;
//    [self.dotAnnotationArr addObject:pointAnnotation1];
//
//    //添加大头针标注
//    CustomPointAnnotation * pointAnnotation2 = [[CustomPointAnnotation alloc]init];
//    pointAnnotation2.coordinate= CLLocationCoordinate2DMake(22.949327, 114.131404);
//    pointAnnotation2.title = @"铁人三项跑步";
//    pointAnnotation2.subtitle = @"该段为铁人三项跑步段";
//    pointAnnotation2.annotationType = CustomSportPointAnnotationType_Sport;
//
//    //添加大头针标注
//    CustomPointAnnotation * pointAnnotation3 = [[CustomPointAnnotation alloc]init];
//    pointAnnotation3.coordinate = CLLocationCoordinate2DMake(22.548327, 114.331404);
//    pointAnnotation3.title = @"结束点";
//    pointAnnotation3.subtitle = @"该处为长跑马拉松结束点";
//    pointAnnotation3.annotationType = CustomSportPointAnnotationType_End;
}

- (void)didEndTracking:(Tracking *)tracking
{
    //添加大头针标注
    CustomPointAnnotation * pointAnnotation3 = [[CustomPointAnnotation alloc]init];
    pointAnnotation3.coordinate = CLLocationCoordinate2DMake(22.548327, 114.331404);
    pointAnnotation3.title = @"结束点";
    pointAnnotation3.subtitle = @"该处为长跑马拉松结束点";
    pointAnnotation3.annotationType = CustomSportPointAnnotationType_End;
    [self.mapView addAnnotation:pointAnnotation3];
    [self.dotAnnotationArr addObject:pointAnnotation3];
    
    NSLog(@"%s", __func__);
    [self renderMapTrajectoryView];
}

- (void)animationTracking:(Tracking *)tracking andCoordinates:(CLLocationCoordinate2D)coordinates
{
    //添加大头针标注
    CustomPointAnnotation * pointAnnotation1 = [[CustomPointAnnotation alloc]init];
    pointAnnotation1.coordinate= coordinates;
    pointAnnotation1.title = @"1公里打点";
    pointAnnotation1.subtitle = @"该处为跑步1公里gps点";
    pointAnnotation1.annotationType = CustomSportPointAnnotationType_Distance;
    pointAnnotation1.distanceIndex = 1000;
    [self.mapView addAnnotation:pointAnnotation1];
    [self.dotAnnotationArr addObject:pointAnnotation1];
}

#pragma mark - 添加半透明覆盖层
- (void)addTransparentOverlay{
    self.transparentCircle = [MACircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(39.905, 116.398) radius:100000000];
    [self.mapView addOverlay:self.transparentCircle level:1];
}


- (IBAction)clickChangValue:(UISegmentedControl *)sender {
    NSLog(@"---------%zd",sender.selectedSegmentIndex);
    [self.mapView setMapType:sender.selectedSegmentIndex];
    switch (sender.selectedSegmentIndex) {
        case 0 :
        {
            MainViewController * mainVc = [[MainViewController alloc]init];
            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:mainVc];
            [self presentViewController:nav animated:YES completion:nil];
            NSLog(@"标准");
        }
            break;
        case 1:
        {
              NSLog(@"卫星");
        }
            break;
        case 2:
        {
            NSLog(@"夜景");
        }
            break;
        case 3:
        {
            NSLog(@"导航");
        }
            break;
            
        default:
            break;
    }
}
- (IBAction)startAnimationChangValue:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            //开始动画
            MAAnimatedAnnotation * animationAnnotation = [[MAAnimatedAnnotation alloc]init];
            animationAnnotation.coordinate = CLLocationCoordinate2DMake(22.548327, 114.031404);
            self.animationAnnotation = animationAnnotation;
            animationAnnotation.title = @"移动点";
            animationAnnotation.subtitle = @"干啥";
            
            [self.mapView addAnnotation:self.animationAnnotation];
            self.animationAnnotation.coordinate = CLLocationCoordinate2DMake(22.548327, 114.031404);
            //创建经纬度
            CLLocationCoordinate2D polyLineCoords[4];
            polyLineCoords[0].latitude = 22.548327;
            polyLineCoords[0].longitude = 114.031404;
            
            polyLineCoords[1].latitude = 22.558337;
            polyLineCoords[1].longitude = 114.231404;
            
            polyLineCoords[2].latitude = 22.949327;
            polyLineCoords[2].longitude = 114.131404;
            
            polyLineCoords[3].latitude = 22.548327;
            polyLineCoords[3].longitude = 114.331404;
            
            __weak typeof(self)weakSelf =self;
            [self.animationAnnotation addMoveAnimationWithKeyCoordinates:polyLineCoords count:4 withDuration:5.0f withName:nil completeCallback:^(BOOL isFinished) {
                if (isFinished) {
                    NSLog(@"-----------------完成");
                    [weakSelf.mapView removeAnnotation:weakSelf.animationAnnotation];
//                    [weakSelf renderMapTrajectoryView];
                }else{
                    for (MAAnnotationMoveAnimation * animation in weakSelf.animationAnnotation.allMoveAnimations) {
                        [animation cancel];
                    }
                }
                
            } stepCallback:^(MAAnnotationMoveAnimation *currentAni) {
                
            }];
            
        }
            break;
        case 1:
        {
            //结束动画
            for (MAAnnotationMoveAnimation * animation in [self.animationAnnotation allMoveAnimations]) {
                [animation cancel];
            }
            [self.mapView removeAnnotation:self.animationAnnotation];
            //并且绘制完所有的轨迹
//            [self renderMapTrajectoryView];
        }
            break;
            
        default:
            break;
    }
    
}

-(void)renderMapTrajectoryView{
    
    CLLocationCoordinate2D polyLineCoords1[2];
    polyLineCoords1[0].latitude = 22.548327;
    polyLineCoords1[0].longitude = 114.031404;
    
    polyLineCoords1[1].latitude = 22.558337;
    polyLineCoords1[1].longitude = 114.231404;
    
    CLLocationCoordinate2D polyLineCoords0[2];
    polyLineCoords0[0].latitude = 22.558337;
    polyLineCoords0[0].longitude = 114.231404;
    
    polyLineCoords0[1].latitude = 22.949327;
    polyLineCoords0[1].longitude = 114.131404;
    
    CLLocationCoordinate2D polyLineCoords2[2];
    polyLineCoords2[0].latitude = 22.949327;
    polyLineCoords2[0].longitude = 114.131404;
    
    polyLineCoords2[1].latitude = 22.548327;
    polyLineCoords2[1].longitude = 114.331404;
    
    CustomPolyline * commonPolyLine = [CustomPolyline polylineWithCoordinates:polyLineCoords1 count:2 drawStyleIndexes:@[@0,@1,@2]];
    commonPolyLine.polyLineType = CustomPolylineType_Run;
    CustomPolyline * commonPolyLine0 = [CustomPolyline polylineWithCoordinates:polyLineCoords0 count:2 drawStyleIndexes:@[@0,@1,@2]];
    commonPolyLine0.polyLineType = CustomPolylineType_Swim;
    CustomPolyline * commonPolyLine1 = [CustomPolyline polylineWithCoordinates:polyLineCoords2 count:2 drawStyleIndexes:@[@0,@1,@2]];
    commonPolyLine1.polyLineType = CustomPolylineType_Rid;
    
    [self.mapView addOverlay:commonPolyLine level:1];
    [self.mapView addOverlay:commonPolyLine0 level:1];
    [self.mapView addOverlay:commonPolyLine1 level:1];
}

- (IBAction)dotChangValue:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            [self.mapView addAnnotations:self.dotAnnotationArr];
        }
            break;
        case 1:
        {
            //无点
            [self.mapView removeAnnotations:self.dotAnnotationArr];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)keyframeAnimationWithView:(UIView *)view {
    // 创建关键帧动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@1.0 ,@1.2, @1.4,@1.2,@1.0];
    animation.duration = 0.2;
    // 动画模式
    animation.calculationMode = kCAAnimationCubic;
    [view.layer addAnimation:animation forKey:@"transform.scale"];
}

/**
 * @brief 根据anntation生成对应的View。
 
 注意：5.1.0后由于定位蓝点增加了平滑移动功能，如果在开启定位的情况先添加annotation，需要在此回调方法中判断annotation是否为MAUserLocation，从而返回正确的View。
 if ([annotation isKindOfClass:[MAUserLocation class]]) {
 return nil;
 }
 
 * @param mapView 地图View
 * @param annotation 指定的标注
 * @return 生成的标注View
 */
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
    }else if ([annotation isKindOfClass:[CustomPointAnnotation class]]){
        CustomPointAnnotation * customAnnotation = (CustomPointAnnotation *)annotation;
        static NSString * pointId = @"MAPointAnnotationPointId";
//        MAAnnotationView自定义的样式
        CustomAnnotationView * annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointId];
        if (annotationView == nil) {
            annotationView = [[CustomAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:pointId];
        }
//        annotationView.canShowCallout = NO; //设置气泡可以弹出.默认为NO.设置为NO.弹出自定义的calloutView
//        annotationView.animatesDrop = YES; //设置标注动画显示.默认为NO
//        annotationView.pinColor = MAPinAnnotationColorGreen;//设置点的颜色
//        annotationView.draggable = NO; //设置标注可以拖动.默认为NO
        switch (customAnnotation.annotationType) {
            case CustomSportPointAnnotationType_Start:
                annotationView.image = [UIImage imageNamed:@"ios_sports_map_start_icon_annotation"];
                annotationView.distanceSum = 0;
                break;
            case CustomSportPointAnnotationType_End:
                annotationView.image = [UIImage imageNamed:@"ios_sports_map_end_icon_annotation"];
                annotationView.distanceSum = 0;
                break;
            case CustomSportPointAnnotationType_Sport:
                annotationView.image = [UIImage imageNamed:@"ios_sports_map_run_icon_annotation"];
                annotationView.distanceSum = 0;
                break;
            case CustomSportPointAnnotationType_Distance:
            {
                annotationView.image = [UIImage new];
                annotationView.distanceSum = customAnnotation.distanceIndex;
            }
                break;
                
            default:
                break;
        }
//        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
//        annotationView.centerOffset = CGPointMake(0, -18);
        //放大又还原的操作
        [self keyframeAnimationWithView:annotationView];
        return annotationView;
        
    }else if ([annotation isKindOfClass:[MAAnimatedAnnotation class]]){
        NSString *pointReuseIndetifier = @"myReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:pointReuseIndetifier];
        
            annotationView.image =  [UIImage imageNamed:@"aeroplane"];
        }
        
        annotationView.canShowCallout               = YES;
        annotationView.animatesDrop                 = NO;
        annotationView.draggable                    = NO;
        UIImageView * imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"梧桐山"]];
        imgView.frame = CGRectMake(0, 0, 100, 60);
        annotationView.leftCalloutAccessoryView = imgView;
        return annotationView;
        
    }
    return nil;
}

-(MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[CustomPolyline class]]) {
        CustomPolyline *polyLine  = (CustomPolyline *)overlay;
        //绘制单色 - 还可绘制多彩色
//        MAPolylineRenderer * polylineRenderer = [[MAPolylineRenderer alloc]initWithOverlay:overlay];
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc]initWithMultiPolyline:polyLine];
        polylineRenderer.lineWidth = 8.0f;
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.lineCapType = kMALineCapRound;
        polylineRenderer.gradient = NO;
        switch (polyLine.polyLineType) {
            case CustomPolylineType_Rid:
//                polylineRenderer.strokeColor = UIColor.redColor;
        
                polylineRenderer.strokeColors = @[UIColor.redColor,UIColor.blueColor,UIColor.orangeColor];
                polylineRenderer.gradient = YES;
                break;
            case CustomPolylineType_Run:
                polylineRenderer.strokeColor = UIColor.blueColor;
                break;
            case CustomPolylineType_Swim:
                polylineRenderer.strokeColor = UIColor.orangeColor;
                break;
            case CustomPolylineType_Change:
                polylineRenderer.strokeColor = UIColor.grayColor;
                break;
            default:
                polylineRenderer.strokeColor = UIColor.greenColor;
                break;
        }
        return polylineRenderer;
    }else if ([overlay isKindOfClass:[MACircle class]]){
        MACircleRenderer * circleRenderer = [[MACircleRenderer alloc]initWithCircle:overlay];
        circleRenderer.fillColor = [[UIColor blackColor]colorWithAlphaComponent:0.8];
        return circleRenderer;
    }
    return nil;
}




-(MAAnnotationView *)annotationView
{
    if (!_annotationView) {
        _annotationView = [[MAAnnotationView alloc]init];
    }
    return _annotationView;
}

-(NSMutableArray *)dotAnnotationArr
{
    if (!_dotAnnotationArr) {
        _dotAnnotationArr = [NSMutableArray array];
    }
    return _dotAnnotationArr;
}
@end
