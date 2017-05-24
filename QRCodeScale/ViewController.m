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
    btn.frame = self.view.bounds;
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)btnClick {
    [self presentViewController:[QRCodeScaleViewController new] animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
