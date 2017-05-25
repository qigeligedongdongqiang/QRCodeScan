//
//  ViewController.m
//  QRCodeScale
//
//  Created by Ngmm_Jadon on 2017/5/24.
//  Copyright © 2017年 Ngmm_Jadon. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeScaleViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"扫一扫" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.center = self.view.center;
    btn.bounds = CGRectMake(0, 0, 150, 100);
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)btnClick {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[QRCodeScaleViewController new]];
    [self presentViewController:nav animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
