//
//  NSAttributedString+make.m
//  ZCCoreTextTrain
//
//  Created by pogong on 16/7/2.
//  Copyright © 2016年 pogong. All rights reserved.
//

#import "NSAttributedString+make.h"
#import "ZCCTRunDelegateRefOwner.h"
#import <objc/runtime.h>

@implementation NSAttributedString (make)

+ (NSAttributedString *)makeAttachmentStringWithContent:(id)content
                                         attachmentSize:(CGSize)attachmentSize
                                            alignToFont:(UIFont *)font
                                              alignment:(ZCTextVerticalAlignment)alignment
{
    
    NSMutableAttributedString * atr = [[NSMutableAttributedString alloc] initWithString:@"\uFFFC"];
    
    ZCCTRunDelegateRefOwner * zcdelegate = [ZCCTRunDelegateRefOwner new];
    zcdelegate.width = attachmentSize.width;
    switch (alignment) {
        case ZCTextVerticalAlignmentTop: {
            zcdelegate.ascent = font.ascender;//上对齐
            zcdelegate.descent = attachmentSize.height - zcdelegate.ascent;
            if (zcdelegate.descent < 0) {
                zcdelegate.ascent = attachmentSize.height;
                zcdelegate.descent = 0;
            }
        } break;
        case ZCTextVerticalAlignmentCenter: {
            CGFloat halfOut = (attachmentSize.height - font.lineHeight)/2;
            zcdelegate.ascent = font.ascender + halfOut;
            zcdelegate.descent = attachmentSize.height - zcdelegate.ascent;
            if (zcdelegate.descent < 0) {
                zcdelegate.ascent = attachmentSize.height;
                zcdelegate.descent = 0;
            }
        } break;
        case ZCTextVerticalAlignmentBottom: {
            zcdelegate.descent = -font.descender;//下对齐
            zcdelegate.ascent = attachmentSize.height - zcdelegate.descent;
            if (zcdelegate.ascent < 0) {
                zcdelegate.ascent = 0;
                zcdelegate.descent = attachmentSize.height;
            }
        } break;
        default: {
            zcdelegate.ascent = attachmentSize.height;
            zcdelegate.descent = 0;
        } break;
    }
    /*
     remain 
     font.descender 负值
     zcdelegate.descent 不小于0
     */
    zcdelegate.customRunContent = content;
    CTRunDelegateRef delegate = zcdelegate.CTRunDelegate;
    
    [atr addAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)delegate range:NSMakeRange(0, 1)];
    if (zcdelegate) CFRelease(delegate);
    
    return [atr copy];
}

char ctFrameKey;

-(void)setCtFrame:(CTFrameRef)ctFrame
{
	if (self.ctFrame != ctFrame) {
		if (self.ctFrame != nil) {
			CFRelease(self.ctFrame);
		}
		CFRetain(ctFrame);
		objc_setAssociatedObject(self, &ctFrameKey, (__bridge id)(ctFrame), OBJC_ASSOCIATION_ASSIGN);
	}
}

-(CTFrameRef)ctFrame
{
	return (__bridge CTFrameRef)(objc_getAssociatedObject(self, &ctFrameKey));
}

char calheightKey;

-(void)setCalheight:(CGFloat)calheight
{
	objc_setAssociatedObject(self, &calheightKey, @(calheight), OBJC_ASSOCIATION_ASSIGN);
}

-(CGFloat)calheight
{
	return [(objc_getAssociatedObject(self, &calheightKey)) floatValue];
}

char suggestSizeKey;

-(void)setSuggestSize:(CGSize)suggestSize
{
	objc_setAssociatedObject(self, &suggestSizeKey, [NSValue valueWithCGSize:suggestSize], OBJC_ASSOCIATION_ASSIGN);
	[self afterSetSuggstSizeAct];
}

-(CGSize)suggestSize
{
	return [(objc_getAssociatedObject(self, &suggestSizeKey)) CGSizeValue];
}

-(void)afterSetSuggstSizeAct
{
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
	
	CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), nil, self.suggestSize, nil);
	CGFloat textHeight = coreTextSize.height;
	
	// 生成CTFrameRef实例
	CTFrameRef ctFrame = [self createFrameWithFramesetter:framesetter width:self.suggestSize.width height:textHeight];
	
	self.ctFrame = ctFrame;
	self.calheight = textHeight;
	
	[self setCustomRunsFrame];
	
	// 释放内存
	CFRelease(framesetter);
}

- (void)setCustomRunsFrame
{
	// 获得CTLine数组
	NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);
	NSInteger lineCount = [lines count];
	CGPoint lineOrigins[lineCount];
	CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), lineOrigins);
	
	// 遍历每个CTLine
	for (NSInteger i = 0 ; i < lineCount; i++) {
		CTLineRef line = (__bridge CTLineRef)lines[i];
		NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
		
		// 遍历每个CTLine中的CTRun
		for (id runObj in runObjArray) {
			CTRunRef run = (__bridge CTRunRef)runObj;
			NSDictionary * runAttributes = (NSDictionary *)CTRunGetAttributes(run);
			CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
			if (delegate == nil) {
				continue;
			}
			
			/*
			 方法:CTRunDelegateGetRefCon 由CTRunDelegateRef 反拿 CTRunDelegateRefCon
			 参见方法:CTRunDelegateCreate 可以知道缘由
			 */
			ZCCTRunDelegateRefOwner * zcTextRunDelegate = CTRunDelegateGetRefCon(delegate);
			if (![zcTextRunDelegate isKindOfClass:[ZCCTRunDelegateRefOwner class]]) {
				continue;
			}
			
			CGRect runBounds;
			CGFloat ascent;
			CGFloat descent;
			
			runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
			runBounds.size.height = ascent + descent;
			
			CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
			runBounds.origin.x = lineOrigins[i].x + xOffset;
			runBounds.origin.y = lineOrigins[i].y;
			runBounds.origin.y -= descent;
			
			CGPathRef pathRef = CTFrameGetPath(self.ctFrame);
			CGRect colRect = CGPathGetBoundingBox(pathRef);
			
			CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
			zcTextRunDelegate.customRunFrame = delegateBounds;
		}
	}
}

- (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter
								   width:(CGFloat)width
								  height:(CGFloat)height {
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, CGRectMake(0, 0, width, height));
	
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
	CFRelease(path);
	return frame;
}

- (void)dealloc {
	if (self.ctFrame != nil) {
		CFRelease(self.ctFrame);
		self.ctFrame = nil;
	}
}

@end
