//
//  ViewAutolayoutCenter.m
//  Common
//
//  Created by wlpiaoyi on 15/1/5.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

#import "PYViewAutolayoutCenter.h"
#import "UIView+Expand.h"


const CGFloat DisableConstrainsValueMAX = CGFLOAT_MAX - 1;
const CGFloat DisableConstrainsValueMIN  = -DisableConstrainsValueMAX;

@implementation PYViewAutolayoutCenter

+(void) removeConstraints:(UIView*) subView{
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *constraints = [subView constraints];
    [subView removeConstraints:constraints];
    UIView *superView = [subView superview];
    constraints = [superView constraints];
    if (constraints&&[constraints count]) {
        for (NSLayoutConstraint *constraint in constraints) {
            if (constraint.secondItem==subView||constraint.firstItem==superView) {
                [superView removeConstraint:constraint];
            }
        }
    }
}

/**
 新增关系约束
 */
+(void) persistConstraint:(UIView*) subView relationmargins:(UIEdgeInsets) margins relationToItems:(PYEdgeInsetsItem) toItems{
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    if ([self isValueEnable:margins.top]) {
        UIView *superView = (__bridge UIView *)(toItems.top);
        NSLayoutAttribute superAtt = NSLayoutAttributeBottom;
        if (!superView) {
            superView = [subView superview];
            superAtt = NSLayoutAttributeTop;
        }
        NSLayoutConstraint *marginsTop = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:superAtt multiplier:1 constant:margins.top];
        [[subView superview] addConstraint:marginsTop];
    }
    if ([self isValueEnable:margins.bottom]) {
        UIView *superView = (__bridge UIView *)(toItems.bottom);
        
        NSLayoutAttribute superAtt = NSLayoutAttributeTop;
        if (!superView) {
            superView = [subView superview];
            superAtt = NSLayoutAttributeBottom;
        }
        NSLayoutConstraint *marginsBottom = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:superAtt multiplier:1 constant:-margins.bottom];
        [[subView superview] addConstraint:marginsBottom];
    }
    if ([self isValueEnable:margins.left]) {
        UIView *superView = (__bridge UIView *)(toItems.left);
        NSLayoutAttribute superAtt = NSLayoutAttributeRight;
        if (!superView) {
            superView = [subView superview];
            superAtt = NSLayoutAttributeLeft;
        }
        NSLayoutConstraint *marginsLeft = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:superAtt multiplier:1 constant:margins.left];
        [[subView superview] addConstraint:marginsLeft];
    }
    if ([self isValueEnable:margins.right]) {
        UIView *superView = (__bridge UIView *)(toItems.right);
        NSLayoutAttribute superAtt = NSLayoutAttributeLeft;
        if (!superView) {
            superView = [subView superview];
            superAtt = NSLayoutAttributeRight;
        }
        NSLayoutConstraint *marginsRight = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superView attribute:superAtt multiplier:1 constant:-margins.right];
        [[subView superview] addConstraint:marginsRight];
    }
}

/**
 新增大小约束
 */
+(void) persistConstraint:(UIView*) subView size:(CGSize) size{
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *constraints = [NSMutableArray new];
    if ([self isValueEnable:size.width]) {
        NSLayoutConstraint *sizeWith = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:size.width];
        [constraints addObject:sizeWith];
    }
    if ([self isValueEnable:size.height]) {
        NSLayoutConstraint *sizeHeight= [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:size.height];
        [constraints addObject:sizeHeight];
    }
    [subView addConstraints:constraints];
    
}

/*
 新增布局约束
 */
+(void) persistConstraint:(UIView*) subView centerPointer:(CGPoint) pointer{
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superView = [subView superview];
    NSMutableArray *constraints = [NSMutableArray new];
    if ([self isValueEnable:pointer.x]) {
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:pointer.x];
        [constraints addObject:centerX];
    }
    if ([self isValueEnable:pointer.y]) {
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1 constant:pointer.y];
        [constraints addObject:centerY];
    }
    [superView addConstraints:constraints];
}

+(BOOL) isValueEnable:(float) value{
    if (value<DisableConstrainsValueMAX-1&&value>=DisableConstrainsValueMIN+1) {
        return YES;
    }
    return NO;
}

@end
