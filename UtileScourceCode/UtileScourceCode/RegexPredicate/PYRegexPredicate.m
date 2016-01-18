//
//  RegexPredicate.m
//  Common
//
//  Created by wlpiaoyi on 14/12/31.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "PYRegexPredicate.h"


NSString * REGEX_HOMEHONE = @"^((\\d{2,4}\\-){0,1}\\d{7,9})$";
NSString * REGEX_MOBILEPHONE = @"^(\\+(\\d{2})){0,1}((13)|(14)|(15)|(18)|(17))\\d{9}$";
NSString * REGEX_INTEGER = @"^\\d{1,}$";
NSString * REGEX_FLOAT = @"^\\d{1,}\\.{1}\\d{1,}$";
NSString * REGEX_EMAIL = @"^([a-zA-Z0-9_\\.\\-])+\\@(([a-zA-Z0-9\\-])+\\.)+([a-zA-Z0-9]{2,4})+$";
//身份证正则表达式(15位)
NSString * REGEX_IDCARD15 = @"^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$";
//身份证正则表达式(18位)
NSString * REGEX_IDCARD18 = @"^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{4}$";
//港澳通行证
NSString * REGEX_HKMACCARD = @"^([a-zA-Z]\\d{8})$";
//台湾通行证
NSString * REGEX_TWCARD = @"^[a-zA-Z0-9]{1,20}$";
//护照
NSString * REGEX_PASSPORT = @"^[A-Z\\d]{5,30}$";
@implementation PYRegexPredicate

/**
 整数
 */
+(BOOL) matchInteger:(NSString*) arg{
    return [self matchArg:arg regex:REGEX_INTEGER];
}
/**
 小数
 */
+(BOOL) matchFloat:(NSString*) arg{
    return [self matchArg:arg regex:REGEX_FLOAT];
}
/**
 手机号码
 */
+(BOOL) matchMobliePhone:(NSString*) arg{
    return [self matchArg:arg regex:REGEX_MOBILEPHONE];
}
/**
 座机号码
 */
+(BOOL) matchHomePhone:(NSString*) arg{
    return [self matchArg:arg regex:REGEX_HOMEHONE];
}
/**
 邮箱
 */
+(BOOL) matchEmail:(NSString*) arg{
    return [self matchArg:arg regex:REGEX_EMAIL];
}
/**
 身份证
 */
+(BOOL) matchIDCard:(NSString*) arg{
    return [self matchArg:arg regex:REGEX_IDCARD15] || [self matchArg:arg regex:REGEX_IDCARD18];
}
/**
 港澳通行证
 */
+(BOOL) matchHkMacCard:(NSString*) arg{
    return [self matchArg:arg regex:REGEX_HKMACCARD];
}
/**
 台湾通行证
 */
+(BOOL) matchTWCard:(NSString*) arg{
    return [self matchArg:arg regex:REGEX_TWCARD];
}
/**
 护照
 */
+(BOOL) matchPassport:(NSString*) arg{
    return [self matchArg:arg regex:REGEX_PASSPORT];
}

+(BOOL) matchArg:(NSString*) arg regex:(NSString*) regex{
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:arg];
}
@end
