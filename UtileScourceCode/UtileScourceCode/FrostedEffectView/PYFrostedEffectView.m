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
#import "PYOrientationListener.h"
#import "PYViewAutolayoutCenter.h"
#import <QuartzCore/QuartzCore.h>
#import "PYViewAutolayoutCenter.h"

@interface PYFrostedEffectView()<PYOrientationListener>
@property (nonatomic, strong) UIImageView *imageViewForstedEffect;
@property (nonatomic, strong) UIImage *imageForstedEffect;
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
-(instancetype) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initParams];
    }
    return self;
}
-(void) initParams{
    _effectValue = 1;
    self.backgroundColor = [UIColor clearColor];
    self.imageViewForstedEffect = [UIImageView new];
    [self addSubview:self.imageViewForstedEffect];
    [PYViewAutolayoutCenter persistConstraint:self.imageViewForstedEffect relationmargins:UIEdgeInsetsMake(0, 0, 0, 0) relationToItems:PYEdgeInsetsItemNull()];
    [[PYOrientationListener instanceSingle] addListener:self];
}

-(void) setEffectValue:(CGFloat)effectValue{
    _effectValue = MAX(MIN(effectValue, 1), 0);
}

-(void) refreshImage{
    @unsafeify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @strongify(self);
        NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];
        
        CGRect visibleRect = self.frame;
        visibleRect.origin.y += self.superview.frame.origin.y;
        visibleRect.origin.x += self.superview.frame.origin.x;
        
        self.hidden = YES;
        CGFloat scale = (1 - (_effectValue - _effectValue * .4)) * 2 * (1 - (_effectValue - _effectValue  * .4));
        UIImage * imageOrg = [self.viewTarget ? self.viewTarget : self.superview drawViewWithBounds:visibleRect scale:scale];
        self.hidden = NO;
        
        UIImage * imageForstedEffect = [imageOrg applyEffect:self.effectValue tintColor:[UIColor clearColor]];
        t = [NSDate timeIntervalSinceReferenceDate] - t;
        @synchronized(self.imageViewForstedEffect) {
            self.imageForstedEffect = imageForstedEffect;
        }
        
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            @synchronized(self.imageViewForstedEffect) {
                self.imageViewForstedEffect.image = self.imageForstedEffect;
            }
        });
    });
}
//-(void) layoutSubviews{
//    [super layoutSubviews];
//    if ((self.lastRect.origin.x != self.frame.origin.x ||
//        self.lastRect.origin.y != self.frame.origin.y ||
//        self.lastRect.size.width != self.frame.size.width ||
//        self.lastRect.size.height != self.frame.size.height) &&
//        self.frame.size.width > 0 &&
//        self.frame.size.height > 0 &&
//        self.flagAuto) {
//        if (!self.imageOrg) {
//            [self refreshForstedEffect];
//        }
//    }
//    self.lastRect = self.frame;
//}
//// Device oriented vertically, home button on the bottom
//-(void) deviceOrientationPortrait{
//    if (self.flagAuto) {
//        [self refreshForstedEffect];
//    }
//}
//// Device oriented vertically, home button on the top
//-(void) deviceOrientationPortraitUpsideDown{
//    if (self.flagAuto) {
//        [self refreshForstedEffect];
//    }
//}
//// Device oriented horizontally, home button on the right
//-(void) deviceOrientationLandscapeLeft{
//    if (self.flagAuto) {
//        [self refreshForstedEffect];
//    }
//}
//// Device oriented horizontally, home button on the left
//-(void) deviceOrientationLandscapeRight{
//    if (self.flagAuto) {
//        [self refreshForstedEffect];
//    }
//}



@end
