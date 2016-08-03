//
//  WeiboCell.m
//  ZCLabel
//
//  Created by Pogong on 16/7/4.
//  Copyright © 2016年 Pogong. All rights reserved.
//

#import "WeiboCell.h"
#import "ZCLabel.h"

@implementation WeiboCell
{
	ZCLabel * _label;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self initSubViews];
	}
	return self;
}

-(void)initSubViews{
	_label = [[ZCLabel alloc] init];
	_label.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:_label];
	_label.tapHander = ^(NSString * string,NSRange range,NSDictionary * info){
		NSLog(@"tapHander on -----%@",string);
		NSString * message = [NSString stringWithFormat:@"%@\ninfo>%@",string,info.description];
		UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"tapHander on"
														message:message
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil, nil];
		[alert show];
	};
	_label.layer.borderWidth = 1.0;
	_label.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

-(void)setShowModel:(WeiboShowModel *)showModel
{
	_showModel = showModel;
	_label.frame = CGRectMake(20.0, 20.0, MAIN_SCREEN_W - 40.0, _showModel.attributedText.calheight);
	_label.attributedText = _showModel.attributedText;
	[_label.selectableRanges removeAllObjects];
	[_label.selectableRanges addObjectsFromArray:_showModel.selectRangeArr];
}

-(NSInteger)sub_Views
{
	return _label.subviews.count;
}

@end
