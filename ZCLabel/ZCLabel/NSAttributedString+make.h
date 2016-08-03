//
//  NSAttributedString+make.h
//  ZCCoreTextTrain
//
//  Created by pogong on 16/7/2.
//  Copyright © 2016年 pogong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

typedef NS_ENUM(NSInteger, ZCTextVerticalAlignment) {
    ZCTextVerticalAlignmentTop =    1, ///< Top alignment.
    ZCTextVerticalAlignmentCenter = 2, ///< Center alignment.
    ZCTextVerticalAlignmentBottom = 3, ///< Bottom alignment.
};

@interface NSAttributedString (make)

+ (NSAttributedString *)makeAttachmentStringWithContent:(id)content
                                         attachmentSize:(CGSize)attachmentSize
                                            alignToFont:(UIFont *)font
                                              alignment:(ZCTextVerticalAlignment)alignment;


@property (assign, nonatomic) CTFrameRef ctFrame;
@property (assign, nonatomic) CGFloat calheight;
@property (nonatomic)CGSize suggestSize;

@end
