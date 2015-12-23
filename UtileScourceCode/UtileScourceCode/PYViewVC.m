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


static void bb(id target, SEL action){
}

@interface PYViewVC ()
@property (nonatomic,strong) UIImage *imageOrg;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *text;
@property (nonatomic) UIView *view01;
@property (nonatomic) UIView *view02;
@property (nonatomic) UIView *view03;
@property (nonatomic, strong) PYGraphicsThumb *gt;

@end

@implementation PYViewVC
+ (NSMethodSignature *) instanceMethodSignatureForSelector:(SEL)aSelector{
    return [self instanceMethodSignatureForSelector:aSelector];
}
+(void) aa{
}


- (void)viewDidLoad {
    SEL action = @selector(aa);
    Method method = class_getClassMethod(self.class, action);
    const char * typeEncoding =  method_getTypeEncoding(method);
    method_setImplementation(method, (IMP)_objc_msgForward);
    [self.class aa];
    
    
    [super viewDidLoad];
    [PYHook mergeHookInstanceWithTarget:self.class action:@selector(b:) blockBefore:^BOOL(NSInvocation *invoction) {
        NSLog(@"");
        return true;
    } blockAfter:^(NSInvocation * invoction) {
        NSLog(@"");
    }];
    CGPoint a = [self b:CGPointMake(20, 20)];
    self.view01 = [PYDrawView new];
    self.view01.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.view01];
    self.view02 = [UIView new];
    self.view02.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.view02];
    self.gt = [PYGraphicsThumb graphicsThumbWithView:self.view block:^(CGContextRef ctx, id userInfo) {
        NSNumber *index = userInfo;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[index stringValue]];
        CGRect rect = CGRectMake(20, 20, boundsWidth(), boundsHeight());
        CGRect * rects = {&rect};
        CGRect _rect = CGRectMake(20, 40, boundsWidth(), boundsHeight());
        CGRect * _rects = {&_rect};
        [PYGraphicsDraw drawTextWithContext:ctx attribute:attr rects:rects lenghtRect:1 y:boundsHeight() scaleFlag:YES];
        [PYGraphicsDraw drawTextWithContext:ctx attribute:attr rects:_rects lenghtRect:1 y:boundsHeight() scaleFlag:YES];
    }];
//    NSArray *filters = [CIFilter filterNamesInCategory:kCICategoryGradient];
//    self.imageOrg = self.imageView.image;
    @weakify(self)
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        @strongify(self)
//        @weakify(self)
//        for (NSString *filterName in filters) {
//            if ([filterName isEqualToString:@"CIAztecCodeGenerator"]) {
//                continue;
//            }
//            // 耗时的操作
//            @weakify(filterName);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                @strongify(self)
//                @strongify(filterName)
//                UIImage *image = [UIImage imageWithImage:self.imageOrg colorMatrix: filterName];
//                if (image) {
//                    [self.imageView setImage:image];
//                }
//            });
//            [NSThread sleepForTimeInterval:0.5f];
//        }
//    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self)
        @weakify(self)
        __block NSUInteger index = 0;
        while (true) {
            index += 1;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                [self.gt executDisplay:@(index)];
            });
            [NSThread sleepForTimeInterval:2];
        }
    });
    
    
    [PYViewAutolayoutCenter persistConstraint:self.view01 relationmargins:UIEdgeInsetsMake(0, 20, DisableConstrainsValueMAX, 20) relationToItems:PYEdgeInsetsItemNull()];
    [PYViewAutolayoutCenter persistConstraint:self.view01 size:CGSizeMake(DisableConstrainsValueMAX, 300)];

    [PYViewAutolayoutCenter persistConstraint:self.view02 size:CGSizeMake(300, 10)];
    [PYViewAutolayoutCenter persistConstraint:self.view02 centerPointer:CGPointMake(0, DisableConstrainsValueMAX)];
    [PYViewAutolayoutCenter persistConstraint:self.view02 relationmargins:UIEdgeInsetsMake(20, DisableConstrainsValueMAX, DisableConstrainsValueMAX, DisableConstrainsValueMAX) relationToItems:PYEdgeInsetsItemMake((__bridge void * _Nullable)(self.view01), nil, nil, nil)];
    
    
    [PYKeyboardNotification setKeyboardNotificationWithResponder:self.text start:^(CGRect keyBoardFrame) {
        
    } end:^(CGRect keyBoardFrame) {
        
    }];
    UILabel *lable = [UILabel new];
    lable.frame = CGRectMake(20, 200, 40, 40);
    lable.textColor = [UIColor redColor];
    lable.attributedText = [[NSAttributedString alloc] initWithString:@"a\nadlkfjaldkjfaldkjfaldjflaj\nsdfsd"];
    [self.view addSubview:lable];
    [lable automorphismWidth];
    [lable automorphismHeight];
    // Do any additional setup after loading the view.
}
-(void) viewDidAppear:(BOOL)animated{
    [self.view drawView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(CGPoint) b:(CGPoint) a{
    return CGPointMake(a.x, a.y * 2);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
