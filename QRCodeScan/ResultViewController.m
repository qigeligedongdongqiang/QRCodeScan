//
//  ResultViewController.m
//  QRCodeScan
//
//  Created by Ngmm_Jadon on 2017/5/25.
//  Copyright © 2017年 Ngmm_Jadon. All rights reserved.
//

#import "ResultViewController.h"

@interface ResultViewController ()

@property (nonatomic, copy) NSString *result;

@end

@implementation ResultViewController

- (instancetype)initWithResult:(NSString *)result {
    if (self = [super init]) {
        _result = result;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"扫描结果";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:label];
    label.text = self.result;
    label.textAlignment = NSTextAlignmentCenter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
