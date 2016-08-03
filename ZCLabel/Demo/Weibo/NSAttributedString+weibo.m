//
//  NSAttributedString+weibo.m
//  ZCCoreTextTrain
//
//  Created by Pogong on 16/7/4.
//  Copyright © 2016年 Pogong. All rights reserved.
//

#import "NSAttributedString+weibo.h"
#import "NSAttributedString+make.h"
#import "UIImage+GIF.h"
#import "WeiboShowUrl.h"
#import "ZCLabelRange.h"

@implementation NSAttributedString (weibo)

+(void)parseWeibo:(Weibo *)weibo font:(UIFont *)font finishBlock:(ZCWeiboTextBlock)finishBlock
{
	NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithString:weibo.text];
	NSMutableArray * selectRangeArr = [NSMutableArray array];
	
	//Emoticon
	NSRegularExpression * regexEmoticon = [NSRegularExpression regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]" options:kNilOptions error:NULL];
	NSArray<NSTextCheckingResult *> * emoticonResults = [regexEmoticon matchesInString:text.string options:kNilOptions range:NSMakeRange(0, text.string.length)];
	NSInteger cutTextCount = 0;
	for (NSTextCheckingResult * emo in emoticonResults) {
		if (emo.range.location == NSNotFound && emo.range.length <= 1) continue;
		NSRange range = emo.range;
		range.location -= cutTextCount;
		
		NSArray * imageArr = @[@"d_doge",@"d_miao",@"d_zhutou"];
		NSInteger anyone =  arc4random() % imageArr.count;
		NSString * imageName = imageArr[anyone];
		NSAttributedString * imageText = [NSAttributedString makeAttachmentStringWithContent:[UIImage imageNamed:imageName] attachmentSize:CGSizeMake(font.pointSize, font.pointSize) alignToFont:font alignment:ZCTextVerticalAlignmentCenter];
		[text replaceCharactersInRange:range withAttributedString:imageText];
		
		cutTextCount += range.length - 1;
	}
	
	//url exchange
	for (WeiboShowUrl * showUrl in weibo.url_struct) {
		if (showUrl.short_url.length == 0) continue;
		if (showUrl.url_title.length == 0) continue;
		
		NSRange searchRange = NSMakeRange(0, text.string.length);
		
		NSRange range = [text.string rangeOfString:showUrl.short_url options:kNilOptions range:searchRange];
		if (range.location == NSNotFound) continue;
		
		NSMutableAttributedString * replace = [[NSMutableAttributedString alloc] initWithString:showUrl.url_title];
		[replace addAttribute:NSForegroundColorAttributeName value:kWBCellTextHighlightColor range:NSMakeRange(0, replace.length)];
		if (showUrl.url_type_pic.length > 0) {
			NSAttributedString * imageText = [NSAttributedString makeAttachmentStringWithContent:[UIImage imageNamed:@"link38"] attachmentSize:CGSizeMake(font.pointSize, font.pointSize) alignToFont:font alignment:ZCTextVerticalAlignmentCenter];
			[replace insertAttributedString:imageText atIndex:0];
		}
		[text replaceCharactersInRange:range withAttributedString:replace];
		ZCLabelRange * selectRange = [[ZCLabelRange alloc]init];
		selectRange.range = NSMakeRange(range.location, showUrl.url_title.length+1);
		selectRange.customInfo = @{@"url":showUrl.short_url};
		[selectRangeArr addObject:selectRange];
	}
	
	//at //@"@[-_a-zA-Z0-9\u4E00-\u9FA5]+"
	NSRegularExpression * regexAt = [NSRegularExpression regularExpressionWithPattern:@"@[-_a-zA-Z0-9\u4E00-\u9FA5]+" options:kNilOptions error:NULL];
	NSArray<NSTextCheckingResult *> * atResults = [regexAt matchesInString:text.string options:kNilOptions range:NSMakeRange(0, text.string.length)];
	for (NSTextCheckingResult * at in atResults) {
		if (at.range.location == NSNotFound && at.range.length <= 1) continue;
		[text addAttribute:NSForegroundColorAttributeName value:kWBCellTextHighlightColor range:at.range];
		ZCLabelRange * selectRange = [[ZCLabelRange alloc]init];
		selectRange.range = at.range;
		selectRange.customInfo = @{@"at":@"at any"};
		[selectRangeArr addObject:selectRange];
	}
	
	//topic //@"#[^@#]+?#"
	NSRegularExpression * regexTopic = [NSRegularExpression regularExpressionWithPattern:@"#[^@#]+?#" options:kNilOptions error:NULL];
	NSArray<NSTextCheckingResult *> * topicResults = [regexTopic matchesInString:text.string options:kNilOptions range:NSMakeRange(0, text.string.length)];
	for (NSTextCheckingResult * topic in topicResults) {
		if (topic.range.location == NSNotFound && topic.range.length <= 1) continue;
		[text addAttribute:NSForegroundColorAttributeName value:kWBCellTextHighlightColor range:topic.range];
		ZCLabelRange * selectRange = [[ZCLabelRange alloc]init];
		selectRange.range = topic.range;
		selectRange.customInfo = @{@"topic":@"topic any"};
		[selectRangeArr addObject:selectRange];
	}
	[text addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, text.length)];
	finishBlock(text,selectRangeArr);
}

@end
