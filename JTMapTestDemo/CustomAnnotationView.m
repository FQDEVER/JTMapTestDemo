//
//  CustomAnnotationView.m
//  JTMapTestDemo
//
//  Created by 范奇 on 2019/3/18.
//  Copyright © 2019 范奇. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "CustomPointAnnotation.h"

#define kCalloutWidth 200.0
#define kCalloutHeight 70.0

@interface CustomAnnotationView()

/**
 弹出的视图
 */
@property (nonatomic, strong,readwrite) CustomCalloutView * calloutView;

/**
 里程圈数
 */
@property (nonatomic, strong) UILabel * distanceIndex ;

@end

@implementation CustomAnnotationView

-(id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        [self creatUI];
        if ([annotation isKindOfClass:[CustomPointAnnotation class]]) {
            CustomPointAnnotation * pointAnnotation = (CustomPointAnnotation *)annotation;
            self.distanceIndex.hidden = !(pointAnnotation.annotationType == CustomSportPointAnnotationType_Distance);
        }
    }
    return self;
}

//创建图片和文本.
 -(void)creatUI{
     UILabel *textLbl = [[UILabel alloc] init];
     textLbl.numberOfLines = 1;
     textLbl.font = [UIFont boldSystemFontOfSize:12];
     textLbl.textColor = UIColor.blackColor;
     textLbl.textAlignment = NSTextAlignmentCenter;
     textLbl.layer.masksToBounds = YES;
     textLbl.backgroundColor = UIColor.whiteColor;
     self.distanceIndex = textLbl;
     self.distanceIndex.frame = CGRectMake(0, 0, 20, 20);
     self.distanceIndex.layer.cornerRadius = 10;
     self.distanceIndex.center = CGPointMake(10, 10);
     NSLog(@"----------%@ - %@",NSStringFromCGPoint(self.calloutOffset),NSStringFromCGPoint(self.distanceIndex.center));
     
     [self addSubview:self.distanceIndex];
     [self insertSubview:self.distanceIndex atIndex:0];
 }

-(void)setDistanceSum:(NSInteger)distanceSum
{
    _distanceSum = distanceSum;
    
    if (distanceSum > 0) {
        self.distanceIndex.text = [NSString stringWithFormat:@"%zd",distanceSum / 1000];
        self.distanceIndex.hidden = NO;
        self.image = [self getDistanceIndexImage];
    }else{
        self.distanceIndex.text = @"";
        self.distanceIndex.hidden = YES;
    }
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected) {
        return;
    }
    
    if (selected) {
        if (self.calloutView == nil) {
            self.calloutView = [[CustomCalloutView alloc]initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(self.calloutOffset.x + CGRectGetWidth(self.bounds) * 0.5, self.calloutOffset.y - CGRectGetHeight(self.calloutView.bounds) * 0.5);
        }
        self.calloutView.image = [UIImage imageNamed:@"梧桐山"];
        self.calloutView.title = self.annotation.title;
        self.calloutView.subTitle = self.annotation.subtitle;
        [self addSubview:self.calloutView];
    }else{
        [self.calloutView removeFromSuperview];
    }
    [super setSelected:selected animated:animated];
}

-(UIImage *)getDistanceIndexImage{

    UIGraphicsBeginImageContext(CGSizeMake(20, 20));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, 20, 20);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    [[UIColor clearColor] set];
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
