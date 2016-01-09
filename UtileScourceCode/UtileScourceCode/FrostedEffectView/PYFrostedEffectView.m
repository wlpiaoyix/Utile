//
//  PYFrostedEffectView.m
//  UtileScourceCode
//
//  Created by wlpiaoyi on 15/12/24.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "PYFrostedEffectView.h"
#import "UIImage+Expand.h"
#import "UIView+Expand.h"
#import "EXTScope.h"
#import <QuartzCore/QuartzCore.h>
@interface PYFrostedEffectView()
@property (nonatomic, strong) UIImageView *imageForstedEffect;
@end

@implementation PYFrostedEffectView

-(instancetype) init{
    if (self = [super init]) {
        [self initParams];
    }
    return self;
}
-(instancetype) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initParams];
    }
    return self;
}
-(void) initParams{
    self.effectValue = .5;
    self.imageForstedEffect = [UIImageView new];
    [self.imageForstedEffect removeFromSuperview];
    self.backgroundColor = [UIColor clearColor];
    self.effectColor = [UIColor clearColor];
    [self addSubview:self.imageForstedEffect];
}

-(void) refreshForstedEffect{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @strongify(self);
        
        @weakify(self);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            CGFloat alpha = self.alpha;
            [PYFrostedEffectView toggleBlurViewsInView:self.superview hidden:YES alpha:alpha];
            
            __block CGRect visibleRect = self.frame;
            visibleRect.origin.y += self.superview.frame.origin.y;
            visibleRect.origin.x += self.superview.frame.origin.x;
            
            self.imageForstedEffect.frameSize = self.frameSize;
            self.imageForstedEffect.frameOrigin = CGPointMake(0, 0);
            self.imageForstedEffect.image = [[self.superview drawViewWithBounds:visibleRect] applyEffect:self.effectValue tintColor:self.effectColor];
            
            [PYFrostedEffectView toggleBlurViewsInView:self.superview hidden:NO alpha:alpha];

        });
    });
}
+ (void)toggleBlurViewsInView:(UIView*)view hidden:(BOOL)hidden alpha:(CGFloat)originalAlpha{
    for (UIView *subview in view.subviews){
        if ([subview isKindOfClass:[PYFrostedEffectView class]]){
            subview.alpha = hidden ? 0.f : originalAlpha;
        }
    }
}
-(void) layoutSubviews{
    [super layoutSubviews];
    [self refreshForstedEffect];
}



@end
