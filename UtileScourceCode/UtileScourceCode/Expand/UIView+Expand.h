//
//  UIView+convenience.h
//
//  Created by Tjeerd in 't Veen on 12/1/11.
//  Copyright (c) 2011 Vurig Media. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIView (Expand)

@property (nonatomic) CGPoint frameOrigin;
@property (nonatomic) CGSize frameSize;

@property (nonatomic) CGFloat frameX;
@property (nonatomic) CGFloat frameY;

// Setting these modifies the origin but not the size.
@property (nonatomic) CGFloat frameRight;
@property (nonatomic) CGFloat frameBottom;

@property (nonatomic) CGFloat frameWidth;
@property (nonatomic) CGFloat frameHeight;

/**
 获取相对于目标视图的位置
 */
-(CGPoint) getAbsoluteOrigin:(UIView*) superView;
/**
 添加单击事件
 */
-(UITapGestureRecognizer*) addTarget:(id) target action:(SEL)action;
/**
 图层的简单设置
 */
-(void)setCornerRadiusAndBorder:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor *)color;
/**
 从xib加载数据，序列号要和当前class名称相同
 */
+(instancetype) loadXib;
-(UIImage*) drawView;

@end
