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
#import "PYFrostedEffectView.h"



CGFloat ScreenWidth = 375;
CGFloat ScreenHigh = 667;

@interface PYDrawView:UIView
//@property (nonatomic, strong) PYFrostedEffectView *feView;
@property (nonatomic) NSTimeInterval timer;
@end
@implementation PYDrawView
-(void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([NSDate timeIntervalSinceReferenceDate] -self.timer > 0.05) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
//        self.feView.effectValue = point.x / self.frame.size.width;
//        [self.feView refreshForstedEffect];
        self.timer = [NSDate timeIntervalSinceReferenceDate];
    }

}

//-(void) drawRect:(CGRect)rect{
////    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"我的吃sdfgsdfg"];
////    [attributeStr setAttributes:@{(NSString*)kCTForegroundColorAttributeName:[UIColor whiteColor],(NSString*)kCTFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(0, attributeStr.length)];
////    [PYGraphicsDraw drawTextWithContext:nil attribute:attributeStr rect:rect y:0 scaleFlag:YES];
//    [PYGraphicsDraw drawLinearGradientWithContext:nil colorValues:(CGFloat[]){
//        0.01f, 0.99f, 0.01f, 1.0f,
//        0.01f, 0.99f, 0.99f, 1.0f,
//        0.99f, 0.99f, 0.01f, 1.0f
//    } alphas:(CGFloat[]){
//        0.1f,
//        0.5f,
//        0.9f
//    } length:3 startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, 200)];
//    
////    CGRect r = CGRectMake(0, 0, 40, 30);
////    [PYGraphicsDraw drawEllipseWithContext:nil rect:r strokeColor:[[UIColor grayColor] CGColor] fillColor:[[UIColor blueColor] CGColor] strokeWidth:6];
////    [PYGraphicsDraw drawCircleWithContext:nil pointCenter:CGPointMake(80, 20) radius:15 strokeColor:[[UIColor whiteColor] CGColor] fillColor:[[UIColor clearColor] CGColor] strokeWidth:10 startDegree:20 endDegree:260];
////    CGPoint pointer[3] = {CGPointMake(40, 0),CGPointMake(80, 0),CGPointMake(80, 40)};
////    [PYGraphicsDraw drawPolygonWithContext:nil pointer:pointer pointerLength:3 strokeColor:[[UIColor blueColor] CGColor] fillColor:nil strokeWidth:4];
////    CGFloat lengthPoint[2] = {5,10};
////    [PYGraphicsDraw drawLineWithContext:nil startPoint:CGPointMake(20, 20) endPoint:CGPointMake(300, 70) strokeColor:[[UIColor yellowColor] CGColor] strokeWidth:2 lengthPointer:lengthPoint length:2];
//}

@end


@interface PYViewVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary <NSString *, NSString *> *> * datas;
@property (nonatomic) NSString * identify;

@end

@implementation PYViewVC
+ (NSMethodSignature *) instanceMethodSignatureForSelector:(SEL)aSelector{
    return [self instanceMethodSignatureForSelector:aSelector];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datas = [NSArray arrayWithObjects:
                  @{@"key":@(0), @"name":@"截屏", @"identify":@"cutScreen"},
                  @{@"key":@(1), @"name":@"绘图", @"identify":@"gdc"},
                  @{@"key":@(1), @"name":@"二维码", @"identify":@"QRCode"},
                  nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.datas count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    NSDictionary * data = self.datas[indexPath.row];
    cell.textLabel.text = data[@"name"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dict = self.datas[indexPath.row];
    self.identify = dict[@"identify"];
    [self performSelector:@selector(goNext)];
}

-(void) goNext{
    [self performSegueWithIdentifier:self.identify sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
