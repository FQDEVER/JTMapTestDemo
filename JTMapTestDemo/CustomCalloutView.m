//
//  CustomCalloutView.m
//  JTMapTestDemo
//
//  Created by 范奇 on 2019/3/18.
//  Copyright © 2019 范奇. All rights reserved.
//

#import "CustomCalloutView.h"
#define kArrorHeight        10

#define kPortraitMargin     5
#define kPortraitWidth      70
#define kPortraitHeight     50

#define kTitleWidth         120
#define kTitleHeight        20


@interface CustomCalloutView ()

@property (nonatomic, strong) UIImageView * portraitView ;

@property (nonatomic, strong) UILabel * subtitleLabel ;

@property (nonatomic, strong) UILabel * titleLabel ;

@end

@implementation CustomCalloutView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self creatUI];
    }
    return self;
}

-(void)creatUI{
    self.portraitView = [[UIImageView alloc]initWithFrame:CGRectMake(kPortraitMargin, kPortraitMargin, kPortraitWidth, kPortraitHeight)];
    self.portraitView.backgroundColor = UIColor.blackColor;
    [self addSubview:self.portraitView];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kPortraitMargin * 2 + kPortraitWidth, kPortraitMargin, kTitleWidth, kTitleHeight)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.text = @"titleLabeltitleLabel";
    [self addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kPortraitMargin * 2 + kPortraitWidth, kPortraitMargin * 2 + kTitleHeight, kTitleWidth, kTitleHeight)];
    self.subtitleLabel.font = [UIFont systemFontOfSize:12];
    self.subtitleLabel.textColor = UIColor.lightGrayColor;
    self.subtitleLabel.text = @"subtitleLabelsubtitleLabelsubt";
    [self addSubview:self.subtitleLabel];
}

-(void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

-(void)setSubTitle:(NSString *)subTitle
{
    self.subtitleLabel.text = subTitle;
}

-(void)setImage:(UIImage *)image{
    self.portraitView.image = image;
}
#pragma mark - 绘制背景色.并且添加一个小尖尖

-(void)drawRect:(CGRect)rect
{
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = UIColor.blackColor.CGColor;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

- (void)drawInContext:(CGContextRef)context
{
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8].CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
    
}

- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

@end
