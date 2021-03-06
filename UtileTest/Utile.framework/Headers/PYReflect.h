//
//  PYReflect.h
//  RunTime
//
//  Created by wlpiaoyi on 15/7/6.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol PYInvoke<NSObject>
//==>分布执行方法
+ (nullable id) startInvoke:(nonnull id) target action:(nonnull SEL)action;
+ (void) setInvoke:(nullable void*) param index:(NSInteger) index invocation:(nonnull const id) invocation;
+ (void) excuInvoke:(nullable void*)returnValue returnType:(char * _Nullable * _Nullable) returnType invocation:(nonnull const id) invocation;
//<==
//单步执行反射方法
+ (void) invoke:(nonnull id) target action:(nonnull SEL)action returnValue:(nullable void*) returnValue params:(nullable void*) param,...NS_REQUIRES_NIL_TERMINATION;
@end
@protocol PYReflect<NSObject>
/**
 获取指定成员属性描述
 */
+(nonnull NSDictionary*) getPropertyInfoWithClass:(nonnull Class) clazz propertyName:(nonnull NSString*) propertyName;
/**
 获取所有成员属性描述
 */
+(nonnull NSArray<NSDictionary*>*) getPropertyInfosWithClass:(nonnull Class) clazz;
/**
 获取指定实例方法描述
 */
+(nonnull NSDictionary*) getInstanceMethodWithClass:(nonnull Class) clazz selUid:(nonnull SEL) selUid;
/**
 获取指定静态方法描述
 */
+(nonnull NSDictionary*) getClassMethodWithClass:(nonnull Class) clazz selUid:(nonnull SEL) selUid;
/**
 获取所有的方法信息
 */
+(nonnull NSArray<NSDictionary*>*) getInstanceMethodInfosWithClass:(nonnull Class) clazz;
@end

@interface PYReflect : NSObject<PYInvoke,PYReflect>
@end
