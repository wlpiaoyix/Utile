//
//  OrientationsListener.m
//  UtileScourceCode
//
//  Created by wlpiaoyi on 16/1/18.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "PYOrientationListener.h"

static PYOrientationListener *xPYOrientationListener;

@interface PYOrientationListener()
@property (nonatomic,strong) NSHashTable<id<PYOrientationListener>> *tableListeners;
@end

@implementation PYOrientationListener
+(nonnull instancetype) instanceSingle{
    @synchronized(self) {
        if (!xPYOrientationListener) {
            xPYOrientationListener = [PYOrientationListener new];
        }
    }
    return xPYOrientationListener;
}

-(id) init{
    if(self=[super init]){
        self.duration = 0.65100300312042236;
        self.tableListeners = [NSHashTable<id<PYOrientationListener>> weakObjectsHashTable];
        UIDevice *device = [UIDevice currentDevice]; //Get the device object
        [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:device];//Get the notification centre for the app
    }
    return self;
}
/**
 旋转当前装置
 */
-(void) attemptRotationToDeviceOrientation:(UIDeviceOrientation) deviceOrientation completion:(void (^)(void)) completion{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        _orientation = deviceOrientation;
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = deviceOrientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
        [UIViewController attemptRotationToDeviceOrientation];//这句是关键
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [NSThread sleepForTimeInterval:self.duration];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion();
                }
            });
            
        });
    }
}
/**
 是否支持旋转到当前方向
 */
-(BOOL) isSupportOrientation:(UIDeviceOrientation) _orientation_{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    if (vc && [vc isKindOfClass:[UINavigationController class]]) {
        vc = [((UINavigationController*)vc).viewControllers count] > 0 ? ((UINavigationController*)vc).viewControllers.lastObject : nil;
    }
    
    if (!vc) {
        return false;
    }
    
    UIInterfaceOrientationMask  supportedOrientations=  [vc supportedInterfaceOrientations];
    NSInteger all = supportedOrientations;
    NSInteger cur = 1 << (NSInteger)_orientation_;
    if (!(all&cur)) {
        return false;
    }
    supportedOrientations = [vc supportedInterfaceOrientations];
    all = supportedOrientations;
    if (!(all&cur)) {
        return false;
    }
    return true;
}
-(void) addListener:(id<PYOrientationListener>) listener{
    @synchronized(self.tableListeners){
        if ([self.tableListeners containsObject:listener]) {
            return;
        }
        [self.tableListeners addObject:listener];
    }
}
-(void) removeListenser:(id<PYOrientationListener>) listener{
    @synchronized(self.tableListeners){
        [self.tableListeners removeObject:listener];
    }
}


- (void)orientationChanged:(NSNotification *)note{
    @synchronized(self.tableListeners){
        UIDeviceOrientation _orientation_ = [[UIDevice currentDevice] orientation];
        BOOL isSupportOrientation = [self isSupportOrientation:_orientation_];
        _orientation  = _orientation_;
        for (id<PYOrientationListener> listener in self.tableListeners) {
            if (isSupportOrientation) {
                switch (_orientation) {
                        // Device oriented vertically, home button on the bottom
                    case UIDeviceOrientationPortrait:{
                        if([listener respondsToSelector:@selector(deviceOrientationPortrait)])[listener deviceOrientationPortrait];
                    }
                        break;
                        // Device oriented vertically, home button on the top
                    case UIDeviceOrientationPortraitUpsideDown:{
                        if([listener respondsToSelector:@selector(deviceOrientationPortraitUpsideDown)])[listener deviceOrientationPortraitUpsideDown];
                    }
                        break;
                        // Device oriented horizontally, home button on the right
                    case UIDeviceOrientationLandscapeLeft:{
                        if([listener respondsToSelector:@selector(deviceOrientationLandscapeLeft)])[listener deviceOrientationLandscapeLeft];
                    }
                        break;
                        // Device oriented horizontally, home button on the left
                    case UIDeviceOrientationLandscapeRight:{
                        if([listener respondsToSelector:@selector(deviceOrientationLandscapeRight)])[listener deviceOrientationLandscapeRight];
                    }
                        break;
                    default:{
                    }
                        break;
                }
            }else{
                if([listener respondsToSelector:@selector(deviceOrientationNotSupport:)])[listener deviceOrientationNotSupport:_orientation_];
            }
        }
    }
}

-(void) dealloc{
    [self.tableListeners removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
