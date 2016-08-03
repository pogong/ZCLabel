//
//  ViewController.m
//  CoreTextTrain
//
//  Created by pogong on 16/7/27.
//  Copyright © 2016年 pogong. All rights reserved.
//

#import "ViewController.h"
#import "CompareController.h"
#import "MixShowController.h"
#import "WeiboViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
	UITableView * _tableView;
	NSArray * _dataArr;
}
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.edgesForExtendedLayout = UIRectEdgeAll;
	
	self.title = @"ZCLabel";
	
	_dataArr = @[@"all show str is attStr",@"MixShow",@"Weibo"];
	
	CGRect frame = self.view.bounds;
	frame.size.height -= 64;
	frame.origin.y = 64;
	
	_tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_tableView];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	
	[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	cell.textLabel.text = _dataArr[indexPath.row];
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.row == 0) {
		CompareController * compare = [[CompareController alloc]init];
		[self.navigationController pushViewController:compare animated:YES];
	}else if (indexPath.row == 1){
		MixShowController * mixShow = [[MixShowController alloc]init];
		[self.navigationController pushViewController:mixShow animated:YES];
	}else{
		WeiboViewController * weibo = [[WeiboViewController alloc]init];
		[self.navigationController pushViewController:weibo animated:YES];
	}
}

@end
