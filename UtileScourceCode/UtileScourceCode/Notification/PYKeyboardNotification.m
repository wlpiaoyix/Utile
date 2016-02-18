//
//  PYKeyboardNotification.m
//  UtileScourceCode
//
//  Created by wlpiaoyi on 15/10/23.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "PYKeyboardNotification.h"
#import "PYReflect.h"
#import "EXTScope.h"
#import <objc/runtime.h>

@protocol PYNOtifactionProtocolTag <NSObject>@end

NSMapTable<NSNumber*, NSMutableDictionary*> *PYNotifactionTableBlock;

const NSString * PYNotifactionTableKeyResponder = @"asd";

const NSString * PYNotifactionTableKeyBlockStart = @"dfkjhj";
const NSString * PYNotifactionTableKeyBlockEnd = @"dfkj";
const NSString * PYNotifactionTableKeyBlockCompletionStart = @"dfkjsdj";
const NSString * PYNotifactionTableKeyBlockCompletionEnd = @"dfkjdf";

void hook_dealloc(UIResponder *responder, SEL action){
    [PYKeyboardNotification hiddenKeyboard];
    [PYKeyboardNotification removeKeyboardNotificationWithResponder:responder];
    SEL hook = sel_getUid("hook_dealloc");
    if ([responder respondsToSelector:hook]) {
        [PYReflect invoke:responder action:hook returnValue:nil params:nil];
    }
}


@interface PYKeyboardNotification()
@end

@implementation PYKeyboardNotification
+(void) initialize{
    NSMapTable<NSNumber*, NSMutableDictionary*> *tableBlock  = [NSMapTable<NSNumber*, NSMutableDictionary*> strongToStrongObjectsMapTable];
    PYNotifactionTableBlock = tableBlock;
}
+(BOOL)setKeyboardNotificationWithResponder:(nonnull UIResponder*) responder start:(nonnull BlockKeyboardAnimatedDoing) blockStart end:(nonnull BlockKeyboardAnimatedDoing) blockEnd{
    if (![responder isKindOfClass:[UIResponder class]]) {
        return false;
    }
    [self hookResponder:responder];
    @synchronized(PYNotifactionTableBlock) {
    
        NSNumber *key  = [self getKeyWithResponder:responder];
        NSMutableDictionary *dic = [PYNotifactionTableBlock objectForKey:key];
        if (!dic) {
            dic = [NSMutableDictionary new];
            SEL selInputShow = @selector(inputshow:);
            SEL selInputHidden = @selector(inputhidden:);
            [[NSNotificationCenter defaultCenter]addObserver:responder selector:selInputShow name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter]addObserver:responder selector: selInputHidden name: UIKeyboardWillHideNotification object:nil];
        }
        [dic addEntriesFromDictionary:@{
                             PYNotifactionTableKeyBlockStart:blockStart,
                             PYNotifactionTableKeyBlockEnd:blockEnd
                             } ];
        [PYNotifactionTableBlock setObject:dic forKey:key];
    }
    return true;
}
/**
 键盘监听事件添加
 @responder 输入源
 @blockCompletionStart 键盘显示完成回调
 @blockCompletionEnd 键盘隐藏完成回调
 */
