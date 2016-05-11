//
//  CutScreenController.m
//  UtileScourceCode
//
//  Created by wlpiaoyi on 16/3/28.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "CutScreenController.h"
#import "UIView+Expand.h"

@interface CutScreenController ()
@property (weak, nonatomic) IBOutlet UIView *viewDraw;
@property (weak, nonatomic) IBOutlet UIImageView *imageDraw;

@end

@implementation CutScreenController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    UIImage * image = [self.viewDraw drawView];
    self.imageDraw.image = image;
    
}
- (IBAction)onClickBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
