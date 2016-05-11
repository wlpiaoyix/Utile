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
#import "PYHook.h"
#import <objc/runtime.h>
#import "PYMotionListener.h"
#import "NSString+Expand.h"



@interface AppDelegate ()

@property (nonatomic) NSString * index;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *a = @"4.10";
    NSString * b = @"4.9.1";
    [a compareVersion:b];
    NSString * uuid = PYUUID(10);
//    [PYUtile soundWithPath:nil isShake:true];
//    [PYMotionListener instanceSingle];
//    [PYHook createClassImp];
    [PYHook mergeHookInstanceWithTarget:[self class] action:@selector(setIndex:) blockBefore:^BOOL(NSInvocation * _Nonnull invoction) {
        return true;
    } blockAfter:^(NSInvocation * _Nonnull invoction) {
        
    }];
    self.index = @"DD";
    
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

- (NSString *)analysisTokenWithURL:(NSURL *)url{
    NSString *str = [url absoluteString];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    
    NSArray *arr = [str componentsSeparatedByString:[NSString stringWithFormat:@"%@://",app_Name]];
    NSString *token = arr.lastObject;
    
    return [self decodeFromPercentEscapeString:token];
    
}
- (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@"" options:NSLiteralSearch                                   range:NSMakeRange(0,[outputStr length])];
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)
sourceApplication annotation:(id)annotation;{
    NSString *token = [self analysisTokenWithURL:url];
    return token != nil;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    return [self analysisTokenWithURL:url];
}




@end
