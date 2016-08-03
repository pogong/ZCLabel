//
//  CompareController.m
//  CoreTextTrain
//
//  Created by pogong on 16/7/27.
//  Copyright © 2016年 pogong. All rights reserved.
//

#import "CompareController.h"

@interface CompareController ()

@end

@implementation CompareController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.edgesForExtendedLayout = UIRectEdgeAll;
	
	self.title = @"all show str is attStr";
	
	UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectZero];
	label1.backgroundColor = [UIColor lightGrayColor];
	label1.font = [UIFont systemFontOfSize:16.0];
	label1.textColor = [UIColor whiteColor];
	label1.textAlignment = NSTextAlignmentCenter;
	label1.frame = CGRectMake(20.0,64.0+20.0,300.0,30.0);
	label1.text = @"show string is attributedString";
	[self.view addSubview:label1];
	
	UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectZero];
	label2.backgroundColor = [UIColor lightGrayColor];
	NSMutableAttributedString * muAtt = [[NSMutableAttributedString alloc]initWithString:@"show string is attributedString"];
	[muAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0] range:NSMakeRange(0, muAtt.string.length)];
	[muAtt addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, muAtt.string.length)];
	NSMutableParagraphStyle * muParagraphStyle = [[NSMutableParagraphStyle alloc]init];
	muParagraphStyle.alignment = NSTextAlignmentCenter;
	[muAtt addAttribute:NSParagraphStyleAttributeName value:[muParagraphStyle copy] range:NSMakeRange(0 , [muAtt.string length])];
	label2.attributedText= [muAtt copy];
	label2.frame=CGRectMake(20.0,64.0+20.0+30.0+20.0,300.0,30.0);
	[self.view addSubview:label2];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
