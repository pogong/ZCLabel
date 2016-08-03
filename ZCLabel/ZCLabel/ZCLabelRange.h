//
//  ZCLabelRange.h
//  ZCCoreTextTrain
//
//  Created by pogong on 16/6/12.
//  Copyright © 2016年 pogong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZCLabelRange : NSObject

@property(nonatomic)NSRange range;
@property(nonatomic,strong)UIColor * color;
@property(nonatomic,strong)NSDictionary * customInfo;

@end
