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

static NSMutableDictionary * PYHookDictionary;
static NSString * PYHookDictionaryKeyClassName = @"name";
static NSString * PYHookDictionaryKeyHookMethodBlockBefore = @"befor";
static NSString * PYHookDictionaryKeyHookMethodBlockAfter = @"after";

SEL py_gethookSel(SEL action){
    return sel_getUid([NSString stringWithFormat:@"hook%s",sel_getName(action)].UTF8String);
}

@interface PYHook()
+(NSMutableDictionary<NSString *, id> * _Nullable) getHookInstanceWithTarget:(Class) target action:(SEL) action;
@end

@implementation NSObject(hook)

- (NSMethodSignature *)hookmethodSignatureForSelector:(SEL)aSelector{
    SEL selector = aSelector;
    if ([self respondsToSelector:aSelector]) {
        SEL hookSelector = py_gethookSel(aSelector);
        if ([self respondsToSelector:hookSelector]) {
            selector = hookSelector;
        }
    }
    return [self hookmethodSignatureForSelector:selector];
}
- (void) hookforwardInvocation:(NSInvocation *)anInvocation{
    SEL selector = py_gethookSel(anInvocation.selector);
    SEL orSelector = anInvocation.selector;
    
    anInvocation.target = self;
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
    @try {
        if (!blockBefore || (blockBefore && blockBefore(anInvocation))) {
            //retain 所有参数，防止参数被释放dealloc
            [anInvocation retainArguments];
            //消息调用
            [anInvocation invoke];
        }
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        if (blockAfter) {
            blockAfter(anInvocation);
        }
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
        
        
        const Method method = class_getInstanceMethod(target, action);
        const char * typeEncoding =  method_getTypeEncoding(method);
        IMP impPrevious = class_replaceMethod(target, action, _objc_msgForward, typeEncoding);
        
        const SEL hookAction = py_gethookSel(action);
        class_addMethod(target, hookAction, impPrevious, typeEncoding);

        if (!impPrevious) {//预防影响其他继承Class调用这个方法出问题
            
            Class superClass = class_getSuperclass(target);
            Method superMethod = class_getInstanceMethod(superClass, action);
            IMP superImp = method_getImplementation(superMethod);
            impPrevious = superImp;
            while(superClass && superImp == impPrevious) {
                
                impPrevious = superImp;
                
                superClass = class_getSuperclass(superClass);
                superMethod = class_getInstanceMethod(superClass, action);
                superImp = method_getImplementation(superMethod);
            }
            
            if (impPrevious) {
                class_addMethod(superClass, hookAction, impPrevious, typeEncoding);
            }
        }
        
        BOOL isSuccess = impPrevious ? true : false;
        if (isSuccess) {
            [self setHookInstance:dict target:target action:action];
        }else{
            class_replaceMethod(target, hookAction, _objc_msgForward, typeEncoding);
            class_replaceMethod(target, action, nil, typeEncoding);
        }
        
        return isSuccess;
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
        SEL hookAction = py_gethookSel(action);
        Method method1 = class_getInstanceMethod(target, action);
        Method method2 = class_getInstanceMethod(target, hookAction);
        method_exchangeImplementations(method1, method2);
        class_replaceMethod(target, hookAction, _objc_msgForward, method_getTypeEncoding(method2));
    }
    return true;
}


