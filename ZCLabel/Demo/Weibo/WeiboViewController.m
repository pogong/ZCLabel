//
//  WeiboViewController.m
//  ZCCoreTextTrain
//
//  Created by pogong on 16/6/21.
//  Copyright © 2016年 Pogong. All rights reserved.
//

#import "WeiboViewController.h"
#import "NSObject+createByDic.h"
#import "Weibo.h"
#import "WeiboShowUrl.h"
#import "NSAttributedString+make.h"
#import "ZCLabel.h"
#import "ZCLabelRange.h"
#import "UIImage+GIF.h"
#import "NSAttributedString+weibo.h"
#import "WeiboShowModel.h"
#import "WeiboCell.h"

@interface WeiboViewController ()<UITableViewDelegate,UITableViewDataSource>
{
	UITableView * _tableView;
	NSArray * _dataArr;
}
@end

@implementation WeiboViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"Weibo";
	
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.edgesForExtendedLayout = UIRectEdgeAll;
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	NSString * path = [[NSBundle mainBundle] pathForResource:@"weibo_0.json" ofType:@""];
	NSData * data = [NSData dataWithContentsOfFile:path];
	NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
	NSArray * arr = dic[@"statuses"];
	
	CGFloat fontSize = 15.0;
	
	UIFont * font = [UIFont systemFontOfSize:fontSize];
	
	NSMutableArray * dataArr = [NSMutableArray array];
	
	for (NSDictionary * dic in arr) {
		Weibo * weibo = [Weibo zc_objectWithDic:dic];
		[NSAttributedString parseWeibo:weibo font:font finishBlock:^(NSMutableAttributedString *text, NSMutableArray *selectRangeArr) {
			NSAttributedString * attributedText = [text copy];
			attributedText.suggestSize = CGSizeMake(MAIN_SCREEN_W - 80.0, MAXFLOAT);
			WeiboShowModel * showModel = [WeiboShowModel new];
			showModel.attributedText = attributedText;
			showModel.selectRangeArr = [selectRangeArr copy];
			
			[dataArr addObject:showModel];
		}];
	}
	
	_dataArr = [dataArr copy];
	
	CGRect frame = self.view.bounds;
	frame.size.height -= 64;
	frame.origin.y = 64;
	
	_tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_tableView];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	
	[_tableView registerClass:[WeiboCell class] forCellReuseIdentifier:@"WeiboCell"];
	
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WeiboCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"WeiboCell"];
	cell.showModel = _dataArr[indexPath.row];
	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WeiboShowModel * showModel = _dataArr[indexPath.row];
	return showModel.attributedText.calheight + 40.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0.01;
}

@end
