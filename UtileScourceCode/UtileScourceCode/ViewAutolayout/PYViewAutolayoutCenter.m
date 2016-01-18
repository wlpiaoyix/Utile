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

/**
 新增关系约束
 */
+(nonnull NSMutableArray<NSLayoutConstraint *> *) persistConstraint:(UIView*) subView relationmargins:(UIEdgeInsets) margins relationToItems:(PYEdgeInsetsItem) toItems{
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray<NSLayoutConstraint *> * constraints = [NSMutableArray new];
    if ([self isValueEnable:margins.top]) {
        UIView *superView = toItems.top ? (__bridge UIView *)(toItems.top) : nil;
        NSLayoutAttribute superAtt = NSLayoutAttributeBottom;
        if (!superView) {
            superView = [subView superview];
            superAtt = NSLayoutAttributeTop;
        }
        NSLayoutConstraint *marginsTop = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:superAtt multiplier:1 constant:margins.top];
        [constraints addObject:marginsTop];
    }
    if ([self isValueEnable:margins.bottom]) {
        UIView *superView = toItems.bottom ? (__bridge UIView *)(toItems.bottom) : nil;
        
        NSLayoutAttribute superAtt = NSLayoutAttributeTop;
        if (!superView) {
            superView = [subView superview];
            superAtt = NSLayoutAttributeBottom;
        }
        NSLayoutConstraint *marginsBottom = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:superAtt multiplier:1 constant:-margins.bottom];
        [constraints addObject:marginsBottom];
    }
    if ([self isValueEnable:margins.left]) {
        UIView *superView = toItems.left ? (__bridge UIView *)(toItems.left) : nil;
        NSLayoutAttribute superAtt = NSLayoutAttributeRight;
        if (!superView) {
            superView = [subView superview];
            superAtt = NSLayoutAttributeLeft;
        }
        NSLayoutConstraint *marginsLeft = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:superAtt multiplier:1 constant:margins.left];
        [constraints addObject:marginsLeft];
    }
    if ([self isValueEnable:margins.right]) {
        UIView *superView = toItems.right ? (__bridge UIView *)(toItems.right) : nil;
        NSLayoutAttribute superAtt = NSLayoutAttributeLeft;
        if (!superView) {
            superView = [subView superview];
            superAtt = NSLayoutAttributeRight;
        }
        NSLayoutConstraint *marginsRight = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superView attribute:superAtt multiplier:1 constant:-margins.right];
        [constraints addObject:marginsRight];
    }
    [[subView superview] addConstraints:constraints];
    
    return constraints;
}

/**
 新增大小约束
 */
+(nonnull NSMutableArray<NSLayoutConstraint *> *) persistConstraint:(UIView*) subView size:(CGSize) size{
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray<NSLayoutConstraint *> * constraints = [NSMutableArray new];
    if ([self isValueEnable:size.width]) {
        NSLayoutConstraint *sizeWith = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:size.width];
        [constraints addObject:sizeWith];
    }
    if ([self isValueEnable:size.height]) {
        NSLayoutConstraint *sizeHeight= [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:size.height];
        [constraints addObject:sizeHeight];
    }
    [subView addConstraints:constraints];
    
    return constraints;
}
/*
 新增布局约束
 */
+(nonnull NSMutableArray<NSLayoutConstraint *> *) persistConstraint:(UIView*) subView centerPointer:(CGPoint) pointer{
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superView = [subView superview];
    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray new];
    if ([self isValueEnable:pointer.x]) {
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:pointer.x];
        [constraints addObject:centerX];
    }
    if ([self isValueEnable:pointer.y]) {
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1 constant:pointer.y];
        [constraints addObject:centerY];
    }
    [superView addConstraints:constraints];
    
    return constraints;
}

/**
 横向等比约束
 */
+(void) persistConstraintHorizontal:(nonnull NSArray<UIView *> *)subViews relationmargins:(UIEdgeInsets) margins relationToItems:(PYEdgeInsetsItem) toItems offset:(CGFloat) offset{
    
    NSUInteger index = 0;
    for (UIView *subView in subViews) {
        PYEdgeInsetsItem _toItems = toItems;
        UIEdgeInsets _margins = margins;
        
        if (index == 0) {
            _toItems.right = nil;
            _margins.right = DisableConstrainsValueMAX;
            
        }else if(index == [subViews count] - 1){
            _toItems.left = (__bridge void * _Nullable)(subViews[index - 1]);
            _margins.left = offset;
            _toItems.right = nil;
        }else{
            _toItems.left = (__bridge void * _Nullable)(subViews[index - 1]);
            _margins.left = offset;
            _toItems.right = nil;
            _margins.right = DisableConstrainsValueMAX;//offset;
        }
        
        [self persistConstraint:subView relationmargins:_margins relationToItems:_toItems];
        if (index != 0) {
            NSLayoutConstraint *equalsConstraint= [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:subViews.firstObject attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
            [subView.superview addConstraint:equalsConstraint];
        }
        index ++;
    }
}

/**
 纵向等比约束
 */
+(void) persistConstraintVertical:(nonnull NSArray<UIView *> *)subViews relationmargins:(UIEdgeInsets) margins relationToItems:(PYEdgeInsetsItem) toItems offset:(CGFloat) offset{
    
    NSUInteger index = 0;
    for (UIView *subView in subViews) {
        PYEdgeInsetsItem _toItems = toItems;
        UIEdgeInsets _margins = margins;
        
        if (index == 0) {
            _toItems.bottom = nil;
            _margins.bottom = DisableConstrainsValueMAX;
            
        }else if(index == [subViews count] - 1){
            _toItems.top = (__bridge void * _Nullable)(subViews[index - 1]);
            _margins.top = offset;
            _toItems.bottom = nil;
        }else{
            _toItems.top = (__bridge void * _Nullable)(subViews[index - 1]);
            _margins.top = offset;
            _toItems.bottom = nil;
            _margins.bottom = DisableConstrainsValueMAX;//offset;
        }
        
        [self persistConstraint:subView relationmargins:_margins relationToItems:_toItems];
        if (index != 0) {
            NSLayoutConstraint *equalsConstraint= [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:subViews.firstObject attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
            [subView.superview addConstraint:equalsConstraint];
        }
        index ++;
    }
}

+(BOOL) isValueEnable:(float) value{
    if (value<DisableConstrainsValueMAX-1&&value>=DisableConstrainsValueMIN+1) {
        return YES;
    }
    return NO;
}

@end
