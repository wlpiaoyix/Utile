//
//  PYHook.m
//  UtileScourceCode
//
//  Created by wlpiaoyi on 15/12/14.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "PYHook.h"
#import "PYUtile.h"
#import "EXTScope.h"
#import "PYReflect.h"
#import <objc/runtime.h>
#import <objc/message.h>
@interface PYHook()
+(NSMutableDictionary<NSString *, id> * _Nullable) getHookInstanceWithTarget:(Class) target action:(SEL) action;
@end


NSMutableDictionary * PYHookDictionary;
NSString * PYHookDictionaryKeyClassName = @"name";
NSString * PYHookDictionaryKeyHookMethodBlockBefore = @"befor";
NSString * PYHookDictionaryKeyHookMethodBlockAfter = @"after";
SEL py_gethookSel(SEL action){
    return sel_getUid([NSString stringWithFormat:@"hook%s",sel_getName(action)].UTF8String);
}

@implementation NSObject(hook)

- (NSMethodSignature *)hookmethodSignatureForSelector:(SEL)aSelector{
    SEL selector = aSelector;
    if ([self respondsToSelector:aSelector]) {
        selector = py_gethookSel(aSelector);
    }
    return [self hookmethodSignatureForSelector:selector];
}
- (void) hookforwardInvocation:(NSInvocation *)anInvocation{
    SEL selector = py_gethookSel(anInvocation.selector);
    SEL orSelector = anInvocation.selector;
    if ([self respondsToSelector:selector]) {
        anInvocation.selector = selector;
    }else{
        [self hookforwardInvocation:anInvocation];
        return;
    }
    
    BOOL (^blockBefore) (NSInvocation * invoction);
    void (^blockAfter) (NSInvocation * invoction);
    NSDictionary *dict;
    dict = [PYHook getHookInstanceWithTarget:[self class] action:orSelector];
    blockBefore = dict[PYHookDictionaryKeyHookMethodBlockBefore];
    blockAfter = dict[PYHookDictionaryKeyHookMethodBlockAfter];
    if (!blockBefore || (blockBefore && blockBefore(anInvocation))) {
        //retain 所有参数，防止参数被释放dealloc
        [anInvocation retainArguments];
        //消息调用
        [anInvocation invoke];
    }
    if (blockAfter) {
        blockAfter(anInvocation);
    }
}

@end


@implementation PYHook{
    

}
+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PYHookDictionary = [NSMutableDictionary new];
        NSArray<NSString *> *methodNames =
        @[
          @"methodSignatureForSelector:",
          @"forwardInvocation:"
          ];
        for (NSString *methodName in methodNames) {
            Method m1 = class_getInstanceMethod([NSObject class], sel_getUid(methodName.UTF8String));
            Method m2 = class_getInstanceMethod([NSObject class], sel_getUid([NSString stringWithFormat:@"hook%@",methodName].UTF8String));
            if (!m1 || !m2) {
                NSLog(@"the method[%@] has failed hook", methodName);
                continue;
            }
            method_exchangeImplementations(m1, m2);
        }
    });
}

+ (BOOL) mergeHookInstanceWithTarget:(Class) target action:(SEL) action blockBefore:(BOOL (^) (NSInvocation * invoction)) blockBefore blockAfter:(void (^) (NSInvocation * invoction)) blockAfter{
    @synchronized(target) {
        [self removeHookInstanceWithTarget:target action:action];
        NSMutableDictionary *dict = [self getHookInstanceWithTarget:target action:action];
        if (!dict) {
            dict = [NSMutableDictionary new];
        }
        if (blockBefore) {
            dict[PYHookDictionaryKeyHookMethodBlockBefore] = blockBefore;
        }
        if (blockAfter) {
            dict[PYHookDictionaryKeyHookMethodBlockAfter] = blockAfter;
        }
        
        
        Method method = class_getInstanceMethod(target, action);
        const char * typeEncoding =  method_getTypeEncoding(method);
        
        IMP impPrevious = class_replaceMethod(target, action, _objc_msgForward, typeEncoding);
        
        SEL hooksel = py_gethookSel(action);
        class_addMethod(target, hooksel, impPrevious, typeEncoding);
        
        [self setHookInstance:dict target:target action:action];
        
        return impPrevious ? true : false;
    }
}

+(BOOL) removeHookInstanceWithTarget:(Class) target action:(SEL) action{
    @synchronized(target) {
        NSString *key = [self getHookInstanceKeyWithTarget:target action:action];
        NSDictionary<NSString *, id> * dict = PYHookDictionary[key];
        if (dict) {
            [PYHookDictionary removeObjectForKey:key];
        }else{
            return false;
        }
        
        Method method1 = class_getInstanceMethod(target, action);
        Method method2 = class_getInstanceMethod(target, py_gethookSel(action));
        method_exchangeImplementations(method1, method2);
        class_replaceMethod(target, py_gethookSel(action), _objc_msgForward, method_getTypeEncoding(method2));
    }
    return true;
}

+(void) setHookInstance:(NSMutableDictionary<NSString *, id> * _Nullable) dict target:(Class) target action:(SEL) action{
    PYHookDictionary[[self getHookInstanceKeyWithTarget:target action:action]] = dict;
}

+(NSMutableDictionary<NSString *, id> * _Nullable) getHookInstanceWithTarget:(Class) target action:(SEL) action{
    NSMutableDictionary<NSString *, id> * dict = PYHookDictionary[[self getHookInstanceKeyWithTarget:target action:action]];
    return dict;
}

+(NSString * _Nonnull) getHookInstanceKeyWithTarget:(Class) target action:(SEL) action{
    return [NSString stringWithFormat:@"instance[%@][%s]",NSStringFromClass(target), sel_getName(action)];
}

@end

//    va_list argumentList;
//    va_start(argumentList, params);
//    for (NSUInteger index = 2; index < invoction.methodSignature.numberOfArguments; index++) {
//    }
//    va_end(argumentList);