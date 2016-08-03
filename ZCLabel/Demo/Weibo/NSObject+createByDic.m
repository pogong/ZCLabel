//
//  NSObject+createByDic.m
//  ZCRuntimeTrain
//
//  Created by pogong on 16/5/8.
//  Copyright © 2016年 pogong. All rights reserved.
//

#import "NSObject+createByDic.h"
#import <objc/runtime.h>

@implementation NSObject (createByDic)

static NSSet * _foundationClasses;

+(NSDictionary *)zc_customKeyDic
{
    return nil;
}
+(NSDictionary *)zc_modelInArray;
{
    return nil;
}

+ (void)load
{
    _foundationClasses = [NSSet setWithObjects:
                          [NSObject class],
                          [NSURL class],
                          [NSDate class],
                          [NSNumber class],
                          [NSDecimalNumber class],
                          [NSData class],
                          [NSMutableData class],
                          [NSArray class],
                          [NSMutableArray class],
                          [NSDictionary class],
                          [NSMutableDictionary class],
                          [NSString class],
                          [NSMutableString class], nil];
}

+ (BOOL)isClassFromFoundation:(Class)c
{
    return [_foundationClasses containsObject:c];
}

+(id)zc_objectWithDic:(NSDictionary *)dic
{
    id thing = [self new];
    Class class = self;
    while (class && [NSObject isClassFromFoundation:class] == NO) {
        unsigned int outCount = 0;
        Ivar * ivars = class_copyIvarList(class, &outCount);
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            NSString * propertyName = [[NSString stringWithUTF8String:ivar_getName(ivar)] substringFromIndex:1];
            NSDictionary * customKeyDic = [class zc_customKeyDic];
            NSString * key = @"";
            if (customKeyDic[propertyName]) {
                key = customKeyDic[propertyName];
            }else{
                key = propertyName;
            }
            id value = dic[key];
            if (value == nil) continue;
            
            NSString * type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
            NSRange range = [type rangeOfString:@"@"];
            if (range.location != NSNotFound) {
                
                type = [type substringWithRange:NSMakeRange(2, type.length - 3)];
                if (![type hasPrefix:@"NS"]) {
                    Class class = NSClassFromString(type);
                    value = [class zc_objectWithDic:value];
                }else if ([type isEqualToString:@"NSArray"]) {
                    NSArray * array = (NSArray *)value;
                    NSDictionary * modelInArray = [class zc_modelInArray];
                    NSString * className = modelInArray[propertyName];
                    if (className.length <= 0) {
                        value = @[];
                    }else{
                        Class class = NSClassFromString(modelInArray[propertyName]);
                        NSMutableArray * muArr = [NSMutableArray array];
                        for (int i = 0; i < array.count; i++) {
                            [muArr addObject:[class zc_objectWithDic:value[i]]];
                        }
                        value = [muArr copy];
                    }
                }
            }
            [thing setValue:value forKeyPath:propertyName];
        }
        free(ivars);
        class = [class superclass];
    }
    return thing;
}

@end
