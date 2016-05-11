//
//  QRCodeController.m
//  UtileScourceCode
//
//  Created by wlpiaoyi on 16/4/26.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "QRCodeController.h"
#import "UIImage+Expand.h"

@interface QRCodeController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation QRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = [UIImage imageWithQRCode:@"IEYadIDHDH" size:400];
    
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
