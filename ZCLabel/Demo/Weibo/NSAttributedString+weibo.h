//
//  NSAttributedString+weibo.h
//  ZCCoreTextTrain
//
//  Created by Pogong on 16/7/4.
//  Copyright © 2016年 Pogong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Weibo.h"

typedef void(^ZCWeiboTextBlock)(NSMutableAttributedString * attributedString,NSMutableArray * selectRangeArr);

@interface NSAttributedString (weibo)

+(void)parseWeibo:(Weibo *)weibo font:(UIFont *)font finishBlock:(ZCWeiboTextBlock)finishBlock;

@end
