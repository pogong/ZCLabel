//
//  ZCLabel.m
//  图文混排demo
//
//  Created by pogong on 16/4/22.
//  Copyright © 2016年 pogong All rights reserved.
//

#import "ZCLabel.h"
#import "ZCCTRunDelegateRefOwner.h"
#import "ZCLabelRange.h"
#import "ZCLabelRange.h"
#import "NSAttributedString+make.h"

@interface ZCLabel()<NSLayoutManagerDelegate,UIGestureRecognizerDelegate>
{
	ZCLabelRange * _curSelectRange;
}

@property(nullable,nonatomic,copy)UIColor * highlightColor;
@property(nonatomic)BOOL isTouchMove;

@end

@implementation ZCLabel

-(NSMutableArray *)selectableRanges
{
	if (_selectableRanges == nil) {
		_selectableRanges = [NSMutableArray array];
	}
	return _selectableRanges;
}

-(instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.highlightColor = kWBCellTextHighlightBackgroundColor;
        self.numberOfLines = 0;
		self.userInteractionEnabled = YES;
	}
	return self;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
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

-(void)setAttributedText:(NSAttributedString *)attributedText
{
	_attributedText = attributedText;
	
	for (UIView * any in self.subviews) {
		[any removeFromSuperview];
	}
	
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//步骤1:翻转当前的坐标系（因为对于底层绘制引擎来说，屏幕左下角为（0，0））
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	[self drawHighlightWithRect:rect context:context];
	
	[self display:rect context:context];
}

-(void)display:(CGRect)rect context:(CGContextRef)context
{
	//步骤2:基础文字绘制
	CTFrameDraw(_attributedText.ctFrame, context);
	
	//步骤3:绘制自定义的内容
	[self coreCustomRunWithContext:context];
	
}

/**
 *  绘制自定义的内容
 *
 *  @param context 绘制上下文
 *
 */
- (void)coreCustomRunWithContext:(CGContextRef)context
{
	// 获得CTLine数组
	NSArray *lines = (NSArray *)CTFrameGetLines(_attributedText.ctFrame);
	NSInteger lineCount = [lines count];
	CGPoint lineOrigins[lineCount];
	CTFrameGetLineOrigins(_attributedText.ctFrame, CFRangeMake(0, 0), lineOrigins);
	
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
			
			id content = zcTextRunDelegate.customRunContent;
			CGRect frame = zcTextRunDelegate.customRunFrame;
			if ([content isKindOfClass:[UIImage class]]) {
				CGContextDrawImage(context, frame, ((UIImage *)content).CGImage);
			}else{
				frame.origin.y = self.frame.size.height - CGRectGetMaxY(frame);
				((UIView *)content).frame = frame;
				[self addSubview:content];
			}
		}
	}
}

- (CFIndex)getIndexWithPoint:(CGPoint)point{
	CTFrameRef textFrame = _attributedText.ctFrame;
	CFArrayRef lines = CTFrameGetLines(textFrame);
	if (!lines) {
		return -1;
	}
	CFIndex count = CFArrayGetCount(lines);
	
	// 获得每一行的origin坐标
	CGPoint origins[count];
	CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);
	
	// 翻转坐标系
	CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.bounds.size.height);
	transform = CGAffineTransformScale(transform, 1.f, -1.f);
	
	CFIndex idx = -1;
	for (int i = 0; i < count; i++) {
		CGPoint linePoint = origins[i];
		CTLineRef line = CFArrayGetValueAtIndex(lines, i);
		// 获得每一行的CGRect信息
		CGRect flippedRect = [self getLineBounds:line point:linePoint];
		CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
		
		if (CGRectContainsPoint(rect, point)) {
			// 将点击的坐标转换成相对于当前行的坐标
			CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
												point.y-CGRectGetMinY(rect));
			// 获得当前点击坐标对应的字符串偏移
			idx = CTLineGetStringIndexForPosition(line, relativePoint);
		}
	}
	return idx;
}

