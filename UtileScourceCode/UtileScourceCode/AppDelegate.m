//
//  AppDelegate.m
//  UtileScourceCode
//
//  Created by wlpiaoyi on 15/10/21.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "AppDelegate.h"
#import "PYReflect.h"
#import "NSDate+Expand.h"
#import "PYUtile.h"
#import "NSDictionary+Expand.h"
#import "NSData+Expand.h"
#import "PYHttpRequest.h"
#import "PYHook.h"
#import <objc/runtime.h>



@interface AppDelegate ()

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

//    NSDate *date = [NSDate date];
//    date = [date setCompentsWithBinary:0b100011];
//    
//    PYHttpRequest *requst = [PYHttpRequest new];
//    [[[requst setBlockSuccess:^(int status, id _Nullable data, id<PYHttpRequest>  _Nonnull target) {
//        NSString *arg = [data toString];
//        NSLog(arg);
//    }] setBlockFaild:^(int status, id  _Nullable data, id<PYHttpRequest>  _Nonnull target) {
//        NSLog(@"");
//    }] requestGet:@"http://www.baidu.com" params:nil];
    
//    NSDictionary *info = [PYUtile getInfoPlistWithName:@"Info"];
//    CGRect r;
//    char *type;
//    id inocke = [PYReflect startInvoke:self action:@selector(getRect)];
//    [PYReflect excuInvoke:&r returnType:&type invocation:inocke];
//    NSArray *a = [PYReflect getInstanceMethodInfosWithClass:self.class];
//    [PYReflect getInstanceMethodWithClass:self.class selUid:@selector(application:didFinishLaunchingWithOptions:)];
//    NSString *kk = [[NSDate date] dateFormateDate:@"EE"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
