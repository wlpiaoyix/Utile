//
//  ViewController.m
//  UtileTest
//
//  Created by wlpiaoyi on 15/10/22.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "ViewController.h"
#import <Utile/Utile.Framework.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController
- (IBAction)hiddenKeyboard:(id)sender {
    [PYKeyboardNotification hiddenKeyboard];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakself = self;
    [PYKeyboardNotification setKeyboardNotificationWithResponder:self.textField start:^(CGRect keyBoardFrame) {
        CGRect r = weakself.view.frame;
        r.origin.y = -keyBoardFrame.size.height;
        weakself.view.frame = r;
    } end:^(CGRect keyBoardFrame) {
        CGRect r = weakself.view.frame;
        r.origin.y = 0;
        weakself.view.frame = r;
    }];
    [PYKeyboardNotification setKeyboardNotificationWithResponder:self.textField completionStart:^{
        weakself.textField.text = (NSString*)documentDir;
    } completionEnd:^{
        weakself.textField.text = @"";
    }];
}
- (IBAction)onClickProgress:(id)sender {
    [[NSDate date] dateFormateDate:nil];
    [PYUtile showProgress:nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSThread sleepForTimeInterval:3.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            [PYUtile hiddenProgress];
        });
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
