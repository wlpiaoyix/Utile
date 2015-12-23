//
//  PYReflect.m
//  RunTime
//
//  Created by wlpiaoyi on 15/7/6.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

#import "PYReflect.h"
#import <objc/runtime.h>


char* py_getencodes_m(char* encodePointer[]){
    size_t length = 0;
    int index = 0;
    while (true) {
        char *encode = encodePointer[index];
        if(!encode){
            index = 0;
            break;
        }
        length += strlen(encode);
        index++;
    }

    char *encodes = calloc(length+1, sizeof(char));
    
    index = 0;
    int indexA = 0;
    while (true) {
        char *encode = encodePointer[index];
        if(!encode){
            index = 0;
            break;
        }
        
        size_t l = strlen(encode);
        for (size_t _index = 0; _index < l; _index++) {
            encodes[indexA] = encode[_index];
            indexA ++;
        }
        index ++;
    }
    return encodes;
}


char* py_sub_chars_m(const char * targetChar, int subIndex, const char * subChar){
    size_t _targetLength = strlen(targetChar);
    size_t _subLength = strlen(subChar);
    
    size_t _subIndex = subIndex < 0 ? 0 : subIndex;
    _subIndex = _subIndex > _targetLength - 1 ? _targetLength - 1 : _subIndex;
    
    char *charValue = calloc(_targetLength + _subLength, sizeof(char));
    for(size_t index = 0; index < _targetLength + _subLength; index++){
        char c;
        if(index < _subIndex){
            c = targetChar[index];
        }else if(index < _subLength + _subIndex){
            c = subChar[index - _subIndex];
        }else{
            c = targetChar[index - _subIndex - _subLength];
        }
        charValue[index] = c;
    }
    return charValue;
}

char* py_copy_chars_m(const char * charCopy, size_t startIndex, size_t endIndex){
    size_t _startIndex = startIndex == -1 ? 0 : startIndex;
    size_t _endIndex = endIndex == -1? strlen(charCopy) : endIndex;
    char *charValue = calloc(_endIndex - _startIndex, sizeof(char));
    for(size_t index = _startIndex; index < _endIndex; index++){
        charValue[index-_startIndex] = charCopy[index];
    }
    return charValue;
}

