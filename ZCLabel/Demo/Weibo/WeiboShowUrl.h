//
//  WeiboShowUrl.h
//  ZCCoreTextTrain
//
//  Created by pogong on 16/6/21.
//  Copyright © 2016年 Pogong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboShowUrl : NSObject

@property(nonatomic)NSInteger url_type;
@property(nonatomic,copy)NSString * short_url;
@property(nonatomic,copy)NSString * url_title;
@property(nonatomic,copy)NSString * url_type_pic;

@end
