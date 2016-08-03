//
//  NSObject+createByDic.h
//  ZCRuntimeTrain
//
//  Created by pogong on 16/5/8.
//  Copyright © 2016年 pogong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (createByDic)

+(NSDictionary *)zc_customKeyDic;
+(NSDictionary *)zc_modelInArray;
+(id)zc_objectWithDic:(NSDictionary *)dic;

@end
