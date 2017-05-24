//
//  QRCodeScaleViewController.m
//  QRCodeScale
//
//  Created by Ngmm_Jadon on 2017/5/24.
//  Copyright © 2017年 Ngmm_Jadon. All rights reserved.
//

#import "QRCodeScaleViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface QRCodeScaleViewController ()<AVCaptureMetadataOutputObjectsDelegate,CALayerDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoLayer;

@property (nonatomic, strong) CALayer *maskLayer;

@end

@implementation QRCodeScaleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //创建会话
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    //添加输入输出设备
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    
    //设置扫描的数据类型
    self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes;
    
    //创建相机预览层
    self.videoLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.videoLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.videoLayer];
    
    //创建遮罩层
    self.maskLayer = [[CALayer alloc] init];
    self.maskLayer.frame = self.view.bounds;
    self.maskLayer.delegate = self;
    
    //设置扫描的区域，方法一：自己计算；方法二：直接转换,但是要在 AVCaptureInputPortFormatDescriptionDidChangeNotification 通知里设置，否则 metadataOutputRectOfInterestForRect: 转换方法会返回 (0, 0, 0, 0)。
    
//        CGFloat x = (self.view.bounds.size.width - 100) * 0.5;
//    
//        CGFloat y = (self.view.bounds.size.height- 100) * 0.5;
//    
//        CGFloat w = 100;
//    
//        CGFloat h = w;
//    
//    
//        self.output.rectOfInterest = CGRectMake(y/self.view.bounds.size.height, x/self.view.bounds.size.width,  h/self.view.bounds.size.height, w/self.view.bounds.size.width);

    
    __weak __typeof(&*self)weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock: ^(NSNotification *_Nonnull note) {
        
        weakSelf.output.rectOfInterest = [weakSelf.videoLayer metadataOutputRectOfInterestForRect:weakSelf.view.frame];
        
    }];
    
    [self.session startRunning];
}

#pragma mark - delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
    NSString *result = object.stringValue;
    [self.session stopRunning];
    NSLog(@"%@",result);
}

#pragma mark - lazyLoad
- (AVCaptureDevice *)device {
    if (!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureDeviceInput *)input {
    if (!_input) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

- (AVCaptureMetadataOutput *)output {
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _output;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