+(BOOL)setKeyboardNotificationWithResponder:(nonnull UIResponder*) responder completionStart:(nonnull BlockKeyboardAnimatedCompletion) blockCompletionStart completionEnd:(nonnull BlockKeyboardAnimatedCompletion) blockCompletionEnd{
    if (![responder isKindOfClass:[UIResponder class]]) {
        return false;
    }
    [self hookResponder:responder];
    @synchronized(PYNotifactionTableBlock) {
        
        NSNumber *key  = [self getKeyWithResponder:responder];
        NSMutableDictionary *dic = [PYNotifactionTableBlock objectForKey:key];
        if (!dic) {
            dic = [NSMutableDictionary new];
            SEL selInputShow = @selector(inputshow:);
            SEL selInputHidden = @selector(inputhidden:);
            [[NSNotificationCenter defaultCenter]addObserver:responder selector:selInputShow name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter]addObserver:responder selector: selInputHidden name: UIKeyboardWillHideNotification object:nil];
        }
        [dic addEntriesFromDictionary:@{
                             PYNotifactionTableKeyBlockCompletionStart:blockCompletionStart,
                             PYNotifactionTableKeyBlockCompletionEnd:blockCompletionEnd
                             }];
        [PYNotifactionTableBlock setObject:dic forKey:key];
    }
    return true;
}
+(BOOL) removeKeyboardNotificationWithResponder:(nonnull UIResponder*) responder{
    @synchronized(PYNotifactionTableBlock) {
        NSNumber *key  = [self getKeyWithResponder:responder];
        [PYNotifactionTableBlock removeObjectForKey:key];
        [[NSNotificationCenter defaultCenter] removeObserver:responder name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:responder name:UIKeyboardWillHideNotification object:nil];
    }
    return true;
}
+(BOOL) hiddenKeyboard{
   return  [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}



-(void)inputshow:(NSNotification *)notification{
    if (![self isKindOfClass:[UIResponder class]]) {
        return;
    }
    UIResponder *responder = (UIResponder*)self;
    NSNumber *key  = [PYKeyboardNotification getKeyWithResponder:responder];
    
    BlockKeyboardAnimatedDoing block = [[PYNotifactionTableBlock objectForKey:key] objectForKey:PYNotifactionTableKeyBlockStart];
    BlockKeyboardAnimatedCompletion completionBlock = [[PYNotifactionTableBlock objectForKey:key] objectForKey:PYNotifactionTableKeyBlockCompletionStart];
    if (!block && !completionBlock ) {
        return;
    }
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    __block CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (keyBoardFrame.size.height == 0) {
        return;
    }
    
    @unsafeify(block);
    @unsafeify(completionBlock);
    [UIView animateWithDuration:animationTime>0?animationTime:0.25 animations:^{
        @strongify(block);
        if (block) {
            block(keyBoardFrame);
        }
    } completion:^(BOOL finished) {
        @strongify(completionBlock);
        if (completionBlock) {
            completionBlock();
        }
    }];
    
    
}

-(void)inputhidden:(NSNotification *)notification{
    if (![self isKindOfClass:[UIResponder class]]) {
        return;
    }
    UIResponder *responder = (UIResponder*)self;
    NSNumber *key  = [PYKeyboardNotification getKeyWithResponder:responder];
    __block BlockKeyboardAnimatedDoing block = [[PYNotifactionTableBlock objectForKey:key] objectForKey:PYNotifactionTableKeyBlockEnd];
    __block BlockKeyboardAnimatedCompletion completionBlock = [[PYNotifactionTableBlock objectForKey:key] objectForKey:PYNotifactionTableKeyBlockCompletionEnd];
    if (!block && !completionBlock) {
        return;
    }
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    __block CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (keyBoardFrame.size.height == 0) {
        return;
    }
    
    @unsafeify(block);
    @unsafeify(completionBlock);
    [UIView animateWithDuration:animationTime>0?animationTime:0.25 animations:^{
        @strongify(block);
        if (block) {
            block(keyBoardFrame);
        }
    } completion:^(BOOL finished) {
        @strongify(completionBlock);
        if (completionBlock) {
            completionBlock();
        }
    }];
    
}
+(void) hookResponder:(UIResponder*) responder{
    @synchronized(responder) {
        SEL selInputShow = @selector(inputshow:);
        SEL selInputHidden = @selector(inputhidden:);
        if (![responder conformsToProtocol:@protocol(PYNOtifactionProtocolTag)]) {
            SEL deallocSEL = sel_getUid("dealloc");
            SEL hookDeallocSEL = sel_getUid("hook_dealloc");
            Method orgm = class_getInstanceMethod([responder class], deallocSEL);
            const char * typeEncoding = method_getTypeEncoding(orgm);
            IMP hookDeallocImp = (IMP)hook_dealloc;
            class_addMethod([responder class], hookDeallocSEL, hookDeallocImp, typeEncoding);
            Method hookm = class_getInstanceMethod([responder class], hookDeallocSEL);
            method_exchangeImplementations(orgm, hookm);
            
            Method mInputShow = class_getInstanceMethod(self, selInputShow);
            Method mInputHidden = class_getInstanceMethod(self, selInputHidden);
            class_addMethod(responder.class, selInputShow, method_getImplementation(mInputShow), method_getTypeEncoding(mInputShow));
            class_addMethod(responder.class, selInputHidden, method_getImplementation(mInputHidden), method_getTypeEncoding(mInputHidden));
            class_addProtocol(responder.class, @protocol(PYNOtifactionProtocolTag));
        }
    }
}
+(NSNumber*) getKeyWithResponder:(UIResponder*) responder{
    return @(responder.hash);
}

@end
