//
//  NSObejct+Expand.m
//  UtileScourceCode
//
//  Created by wlpiaoyi on 15/11/5.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "NSObject+Expand.h"
#import "PYReflect.h"
#import <objc/runtime.h>

@implementation NSObject(toDictionary)
/**
 通过JSON初始化对象
 */
+(instancetype) objectWithDictionary:(NSDictionary*) dictionary{
    return [self objectWithDictionary:dictionary clazz:self];
}
/**
 通过JSON初始化对象
 */
+(id) objectWithDictionary:(NSDictionary*) dictionary clazz:(Class) clazz{
    id target = [[clazz alloc] init];
    if (target) {
        for (NSString *propertyName in [dictionary allKeys]) {
            NSString *setMethodName = [NSString stringWithFormat:@"set%@%@:",[[propertyName substringToIndex:1] uppercaseString],[propertyName substringFromIndex:1]];
            SEL setSel = sel_getUid([setMethodName UTF8String]);
            if(![target respondsToSelector:setSel]){
                NSLog(@"has no set name with:%@ in %@",setMethodName, NSStringFromClass([target class]));
                continue;
            }
            
            id propertyValue = dictionary[propertyName];
            if (propertyValue == nil || propertyValue == [NSNull null]) {
                continue;
            }
            
            NSInvocation *invocaton = [PYReflect startInvoke:target action:setSel];
            const char * encode = [invocaton.methodSignature getArgumentTypeAtIndex:2];
            
            if(strcasecmp(encode, @encode(int)) == 0){
                int v = [propertyValue intValue];
                [PYReflect setInvoke:&v index:2 invocation:invocaton];
            }else if(strcasecmp(encode, @encode(long)) == 0){
                long v = [propertyValue longValue];
                [PYReflect setInvoke:&v index:2 invocation:invocaton];
            }else if(strcasecmp(encode, @encode(long long)) == 0){
                long long v = [propertyValue longLongValue];
                [PYReflect setInvoke:&v index:2 invocation:invocaton];
            }else if(strcasecmp(encode, @encode(bool)) == 0){
                bool v = [propertyValue boolValue];
                [PYReflect setInvoke:&v index:2 invocation:invocaton];
            }else if(strcasecmp(encode, @encode(float)) == 0){
                float v = [propertyValue floatValue];
                [PYReflect setInvoke:&v index:2 invocation:invocaton];
            }else if(strcasecmp(encode, @encode(double)) == 0){
                double v = [propertyValue doubleValue];
                [PYReflect setInvoke:&v index:2 invocation:invocaton];
            }else if(strcasecmp(encode, @encode(short)) == 0){
                short v = [propertyValue shortValue];
                [PYReflect setInvoke:&v index:2 invocation:invocaton];
            }else if(strcasecmp(encode, @encode(char)) == 0){
                char v = [propertyValue charValue];
                [PYReflect setInvoke:&v index:2 invocation:invocaton];
            }else{
                if ([propertyValue isKindOfClass:[NSNumber class]]) {
                    propertyValue =  ((NSNumber*)propertyValue).stringValue;
                }
                [PYReflect setInvoke:&propertyValue index:2 invocation:invocaton];
            }
            [PYReflect excuInvoke:nil returnType:nil invocation:invocaton];
        }
    }
    return target;
}
/**
 通过对象生成JSON
 */
-(NSDictionary*) objectToDictionary{
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    __weak id obejct = self;
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    @try {
        static NSDictionary *PYObjectSuperPropertNameDic = nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            PYObjectSuperPropertNameDic = @{@"hash":@YES,@"superclass":@YES,@"description":@YES,@"debugDescription":@YES};
        });
        for (int i = 0; i < outCount; i++) {
            
            objc_property_t property = properties[i];
            NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            
            if (PYObjectSuperPropertNameDic[propertyName]) {
                continue;
            }
            
            SEL getSel = sel_getUid([propertyName UTF8String]);
            if(![obejct respondsToSelector:getSel]){
                NSLog(@"has no get name with:%@ in %@",propertyName, NSStringFromClass([obejct class]));
                continue;
            }
            
            NSInvocation *invocaton = [PYReflect startInvoke:obejct action:getSel];
            const char * encode = invocaton.methodSignature.methodReturnType;
            
            id returnValue;
            if(strcasecmp(encode, @encode(int)) == 0){
                int v;
                [PYReflect excuInvoke:&v returnType:nil invocation:invocaton];
                returnValue = [NSNumber numberWithInt:v];
            }else if(strcasecmp(encode, @encode(long)) == 0){
                long v;
                [PYReflect excuInvoke:&v returnType:nil invocation:invocaton];
                returnValue = [NSNumber numberWithLong:v];
            }else if(strcasecmp(encode, @encode(long long)) == 0){
                long long v;
                [PYReflect excuInvoke:&v returnType:nil invocation:invocaton];
                returnValue = [NSNumber numberWithLongLong:v];
            }else if(strcasecmp(encode, @encode(bool)) == 0){
                bool v;
                [PYReflect excuInvoke:&v returnType:nil invocation:invocaton];
                returnValue = [NSNumber numberWithBool:v];
            }else if(strcasecmp(encode, @encode(float)) == 0){
                float v;
                [PYReflect excuInvoke:&v returnType:nil invocation:invocaton];
                returnValue = [NSNumber numberWithFloat:v];
            }else if(strcasecmp(encode, @encode(double)) == 0){
                double v;
                [PYReflect excuInvoke:&v returnType:nil invocation:invocaton];
                returnValue = [NSNumber numberWithDouble:v];
            }else if(strcasecmp(encode, @encode(short)) == 0){
                short v;
                [PYReflect excuInvoke:&v returnType:nil invocation:invocaton];
                returnValue = [NSNumber numberWithShort:v];
            }else if(strcasecmp(encode, @encode(char)) == 0){
                char v;
                [PYReflect excuInvoke:&v returnType:nil invocation:invocaton];
                returnValue = [NSNumber numberWithChar:v];
            }else{
                void * v;
                [PYReflect excuInvoke:&v returnType:nil invocation:invocaton];
                returnValue = (__bridge id)v;
            }
            if(!returnValue){
                continue;
            }
            if (returnValue) {
                [dict setObject:returnValue forKey:propertyName];
            }
        }
    }
    @finally {
        free(properties);
    }
    return dict;
}

@end