+(BOOL) mergeHookClassWithTarget:(Class)target action:(SEL)action blockBefore:(BOOL (^)(NSInvocation *))blockBefore blockAfter:(void (^)(NSInvocation *))blockAfter{
    Method method = class_getClassMethod(target, action);
    const char * typeEncoding =  method_getTypeEncoding(method);
    
    return true;
}
+(BOOL) removeHookClassWithTarget:(Class)target action:(SEL)action{
    
    return true;
}
+(NSString *) getEncodeName:(char *) encode{
    NSString * encodeName = nil;
    if (strcmp(encode, @encode(void))  == 0) {
        encodeName = @"viod";
    }else if (strcmp(encode, @encode(id))  == 0){
        encodeName = @"id";
    }else if (strcmp(encode, @encode(BOOL))  == 0){
        encodeName = @"BOOL";
//    }else if (strcmp(encode, @encode(short))  == 0){
//        encodeName = @"short";
//    }else if (strcmp(encode, @encode(int))  == 0){
//        encodeName = @"int";
//    }else if (strcmp(encode, @encode(long))  == 0){
//        encodeName = @"long";
//    }else if (strcmp(encode, @encode(float))  == 0){
//        encodeName = @"float";
    }else if (strcmp(encode, @encode(double))  == 0
              || strcmp(encode, @encode(float))  == 0
              || strcmp(encode, @encode(long))  == 0
              || strcmp(encode, @encode(int))  == 0
              || strcmp(encode, @encode(short))  == 0
              || strcmp(encode, @encode(long long int))  == 0
              || strcmp(encode, @encode(char))  == 0){
        encodeName = @"double";
//    }else if (strcmp(encode, @encode(char))  == 0){
//        encodeName = @"char";
//    }else if (strcmp(encode, @encode(char *))  == 0){
//        encodeName = @"char *";
//    }else if (strcmp(encode, @encode(void *))  == 0){
//        encodeName = @"void *";
    }else if (strcmp(encode, @encode(SEL))  == 0){
        encodeName = @"SEL";
    }else if (strcmp(encode, @encode(CGRect))  == 0){
        encodeName = @"CGRect";
    }else if (strcmp(encode, @encode(CGSize))  == 0){
        encodeName = @"CGSize";
    }else if (strcmp(encode, @encode(CGPoint))  == 0){
        encodeName = @"CGPoint";
    }
    return encodeName;
}
+(NSArray<NSString*> *) getAllEncodes{
    NSUInteger length = 8;
    char * types[8] = {
        @encode(void),
        @encode(id),
        @encode(BOOL),
        @encode(double),
        @encode(SEL),
        @encode(CGRect),
        @encode(CGPoint),
        @encode(CGSize)
    };
    NSMutableArray<NSString *> * allEncodes = [NSMutableArray<NSString*> new];
    for (NSUInteger index = 0; index < length; index++){
        NSString *encodeName = [self getEncodeName:types[index]];
        [allEncodes addObject:encodeName];
    }
    return [NSArray<NSString*> arrayWithArray:allEncodes];
}
+(void) addMethodParams:(NSMutableArray<NSArray *> *) methodResources methodResource:(NSMutableArray<NSString *> *) methodResource deep:(int) deep maxDeep:(const int) maxDeep{
    
    if (maxDeep <= deep - 2) {
        [methodResources addObject:methodResource];
        return;
    }
    
    deep++;
    
    NSArray<NSString *> * allEncodes = [self getAllEncodes];
    BOOL isFirst = true;
    for (NSString *encode in allEncodes) {
        if (isFirst) {
            isFirst = false;
            continue;
        }
        NSMutableArray<NSString *> * _methodResource = [NSMutableArray<NSString *> arrayWithArray:methodResource];
        [_methodResource addObject:encode];
        [self addMethodParams:methodResources methodResource:_methodResource deep:deep maxDeep:maxDeep];
    }
}
+(nonnull NSArray<NSString *> *) createClassImp{
    
    NSMutableArray<NSArray *> * methodResources = [NSMutableArray<NSArray *> new];
    NSArray<NSString *> * allEncodes = [self getAllEncodes];
    for (NSString *encodeName in allEncodes) {
        
        NSMutableArray<NSString *> * methodResource = [NSMutableArray<NSString *> arrayWithObject:encodeName];
        for (NSUInteger index = 0; index < 4; index ++) {
            const int maxDeep = (int)index;
            int deep = 2;
            [self addMethodParams:methodResources methodResource:methodResource deep:deep maxDeep:maxDeep];
        }
    }
    
    NSString * headChars = @"py_hook_";
    NSString * paramChars = @"imp(id target, SEL action";
    NSString * tailChars = @"){}\n";
    NSMutableArray<NSString *> * methodResourceArgs = [NSMutableArray<NSString *> new];
    for (NSArray<NSString *> *methodResource in methodResources) {
        NSMutableString *arg = [NSMutableString stringWithFormat:@"%@ %@",methodResource.firstObject, headChars];
        BOOL isFist = true;
        for (NSString *encode in methodResource) {
            if (isFist) {
                isFist = false;
                continue;
            }
            [arg appendFormat:@"%@_",encode];
        }
        [arg appendString:paramChars];
        isFist = true;
        NSInteger index = 0;
        for (NSString *encode in methodResource) {
            if (isFist) {
                isFist = false;
                continue;
            }
            [arg appendFormat:@", %@ param%d",encode ,index];
            index++;
        }
        [arg appendString:tailChars];
        [methodResourceArgs addObject:arg];
    }
    return methodResourceArgs;
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