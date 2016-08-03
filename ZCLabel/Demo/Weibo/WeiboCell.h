//
//  WeiboCell.h
//  ZCLabel
//
//  Created by Pogong on 16/7/4.
//  Copyright © 2016年 Pogong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboShowModel.h"

@interface WeiboCell : UITableViewCell
@property(nonatomic,strong)WeiboShowModel * showModel;
-(NSInteger)sub_Views;
@end
