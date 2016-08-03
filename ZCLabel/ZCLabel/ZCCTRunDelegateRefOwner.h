//
//  ZCTextRunDelegate.h
//  图文混排demo
//
//  Created by pogong on 16/4/20.
//  Copyright © 2016年 pogong All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface ZCCTRunDelegateRefOwner : NSObject <NSCopying, NSCoding>

- (nullable CTRunDelegateRef)CTRunDelegate;

@property (nullable, nonatomic, strong) id customRunContent;

@property (nonatomic, assign) CGRect customRunFrame;

@property (nonatomic) CGFloat ascent;

@property (nonatomic) CGFloat descent;

@property (nonatomic) CGFloat width;

@end
