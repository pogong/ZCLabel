//
//  ZCLabel.h
//  图文混排demo
//
//  Created by pogong on 16/4/22.
//  Copyright © 2016年 pogong All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZCLabelTapHandler)(NSString * string,NSRange range,NSDictionary * info);

@interface ZCLabel : UIView

@property(nullable,nonatomic,strong) NSMutableArray * selectableRanges;

@property(nonatomic)NSInteger numberOfLines;

@property(nullable,nonatomic,copy)NSAttributedString * attributedText;

@property(nullable,nonatomic,copy)ZCLabelTapHandler tapHander;

@end
