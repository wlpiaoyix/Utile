//
//  PYViewVC.m
//  UtileScourceCode
//
//  Created by wlpiaoyi on 15/10/23.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "PYViewVC.h"
#import "PYKeyboardNotification.h"
#import "UILable+Expand.h"
#import "PYViewAutolayoutCenter.h"
#import "UIImage+Expand.h"
#import "EXTScope.h"
#import "PYGraphicsDraw.h"
#import "PYGraphicsThumb.h"
#import "UIView+Expand.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "PYHook.h"
#import "PYFrostedEffectView.h"
#import "PYReachabilityListener.h"
#import "PYOrientationListener.h"
#import "PYKeyboardNotification.h"

@interface PYDrawView:UIView
@end
@implementation PYDrawView

-(void) drawRect:(CGRect)rect{
//    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"我的吃sdfgsdfg"];
//    [attributeStr setAttributes:@{(NSString*)kCTForegroundColorAttributeName:[UIColor whiteColor],(NSString*)kCTFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(0, attributeStr.length)];
//    [PYGraphicsDraw drawTextWithContext:nil attribute:attributeStr rect:rect y:0 scaleFlag:YES];
    [PYGraphicsDraw drawLinearGradientWithContext:nil colorValues:(CGFloat[]){
        0.01f, 0.99f, 0.01f, 1.0f,
        0.01f, 0.99f, 0.99f, 1.0f,
        0.99f, 0.99f, 0.01f, 1.0f
    } alphas:(CGFloat[]){
        0.1f,
        0.5f,
        0.9f
    } length:3 startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, 200)];
    
//    CGRect r = CGRectMake(0, 0, 40, 30);
//    [PYGraphicsDraw drawEllipseWithContext:nil rect:r strokeColor:[[UIColor grayColor] CGColor] fillColor:[[UIColor blueColor] CGColor] strokeWidth:6];
//    [PYGraphicsDraw drawCircleWithContext:nil pointCenter:CGPointMake(80, 20) radius:15 strokeColor:[[UIColor whiteColor] CGColor] fillColor:[[UIColor clearColor] CGColor] strokeWidth:10 startDegree:20 endDegree:260];
//    CGPoint pointer[3] = {CGPointMake(40, 0),CGPointMake(80, 0),CGPointMake(80, 40)};
//    [PYGraphicsDraw drawPolygonWithContext:nil pointer:pointer pointerLength:3 strokeColor:[[UIColor blueColor] CGColor] fillColor:nil strokeWidth:4];
//    CGFloat lengthPoint[2] = {5,10};
//    [PYGraphicsDraw drawLineWithContext:nil startPoint:CGPointMake(20, 20) endPoint:CGPointMake(300, 70) strokeColor:[[UIColor yellowColor] CGColor] strokeWidth:2 lengthPointer:lengthPoint length:2];
}

@end


@interface PYViewVC ()<PYReachabilityListener, PYOrientationListener>
@property (nonatomic,strong) UIImage *imageOrg;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *text;
@property (strong, nonatomic) UITextField *text2;
@property (nonatomic) UIView *view01;
@property (nonatomic) UIView *view02;
@property (nonatomic) UIView *view03;
@property (nonatomic, strong) PYGraphicsThumb *gt;
@property (strong, nonatomic) PYFrostedEffectView *forview;

@end

@implementation PYViewVC
+ (NSMethodSignature *) instanceMethodSignatureForSelector:(SEL)aSelector{
    return [self instanceMethodSignatureForSelector:aSelector];
}

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    UIView *view1 = [UIView new];
    UIView *view2 = [UIView new];
    UIView *view3 = [UIView new];
    UIView *view4 = [UIView new];
    UIView *view5 = [UIView new];
    view1.backgroundColor = [UIColor redColor];
    view2.backgroundColor = [UIColor yellowColor];
    view3.backgroundColor = [UIColor blueColor];
    view4.backgroundColor = [UIColor greenColor];
    view5.backgroundColor = [UIColor orangeColor];
    NSArray *array = @[view1, view2, view3, view4, view5];
    for (UIView * view in array) {
        [[self.view viewWithTag:55] addSubview:view];
    }
    [PYViewAutolayoutCenter persistConstraintVertical:array relationmargins:UIEdgeInsetsMake(0, 0, 0, 0) relationToItems:PYEdgeInsetsItemMake(nil, nil, nil, nil) offset:3];
    [[PYReachabilityListener instanceSingle] addListener:self];
    [[PYOrientationListener instanceSingle] addListener:self];
    
    self.text2 = [UITextField new];
    [self.view addSubview:self.text2];
    
  
}
-(void) viewDidAppear:(BOOL)animated{
    [self.view drawView];
    [self.text2 removeFromSuperview];
    self.text2 = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(CGPoint) b:(CGPoint) a{
    return CGPointMake(a.x, a.y * 2);
}

/**
 没有网络
 */
-(void) notReachable{
    
}
/**
 2G/3G/4G网络
 */
-(void) reachableViaWWAN{
    
}
/**
 WIFI/WLAN网络
 */
-(void) reachableViaWiFi{
    
}

// Device oriented vertically, home button on the bottom
-(void) deviceOrientationPortrait{
}
// Device oriented vertically, home button on the top
-(void) deviceOrientationPortraitUpsideDown{
}
// Device oriented horizontally, home button on the right
-(void) deviceOrientationLandscapeLeft{
}
// Device oriented horizontally, home button on the left
-(void) deviceOrientationLandscapeRight{
}
// Device oriented horizontally, home button not support
-(void) deviceOrientationNotSupport:(UIDeviceOrientation) deviceOrientation{

}
@end
