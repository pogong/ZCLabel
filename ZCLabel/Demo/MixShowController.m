//
//  MixShowController.m
//  CoreTextTrain
//
//  Created by pogong on 16/7/27.
//  Copyright © 2016年 pogong. All rights reserved.
//

#import "MixShowController.h"
#import "ZCLabel.h"
#import "ZCLabelRange.h"
#import "NSAttributedString+make.h"
#import "UIImage+GIF.h"

@interface MixShowController ()

@end

@implementation MixShowController

-(void)btnPress
{
	NSLog(@"btnPress");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.title = @"MixShow";
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.edgesForExtendedLayout = UIRectEdgeAll;

	[self mixShowWithLinkTap];
	
}

-(void)mixShowWithLinkTap
{
	UIFont * font = [UIFont systemFontOfSize:16.0];
	
	NSMutableAttributedString * text = [NSMutableAttributedString new];
	{
		NSString * title = @"图文示例:";
		[text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:nil]];
	}
	
	{
		NSString * title = @"普通图片->";
		[text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:nil]];
	}
	
	{
		UIImage * image = [UIImage imageNamed:@"hitgirl.jpg"];
		NSAttributedString * imageText = [NSAttributedString makeAttachmentStringWithContent:image attachmentSize:CGSizeMake(32, 48) alignToFont:font alignment:ZCTextVerticalAlignmentCenter];
		[text appendAttributedString:imageText];
	}
	
	{
		NSString * title = @"Gif->";
		[text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:nil]];
	}
	
	{
		UIImageView * imageView = [[UIImageView alloc]init];
		imageView.image = [UIImage sd_animatedGIFNamed:@"001"];
		NSAttributedString * imageText = [NSAttributedString makeAttachmentStringWithContent:imageView attachmentSize:CGSizeMake(16.0, 16.0) alignToFont:font alignment:ZCTextVerticalAlignmentCenter];
		[text appendAttributedString:imageText];
	}
	
	{
		NSString * title = @"按钮->";
		NSMutableAttributedString * muAtt = [[NSMutableAttributedString alloc] initWithString:title attributes:nil];
		[text appendAttributedString:[muAtt copy]];
	}
	
	{
		UIButton * btn = [[UIButton alloc]init];
		[btn setTitle:@"btn" forState:UIControlStateNormal];
		btn.backgroundColor = [UIColor redColor];
		[btn addTarget:self action:@selector(btnPress) forControlEvents:UIControlEventTouchUpInside];
		NSAttributedString * attachText =  [NSAttributedString makeAttachmentStringWithContent:btn attachmentSize:CGSizeMake(80.0, 40.0) alignToFont:font alignment:ZCTextVerticalAlignmentCenter];
		[text appendAttributedString:attachText];
	}
	
	NSRange range1 = [text.string rangeOfString:@"普通图片"];
	NSRange range2 = [text.string rangeOfString:@"Gif"];
	NSRange range3 = [text.string rangeOfString:@"按钮"];
	
	[text addAttribute:NSForegroundColorAttributeName value:kWBCellTextHighlightColor range:range1];
	[text addAttribute:NSForegroundColorAttributeName value:kWBCellTextHighlightColor range:range2];
	[text addAttribute:NSForegroundColorAttributeName value:kWBCellTextHighlightColor range:range3];
	
	NSMutableParagraphStyle * muParagraphStyle = [[NSMutableParagraphStyle alloc]init];
	muParagraphStyle.alignment = NSTextAlignmentLeft;
	muParagraphStyle.lineSpacing = 5.0;
	[text addAttribute:NSParagraphStyleAttributeName value:[muParagraphStyle copy] range:NSMakeRange(0 , [text length])];
	
	[text addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, text.length)];
	
	NSAttributedString * any = [text copy];
	
	any.suggestSize = CGSizeMake(300.0, MAXFLOAT);
	
	ZCLabel * textView = [[ZCLabel alloc] initWithFrame:self.view.bounds];
	textView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:textView];
	textView.attributedText = any;
	textView.frame = CGRectMake(40.0, 64.0+64.0, 300.0, any.calheight);
	textView.layer.borderWidth = 1.0;
	textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	
	textView.tapHander = ^(NSString * string,NSRange range,NSDictionary * info){
		NSLog(@"tapHander on -----%@",string);
		NSString * message = [NSString stringWithFormat:@"%@\nrange(%zd,%zd)",string,range.location,range.length];
		UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"tapHander on"
													   message:message
													  delegate:nil
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil, nil];
		[alert show];
	};
	
	ZCLabelRange * selectRange1 = [[ZCLabelRange alloc]init];
	selectRange1.range = range1;
	
	ZCLabelRange * selectRange2 = [[ZCLabelRange alloc]init];
	selectRange2.range = range2;
	
	ZCLabelRange * selectRange3 = [[ZCLabelRange alloc]init];
	selectRange3.range = range3;
	
	[textView.selectableRanges addObject:selectRange1];
	[textView.selectableRanges addObject:selectRange2];
	[textView.selectableRanges addObject:selectRange3];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
