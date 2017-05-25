//
//  QRCodeScanViewController.m
//  QRCodeScale
//
//  Created by Ngmm_Jadon on 2017/5/24.
//  Copyright © 2017年 Ngmm_Jadon. All rights reserved.
//

#import "QRCodeScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ResultViewController.h"

@interface ScanAnimationLayer ()

@property (nonatomic, assign) CGFloat lineStartY;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation ScanAnimationLayer

- (void)layoutSublayers {
    [super layoutSublayers];
    
    _lineStartY = 0.0f;
    
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.strokeColor = [UIColor greenColor].CGColor;
    _shapeLayer.lineWidth = 0.5;
    [self addSublayer:_shapeLayer];
    
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(paintCurrentLine)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)paintCurrentLine {
    self.lineStartY += 1.5;
    if (self.lineStartY > self.frame.size.height) {
        self.lineStartY = 0.0f;
    }
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(0, self.lineStartY)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, self.lineStartY)];
    _shapeLayer.path = path.CGPath;
}

@end

@interface QRCodeScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,CALayerDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoLayer;

@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, strong) UIView *centerScanView;
@property (nonatomic, strong) ScanAnimationLayer *animationLayer;

@property (nonatomic, assign) CGRect scanRect;

@end

@implementation QRCodeScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setScanConfig];
    [self addSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNav];
    [self startScaning];
}

#pragma mark - setNavigationItem
- (void)setNav {
    self.navigationItem.title = @"扫一扫";
    
    UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissBtn.frame = CGRectMake(0, 0, 30, 30);
    dismissBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [dismissBtn setTitle:@"取消" forState:UIControlStateNormal];
    [dismissBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dismissBtn addTarget:self action:@selector(dismissBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:dismissBtn];
}

- (void)dismissBtnClick {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - setAVCapture
- (void)setScanConfig {
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
    [self.view.layer insertSublayer:self.maskLayer above:self.videoLayer];
    [self.maskLayer setNeedsDisplay];
    
    //设置扫描的区域:
    //    方法一：自己计算；
    CGFloat w = 200;
    CGFloat h = w;
    CGFloat x = (self.view.bounds.size.width - w) * 0.5;
    CGFloat y = (self.view.bounds.size.height- h) * 0.5;
    self.output.rectOfInterest = CGRectMake(y/self.view.bounds.size.height, x/self.view.bounds.size.width,  h/self.view.bounds.size.height, w/self.view.bounds.size.width);
    self.scanRect = CGRectMake(x, y, w, h);
    
    //    方法二：直接转换,但是要在 AVCaptureInputPortFormatDescriptionDidChangeNotification 通知里设置，否则 metadataOutputRectOfInterestForRect: 转换方法会返回 (0, 0, 0, 0)。
    //    __weak __typeof(&*self)weakSelf = self;
    //    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock: ^(NSNotification *_Nonnull note) {
    //        weakSelf.output.rectOfInterest = [weakSelf.videoLayer metadataOutputRectOfInterestForRect:weakSelf.scanRect];
    //    }];
}

#pragma mark - addSubviews
- (void)addSubViews {
    [self addCenterScanView];
    [self addTipLabel];
}

- (void)addTipLabel {
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.bounds = CGRectMake(0, 0, self.view.bounds.size.width, 30);
    tipLabel.center = CGPointMake(self.centerScanView.center.x, CGRectGetMaxY(self.centerScanView.frame)+50);
    tipLabel.text = @"将二维码放入框内，即可自动扫描";
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.font = [UIFont systemFontOfSize:15];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
}

- (void)addCenterScanView {
    self.centerScanView = [[UIView alloc] initWithFrame:self.scanRect];
    self.centerScanView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.centerScanView];
    
    for (NSInteger i = 0; i < 4; i++) {
        UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Scan_icon"]];
        switch (i) {
            case 0:
                imgV.frame = CGRectMake(0, 0, 15, 15);
                break;
            case 1:
                imgV.frame = CGRectMake(self.centerScanView.bounds.size.width - 15, 0, 15, 15);
                imgV.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                break;
            case 2:
                imgV.frame = CGRectMake(0, self.centerScanView.bounds.size.height - 15, 15, 15);
                imgV.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
                break;
            case 3:
                imgV.frame = CGRectMake(self.centerScanView.bounds.size.width - 15, self.centerScanView.bounds.size.height - 15, 15, 15);
                imgV.transform = CGAffineTransformMakeRotation(M_PI);
                break;
            default:
                break;
        }
        [self.centerScanView addSubview:imgV];
    }
    
}

#pragma mark - scan action
- (void)startScaning {
    [self.session startRunning];
    
    _animationLayer = [[ScanAnimationLayer alloc] init];
    _animationLayer.frame = CGRectMake(0, 0, _scanRect.size.width, _scanRect.size.height);
    [self.centerScanView.layer addSublayer:_animationLayer];
}

- (void)stopScaning {
    [self.session stopRunning];
    
    [_animationLayer removeFromSuperlayer];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
    NSString *result = object.stringValue;
    [self stopScaning];
    NSLog(@"%@",result);
    [self.navigationController pushViewController:[[ResultViewController alloc]initWithResult:result] animated:YES];
}

#pragma mark - CALayerDelegate
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    if (layer == self.maskLayer) {
        UIGraphicsBeginImageContextWithOptions(self.maskLayer.frame.size, NO, 1.0);
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8].CGColor);
        CGContextFillRect(ctx, self.maskLayer.frame);
        CGContextClearRect(ctx, self.scanRect);
    }
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
    self.maskLayer.delegate = nil;
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
