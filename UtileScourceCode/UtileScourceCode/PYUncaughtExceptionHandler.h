//
//  PYUncaughtExceptionHandler.h
//  UtileScourceCode
//
//  Created by wlpiaoyi on 16/5/6.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PYUncaughtExceptionHandler : NSObject{
    BOOL dismissed;
}
@end

void HandleException(NSException *exception);
void SignalHandler(int signal);

void InstallUncaughtExceptionHandler(void);
