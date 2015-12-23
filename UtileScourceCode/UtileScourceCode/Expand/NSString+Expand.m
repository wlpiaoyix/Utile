//
//  NSString+Convenience.m
//  AKSL-189-Msp
//
//  Created by qqpiaoyi on 13-11-12.
//  Copyright (c) 2013年 AKSL. All rights reserved.
//

#import "NSString+Expand.h"

@implementation NSString (Expand)

-(NSDate*) dateFormateString:(NSString*) formatePattern{
    NSDateFormatter *dft = [[NSDateFormatter alloc]init];
    [dft setDateFormat:formatePattern==nil?@"yyyy-MM-dd HH:mm:ss":formatePattern];
    return [dft dateFromString:self];
}
-(bool) stringEndWith:(NSString*) suffix{
    if(![NSString isEnabled:suffix]){
        return YES;
    }
    int formIndex = (int)[self length]-(int)[suffix length];
    if(formIndex>self.length){return NO;}
    if([suffix isEqual:[self substringFromIndex: formIndex]])return YES;
    else return NO;
}

-(bool) stringStartWith:(NSString*) suffix{
    if(![NSString isEnabled:suffix]){
        return YES;
    }
    int toIndex = (int)[suffix length];
    if(toIndex>self.length){return NO;}
    if([suffix isEqual:[self substringToIndex: toIndex]])return YES;
    else return NO;

}

-(int) intLastIndexOf:(char) suffix{
    const char* temp = [self UTF8String];
    for (int i=(int)strlen(temp);i>0;i--) {
        char c = temp[i];
        if(c==suffix){
            return i;
        }
    }
    return 0;
}
-(int) intIndexOf:(int) index Suffix: (char) suffix{
    const char* temp = [self UTF8String];
    int tempIndex = 0;
    for (int i=0;i<(int)strlen(temp);i++) {
        char c = temp[i];
        if(c==suffix){
            if(tempIndex == index) return i;
            tempIndex++;
        }
    }
    return 0;
}
-(NSString*) replaceAll:(NSString*) target Replcement:(NSString*) replcement{
    NSString *arg = [self replaceStringBy:self Target:target Replcement:replcement Index:0];
    return arg;
}
-(NSString*) replaceStringBy:(NSString*) arg Target:(NSString*) target Replcement:(NSString*) replcement Index:(int) index{
    if(![NSString isEnabled:target]||![NSString isEnabled:replcement]){
        return arg;
    }
    NSUInteger targetLength = target.length;
    NSUInteger argLength = arg.length;
    if(argLength<index+targetLength){
        return arg;
    }
    NSString *tempArg;
    NSUInteger currentIndex = argLength;
    for (int i=index;i<argLength;i++) {
        if(argLength<i+targetLength){
            return arg;
        }
        NSString *tempTaget = [[arg substringFromIndex:i] substringToIndex:targetLength];
        if([tempTaget isEqualToString:target]){
            currentIndex = i;
            NSString *startArg = [arg substringToIndex:currentIndex];
            NSString *endArg = [arg substringFromIndex:currentIndex+targetLength];
            tempArg = [NSString stringWithFormat:@"%@%@%@",startArg,replcement,endArg];
            break;
        }
    }
    if (tempArg) {
        return [self replaceStringBy:tempArg Target:target Replcement:replcement Index:currentIndex];
    }else{
        return arg;
    }
}
+(bool) isEnabled:(id) target{
    if(!target||target==nil||target==[NSNull null]||[@"" isEqual:target])return NO;
    else return YES;
}
-(NSString *)filterHTML
{
    NSString *html = self;
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO){
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
//    NSString * regEx = @"<([^>]*)>";
//    html = [html stringByReplacingOccurrencesOfString:regEx withString:@""];
    return html;
}
+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
