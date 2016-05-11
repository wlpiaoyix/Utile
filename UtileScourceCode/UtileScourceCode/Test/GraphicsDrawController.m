//
//  GraphicsDrawController.m
//  UtileScourceCode
//
//  Created by wlpiaoyi on 16/4/8.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "GraphicsDrawController.h"
#import "PYGraphicsThumb.h"
#import "PYGraphicsDraw.h"

@interface GraphicsDrawController ()
@property (nonatomic, strong)  PYGraphicsThumb * gt;

@end

@implementation GraphicsDrawController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gt = [PYGraphicsThumb graphicsThumbWithView:self.view block:^(CGContextRef  _Nonnull context, id  _Nullable userInfo) {
        [self drawCurveWithContext:context];
    }];
}
-(void) drawCurveWithContext:(CGContextRef) context{
    
    [PYGraphicsDraw startDraw:&context];
//（上下文，起点的偏移量，事例描述的时20像素的虚线10的空格，数组有2个元素）
//    CGContextSetLineDash(context, 0, nil, 0);
//    CGContextSetLineCap(context, kCGLineCapButt);//线的边角样式（直角型）
//    CGContextSetLineJoin(context, kCGLineJoinRound);
//    CGContextSetLineWidth(context, 2);//线的宽度
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor); //线条颜色
//    CGContextMoveToPoint(context,0,20); // 移动到指定点
//    CGContextAddCurveToPoint(context, 0, 20, 30, 80, 70, 50);
//    CGContextAddQuadCurveToPoint(context, 80, 20, 100, 80);
    //创建CGMutablePathRef
    CGMutablePathRef curvedPath = CGPathCreateMutable();
//    CGPathMoveToPoint(curvedPath, NULL, 0, 0);
    
    UIBezierPath* aPath = [UIBezierPath bezierPathWithCGPath:curvedPath];
    aPath.lineWidth = .5;
    aPath.lineCapStyle = kCGLineCapRound;  //线条拐角
    aPath.lineJoinStyle = kCGLineCapRound;  //终点处理
    [aPath moveToPoint:CGPointMake(0, 0)];
    [aPath addQuadCurveToPoint:CGPointMake(40, 10) controlPoint:CGPointMake(20, 80)];
    [aPath addQuadCurveToPoint:CGPointMake(70, 20) controlPoint:CGPointMake(60, 70)];
    CGContextAddPath(context, curvedPath);
    [aPath stroke];
    [PYGraphicsDraw endDraw:&context];
}
-(void) viewDidAppear:(BOOL)animated{
    [self.gt executDisplay:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
