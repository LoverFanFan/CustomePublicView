//
//  ViewController.m
//  CustomPublickKeyboard
//
//  Created by 吴启凡 on 16/1/14.
//  Copyright © 2016年 可行星. All rights reserved.
//

#import "ViewController.h"
#import "PublicTopicViewController.h"



@interface ViewController ()<UITextFieldDelegate,UITextViewDelegate>


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"发布界面";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 100, 200, 40);
    [btn setTitle:@"去发布" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(gotoPublicView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    

    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)gotoPublicView{
    
    PublicTopicViewController *pVC = [[PublicTopicViewController alloc]init];
    [self.navigationController pushViewController:pVC animated:YES];
    
}



@end
