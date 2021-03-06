//
//  NSData+Expand.m
//  UtileScourceCode
//
//  Created by wlpiaoyi on 15/11/26.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "NSData+Expand.h"

@implementation NSData(Expand)
-(id _Nullable) toDictionary{
//    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:self];
//    NSDictionary *dictionary = [unarchiver decodeObjectForKey:@"Some Key Value"];
//    [unarchiver finishDecoding];
//    return dictionary;
    
    NSError *error;
    id obj = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSAssert(NO, error.domain);
    }
    return obj;
}
-(NSString * _Nullable) toString{
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}
@end
