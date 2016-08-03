//
//  Weibo.h
//  ZCCoreTextTrain
//
//  Created by pogong on 16/6/21.
//  Copyright © 2016年 Pogong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboShowUrl.h"

@interface Weibo : NSObject

@property (nonatomic, copy) NSString * text;
@property (nonatomic, strong) NSArray * url_struct;
@property (nonatomic, strong)Weibo * retweeted_status;

@end
