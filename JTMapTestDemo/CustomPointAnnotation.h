//
//  CustomPointAnnotation.h
//  JTMapTestDemo
//
//  Created by 范奇 on 2019/3/18.
//  Copyright © 2019 范奇. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

//最新表盘排序样式
typedef enum : NSInteger{
    CustomSportPointAnnotationType_Start = 0,         //开始
    CustomSportPointAnnotationType_Distance,       //距离
    CustomSportPointAnnotationType_Sport,         //运动
    CustomSportPointAnnotationType_End,        //结束
}CustomSportPointAnnotationType;

@interface CustomPointAnnotation : MAPointAnnotation

/**
 自定义运动类型
 */
@property (nonatomic, assign) CustomSportPointAnnotationType annotationType;

/**
 里程圈数
 */
@property (nonatomic, assign) NSInteger distanceIndex;

@end
