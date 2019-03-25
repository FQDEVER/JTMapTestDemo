//
//  CustomPolyline.h
//  JTMapTestDemo
//
//  Created by 范奇 on 2019/3/19.
//  Copyright © 2019 范奇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>

//最新表盘排序样式
typedef enum : NSInteger{
    CustomPolylineType_Swim = 0,         //游泳
    CustomPolylineType_Run,       //跑步
    CustomPolylineType_Rid,         //骑行
    CustomPolylineType_Change,        //转换
    CustomPolylineType_OtherSport,        //其他运动
}CustomPolylineType;

@interface CustomPolyline : MAMultiPolyline //渐变配套的类型.简单样式使用MAPolyline

/**
 自定义线条类型
 */
@property (nonatomic, assign) CustomPolylineType polyLineType;

@end

