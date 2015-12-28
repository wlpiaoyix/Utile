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

@implementation PYFrostedEffectView

-(instancetype) init{
    if (self = [super init]) {
        self.effectValue = .5;
    }
    return self;
}
-(instancetype) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.effectValue = .5;
    }
    return self;
}

-(void) refreshForstedEffect{
    self.backgroundColor = [UIColor clearColor];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @strongify(self);
        
        @weakify(self);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            CGFloat alpha = self.alpha;
            [PYFrostedEffectView toggleBlurViewsInView:self.superview hidden:YES alpha:alpha];
            
            __block CGRect visibleRect = [self.superview convertRect:self.frame toView:self];
            visibleRect.origin.y += self.frame.origin.y;
            visibleRect.origin.x += self.frame.origin.x;
            
            UIImage *image = [[self.superview drawViewWithBounds:visibleRect] applyEffect:self.effectValue];
            [PYFrostedEffectView toggleBlurViewsInView:self.superview hidden:NO alpha:alpha];
            self.layer.contents = (id)image.CGImage;
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
