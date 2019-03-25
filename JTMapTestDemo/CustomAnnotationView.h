//
//  CustomAnnotationView.h
//  JTMapTestDemo
//
//  Created by 范奇 on 2019/3/18.
//  Copyright © 2019 范奇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCalloutView.h"
#import <MAMapKit/MAMapKit.h>

//创建其位置 - 整点距离.开始点.结束点.转换点.运动类型点.里程点.

NS_ASSUME_NONNULL_BEGIN

@interface CustomAnnotationView : MAAnnotationView

/**
 弹出的视图
 */
@property (nonatomic, strong,readonly) CustomCalloutView * calloutView;

@property (nonatomic, assign) NSInteger distanceSum;

@end

NS_ASSUME_NONNULL_END