char* py_parse_encode_type(const char * encodeType ,bool* isBaseType){
    char *type = "";
    bool flagBaseType = true;
    int index = 0;
    char *_encodeType;
    while (index < strlen(encodeType)) {
        if(encodeType[index] != '^'){
            break;
        }
        index++;
    }
    if(index > 0){
        _encodeType = py_copy_chars_m(encodeType, index, strlen(encodeType));
    }else{
        _encodeType = py_copy_chars_m(encodeType, -1, -1);
    }
    if(strcasecmp(_encodeType, @encode(void)) == 0){
        type = "Void";
    }else if(strcasecmp(_encodeType, @encode(char)) == 0){
        type = "Int8";
    }else if(strcasecmp(_encodeType, @encode(short)) == 0){
        type = "Int16";
    }else if(strcasecmp(_encodeType, @encode(int)) == 0){
        type = "Int32";
    }else if(strcasecmp(_encodeType, @encode(long)) == 0 || strcasecmp(_encodeType, @encode(long long)) == 0 || strcasecmp(_encodeType, @encode(long long int)) == 0){
        type = "Int64";
    }else if(strcasecmp(_encodeType, @encode(bool)) == 0){
        type = "Bool";
    }else if(strcasecmp(_encodeType, @encode(float)) == 0){
        type = "Float";
    }else if(strcasecmp(_encodeType, @encode(double)) == 0){
        type = "Double";
    }else if(strcasecmp(_encodeType, @encode(id)) == 0){
        flagBaseType = false;
        type = "Object";
    }else{
        flagBaseType = false;
        
        size_t typeLength = strlen(_encodeType);
        
        if(_encodeType[0] == '@' && _encodeType[1] == '"' && _encodeType[typeLength - 1] == '"'){
            NSString *strEncodeType = [NSString stringWithUTF8String:_encodeType];
            strEncodeType = [strEncodeType stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
            strEncodeType = [strEncodeType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            type = (char *)[strEncodeType UTF8String];
        }
    }
    if (index > 0) {
        char * tempChars = calloc(index, sizeof(char));
        while (index > 0) {
            index--;
            tempChars[index] = '*';
        }
        type = (char *)[[NSString stringWithFormat:@"%s%s",tempChars,type] UTF8String];
        free(tempChars);
    }
    free(_encodeType);
    if(isBaseType)*isBaseType = flagBaseType;
    return type;
}


@implementation PYReflect{
}

//==>分布执行方法
+ (nullable id) startInvoke:(nonnull id) target action:(nonnull SEL)action{
    //初始化NSMethodSignature对象
    NSMethodSignature *methodSig = [[target class] instanceMethodSignatureForSelector:action];
    if (methodSig == nil) {
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    if (invocation == nil) {
        return nil;
    }
    //设置被调用的消息
    [invocation setSelector:action];
    //设置调用者也就是AsynInvoked的实例对象
    [invocation setTarget:target];
    return invocation;
}
+ (void) setInvoke:(nullable void*) param index:(NSInteger) index invocation:(nonnull const id) invocation{
    if (![invocation isKindOfClass:[NSInvocation class]]) {
        return;
    }
    if (index < 2) return;
    if (!param) return;
    [invocation setArgument:param atIndex:index];
}

+ (void) excuInvoke:(nullable void*)returnValue returnType:(char * _Nullable * _Nullable) returnType invocation:(nonnull const id) invocation{
    if (![invocation isKindOfClass:[NSInvocation class]]) {
        return;
    }
    if(invocation == nil) return;
    //retain 所有参数，防止参数被释放dealloc
    [invocation retainArguments];
    //消息调用
    [invocation invoke];
    char *_returnType = (char*)((NSInvocation*)invocation).methodSignature.methodReturnType;
    //获得返回值类型
    if(!_returnType){
        return;
    }else{
        if(returnType){
            *returnType = _returnType;
        }
    }
    
    if(!returnValue){
        return;
    }
    
    if(strcmp(_returnType, @encode(void)) == 0){//如果没有返回值，也就是消息声明为void
        return;
    }
    [invocation getReturnValue:returnValue];
}
//<==
//单步执行反射方法
+ (void) invoke:(nonnull id) target action:(nonnull SEL)action returnValue:(nullable void*) returnValue params:(nullable void*) param,...NS_REQUIRES_NIL_TERMINATION{
    if (![target respondsToSelector:action]) {
        return;
    }
    NSInvocation *invaction = [self startInvoke:target action:action];
    //如果此消息有参数需要传入，那么就需要按照如下方法进行参数设置，需要注意的是，atIndex的下标必须从2开始。原因为：0 1 两个参数已经被target 和selector占用
    if(param){
        int index = 2;
        [self setInvoke:param index:index invocation:invaction];
        va_list _list;
        va_start(_list, param);
        void* resource = nil;
        while ((resource = va_arg( _list, void*))) {
            index ++;
            [self setInvoke:resource index:index invocation:invaction];
        }
        va_end(_list);
    }
    [self excuInvoke:returnValue returnType:nil invocation:invaction];
}

/**
 获取指定成员属性描述
 */
+(nonnull NSDictionary*) getPropertyInfoWithClass:(nonnull Class) clazz propertyName:(nonnull NSString*) propertyName{
    objc_property_t property = class_getProperty(clazz, [propertyName UTF8String]);
    return [self getPropertyInfoWithProperty:property];
}

/**
 获取所有成员属性描述
 */
+(nonnull NSArray<NSDictionary*>*) getPropertyInfosWithClass:(nonnull Class) clazz{
    unsigned int outCount;
    objc_property_t * propertyList = class_copyPropertyList(clazz, &outCount);
    NSMutableArray<NSDictionary*> *propertyInfos = [NSMutableArray<NSDictionary*> new];
    for (unsigned int index = 0; index < outCount; index++) {
        objc_property_t property = propertyList[index];
        [propertyInfos addObject:[self getPropertyInfoWithProperty:property]];
    }
    return propertyInfos;
}

/**
 获取指定实例方法描述
 */
+(nonnull NSDictionary*) getInstanceMethodWithClass:(nonnull Class) clazz selUid:(nonnull SEL) selUid{
    Method method = class_getInstanceMethod(clazz, selUid);
    return [self getMethodInfoWithMethod:method];
}/**
  获取指定静态方法描述
  */
+(nonnull NSDictionary*) getClassMethodWithClass:(nonnull Class) clazz selUid:(nonnull SEL) selUid{
    Method method = class_getClassMethod(clazz, selUid);
    return [self getMethodInfoWithMethod:method];
}
/**
 获取所有的方法信息
 */
+(nonnull NSArray<NSDictionary*>*) getInstanceMethodInfosWithClass:(nonnull Class) clazz{
    unsigned int outCount;
    Method* methods = class_copyMethodList(clazz, &outCount);
    NSMutableArray<NSDictionary*> *methodDics = [[NSMutableArray<NSDictionary*> alloc] init];
    for (int i = 0; i<outCount; i++) {
        Method method = methods[i];
        [methodDics addObject:[self getMethodInfoWithMethod:method]];
    }
    free(methods);
    return methodDics;

}

+(NSDictionary*) getPropertyInfoWithProperty:(objc_property_t) property{
    
    static NSString *keyName;
    static NSString *keyType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyName = @"name";
        keyType = @"type";
    });
    
    NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
    NSString *propertyType = [NSString stringWithUTF8String:property_getAttributes(property)];
    propertyType = [[propertyType componentsSeparatedByString:@","].firstObject substringFromIndex:1];
    propertyType = [NSString stringWithUTF8String:py_parse_encode_type(propertyType.UTF8String, nil)];
    
    return @{keyName:propertyName,keyType:propertyType};
    
}
+(NSDictionary*) getMethodInfoWithMethod:(Method) method{
    
    NSNumber *argumentNum = @(method_getNumberOfArguments(method)-2);
    char returnEncode[2];
    method_getReturnType(method, returnEncode, 2);
    NSString *returnType = [[NSString alloc] initWithUTF8String:py_parse_encode_type(returnEncode, nil)];
    
    static NSString *keyName;
    static NSString *keyArgumentNum;
    static NSString *keyReturnType;
    static NSString *keyReturEncode;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyName = @"name";
        keyArgumentNum = @"argumentNum";
        keyReturnType = @"returnType";
        keyReturEncode = @"returEncode";
    });
    
    return @{keyName :[NSString stringWithUTF8String:sel_getName(method_getName(method))],
                     keyArgumentNum:argumentNum,
                     keyReturnType:returnType,
                     keyReturEncode:[NSString stringWithUTF8String:returnEncode]};
}

@end