- (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

-(ZCLabelRange *)getSelectRangeWithPoint:(CGPoint)point
{
	CFIndex idx = [self getIndexWithPoint:point];
	for (ZCLabelRange * labelRange in _selectableRanges)
	{
		if (NSLocationInRange(idx, labelRange.range))
		{
			return labelRange;
		}
	}
	return nil;
}

#pragma add touch
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	self.isTouchMove = NO;
	CGPoint point = [[touches anyObject] locationInView:self];
	_curSelectRange = [self  getSelectRangeWithPoint:point];
	if (_curSelectRange) {
		[self setNeedsDisplay];
	}else{
		[super touchesBegan:touches withEvent:event];
	}
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	self.isTouchMove = YES;
	[super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	if (self.isTouchMove == NO) {
		CGPoint point = [[touches anyObject] locationInView:self];
		_curSelectRange = [self  getSelectRangeWithPoint:point];
		if (_curSelectRange) {
			if (_curSelectRange&&_tapHander) {
				_tapHander([[self.attributedText string]substringWithRange:_curSelectRange.range],_curSelectRange.range,_curSelectRange.customInfo);
			}
		}else{
			[super touchesEnded:touches withEvent:event];
		}
	}else{
		[super touchesEnded:touches withEvent:event];
	}
	_curSelectRange = nil;
	[self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	self.isTouchMove = NO;
	[super touchesCancelled:touches withEvent:event];
}

//绘制高亮背景
- (void)drawHighlightWithRect:(CGRect)rect context:(CGContextRef)ctx
{
	if (_curSelectRange)
	{
		if (_curSelectRange.color) {
			[_curSelectRange.color setFill];
		}else{
			[self.highlightColor setFill];
		}
		
		NSRange linkRange = _curSelectRange.range;
		
		CFArrayRef lines = CTFrameGetLines(_attributedText.ctFrame);
		CFIndex count = CFArrayGetCount(lines);
		CGPoint lineOrigins[count];
		CTFrameGetLineOrigins(_attributedText.ctFrame, CFRangeMake(0, 0), lineOrigins);
		NSInteger numberOfLines = [self numberOfDisplayedLines];
		
		for (CFIndex i = 0; i < numberOfLines; i++)
		{
			CTLineRef line = CFArrayGetValueAtIndex(lines, i);
			
			CFRange stringRange = CTLineGetStringRange(line);
			NSRange lineRange = NSMakeRange(stringRange.location, stringRange.length);
			NSRange intersectedRange = NSIntersectionRange(lineRange, linkRange);
			if (intersectedRange.length == 0) {
				continue;
			}
			
			CGRect highlightRect = [self rectForRange:linkRange
											   inLine:line
										   lineOrigin:lineOrigins[i]];
			
			highlightRect = CGRectOffset(highlightRect, 0, -rect.origin.y);
			
			if (!CGRectIsEmpty(highlightRect))
			{
				CGFloat pi = (CGFloat)M_PI;
				
				CGFloat radius = 1.0f;
				CGContextMoveToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + radius);
				CGContextAddLineToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + highlightRect.size.height - radius);
				CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + highlightRect.size.height - radius,
								radius, pi, pi / 2.0f, 1.0f);
				CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width - radius,
										highlightRect.origin.y + highlightRect.size.height);
				CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius,
								highlightRect.origin.y + highlightRect.size.height - radius, radius, pi / 2, 0.0f, 1.0f);
				CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width, highlightRect.origin.y + radius);
				CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius, highlightRect.origin.y + radius,
								radius, 0.0f, -pi / 2.0f, 1.0f);
				CGContextAddLineToPoint(ctx, highlightRect.origin.x + radius, highlightRect.origin.y);
				CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + radius, radius,
								-pi / 2, pi, 1);
				CGContextFillPath(ctx);
			}
		}
	}
}

- (CGRect)rectForRange:(NSRange)range
				inLine:(CTLineRef)line
			lineOrigin:(CGPoint)lineOrigin
{
	CGRect rectForRange = CGRectZero;
	CFArrayRef runs = CTLineGetGlyphRuns(line);
	CFIndex runCount = CFArrayGetCount(runs);
	
	// Iterate through each of the "runs" (i.e. a chunk of text) and find the runs that
	// intersect with the range.
	for (CFIndex k = 0; k < runCount; k++)
	{
		CTRunRef run = CFArrayGetValueAtIndex(runs, k);
		
		CFRange stringRunRange = CTRunGetStringRange(run);
		NSRange lineRunRange = NSMakeRange(stringRunRange.location, stringRunRange.length);
		NSRange intersectedRunRange = NSIntersectionRange(lineRunRange, range);
		
		if (intersectedRunRange.length == 0)
		{
			// This run doesn't intersect the range, so skip it.
			continue;
		}
		
		CGFloat ascent = 0.0f;
		CGFloat descent = 0.0f;
		CGFloat leading = 0.0f;
		
		// Use of 'leading' doesn't properly highlight Japanese-character link.
		CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,
														   CFRangeMake(0, 0),
														   &ascent,
														   &descent,
														   NULL); //&leading);
		CGFloat height = ascent + descent;
		
		CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
		
		CGFloat linkRectX = lineOrigin.x + xOffset - leading;
		CGFloat linkRectY = lineOrigin.y - descent;//绘制是,坐标轴倒置,所以 绘图的down-^ 等于 真实的up-V
		CGFloat linkRectW = width + leading;
		CGFloat linkRectH = height;
		
		CGRect linkRect = CGRectMake(linkRectX, linkRectY, linkRectW, linkRectH);
		
		linkRect.origin.y = roundf(linkRect.origin.y);
		linkRect.origin.x = roundf(linkRect.origin.x);
		linkRect.size.width = roundf(linkRect.size.width);
		linkRect.size.height = roundf(linkRect.size.height);
		
		rectForRange = CGRectIsEmpty(rectForRange) ? linkRect : CGRectUnion(rectForRange, linkRect);
	}
	
	return rectForRange;
}

-(NSInteger)numberOfDisplayedLines
{
	CFArrayRef lines = CTFrameGetLines(_attributedText.ctFrame);
	return _numberOfLines > 0 ? MIN(CFArrayGetCount(lines), _numberOfLines) : CFArrayGetCount(lines);
}

@end
