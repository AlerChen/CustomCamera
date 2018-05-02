//
//  ViewController.m
//  Uke
//
//  Created by TopScore-AI on 2018/4/27.
//  Copyright © 2018年 TopScore-AI. All rights reserved.
//

#import "CameraViewController.h"
#import <Masonry.h>
#import <AVFoundation/AVFoundation.h>

#define KScreenBounds   [UIScreen mainScreen].bounds
#define KScreenWidth  KScreenBounds.size.width*1.0
#define KScreenHeight KScreenBounds.size.height*1.0

@interface CameraViewController ()

//  捕获设备
@property(nonatomic)AVCaptureDevice * device;

//  输入设备
@property(nonatomic)AVCaptureDeviceInput * input;

//  Output
@property(nonatomic)AVCaptureMetadataOutput * output;

//  ImageOutPut
@property (nonatomic)AVCaptureStillImageOutput * imageOutPut;

//  Session
@property(nonatomic)AVCaptureSession * session;

//  图像预览层
@property(nonatomic)AVCaptureVideoPreviewLayer * previewLayer;

//  右按钮
@property(strong,nonatomic) UIButton * rightButton;

//  完成按钮
@property(strong,nonatomic) UIButton * finishedButton;

//  拍照按钮
@property (nonatomic)UIButton * PhotoButton;

//  闪光按钮
@property (nonatomic)UIButton * flashButton;

//  拍摄图片视图
@property (nonatomic)UIImageView * imageView;

//  聚焦视图
@property (nonatomic)UIView * focusView;

//  image
@property (nonatomic)UIImage * image;

//
//@property (nonatomic)BOOL isflashOn;

//  是否可用相机状态
@property (nonatomic)BOOL canCa;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureInfo];
    
    _canCa = [self canUseCamear];
    
    if (_canCa) {
        
        [self setupUI];
        
    }else { return; }
    
}

#pragma mark - Configure Info

- (void)configureInfo
{
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - SetupUI

/**
 Set up UI
 */
- (void)setupUI
{
    [self setupCamera];
    [self setupPhotoButton];
    [self setupLeftButton];
    [self setupRightButton];
    [self setupFinishedButton];
    [self setupFocusView];
    [self addTapGesture];
    
}

/**
 Set up Photo Button
 */
- (void)setupPhotoButton
{
    _PhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_PhotoButton];
    [_PhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-50);
        make.width.height.mas_equalTo(60);
        
    }];
    
    [_PhotoButton setImage:[UIImage imageNamed:@"photograph"] forState: UIControlStateNormal];
    [_PhotoButton setImage:[UIImage imageNamed:@"photograph_Select"] forState:UIControlStateNormal];
    [_PhotoButton addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    
}

/**
 Set up Left Button
 */
- (void)setupLeftButton
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.view addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(_PhotoButton);
        make.trailing.mas_equalTo(_PhotoButton.mas_leading).offset(-30);
        make.width.height.mas_equalTo(60);
        
    }];
    
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [leftButton addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    
}

/**
 Set up Right Button
 */
- (void)setupRightButton
{
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.view addSubview:_rightButton];
    [_rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(_PhotoButton);
        make.leading.mas_equalTo(_PhotoButton.mas_trailing).offset(30);
        make.width.height.mas_equalTo(60);
        
    }];
    
    [_rightButton setTitle:@"切换" forState:UIControlStateNormal];
    _rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_rightButton addTarget:self action:@selector(changeCamera) forControlEvents:UIControlEventTouchUpInside];
}

/**
 Set up Finished Button
 */
- (void)setupFinishedButton
{
    _finishedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.view addSubview:_finishedButton];
    [_finishedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(_PhotoButton);
        make.leading.mas_equalTo(_PhotoButton.mas_trailing).offset(30);
        make.width.height.mas_equalTo(60);
        
    }];
    
    [_finishedButton setTitle:@"完成" forState:UIControlStateNormal];
    _finishedButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_finishedButton addTarget:self action:@selector(finishedButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    _finishedButton.hidden = YES;
}

/**
 Set up Focus View
 */
- (void)setupFocusView
{
    _focusView = [[UIView alloc]init];
    [self.view addSubview:_focusView];
    
    [_focusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading);
        make.top.mas_equalTo(self.view.mas_top);
        make.width.height.mas_equalTo(80);
    }];
    
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor =[UIColor greenColor].CGColor;
    _focusView.backgroundColor = [UIColor clearColor];
    
    _focusView.hidden = YES;
}

/**
 添加点击手势
 */
- (void)addTapGesture
{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

/**
 设置摄像头
 */
- (void)setupCamera
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    self.output = [[AVCaptureMetadataOutput alloc]init];
    self.imageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
    self.session = [[AVCaptureSession alloc]init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
        
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.imageOutPut]) {
        [self.session addOutput:self.imageOutPut];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    // StartRunning
    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}

#pragma mark - Action Method

#pragma mark  截取照片

/**
 *  截取照片
 */
- (void)shutterCamera
{
    AVCaptureConnection * videoConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    [self.imageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        self.image = [UIImage imageWithData:imageData];
        [self.session stopRunning];
        self.imageView = [[UIImageView alloc]initWithFrame:self.previewLayer.frame];
        [self.view insertSubview:_imageView belowSubview:_PhotoButton];
        self.imageView.layer.masksToBounds = YES;
        self.imageView.image = _image;
        NSLog(@"image size = %@",NSStringFromCGSize(self.image.size));
        
        self.rightButton.hidden = YES;
        self.finishedButton.hidden = NO;
        
    }];
}

#pragma mark Cancel
/**
 *  取消
 */
-(void)cancle{
    
    [self.imageView removeFromSuperview];
    [self.session startRunning];
    
    if ([self.delegate respondsToSelector:@selector(cameraViewControllerWillDismiss)]) {
        [self.delegate cameraViewControllerWillDismiss];
    }
}


#pragma mark - Action Method
#pragma mark  Change Camera

/**
 *  切换前后摄像头
 */
- (void)changeCamera{
    
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        
        CATransition *animation = [CATransition animation];
        
        animation.duration = .5f;
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
                
            } else {
                [self.session addInput:self.input];
            }
            
            [self.session commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}

#pragma mark Finished

/**
 *  完成按钮点击事件
 */
- (void)finishedButtonDidClick
{
    [self.imageView removeFromSuperview];
    [self.session startRunning];
    if ([self.delegate respondsToSelector:@selector(cameraViewControllerDidFinishedTakePhoto:)]) {
        
        CGImageRef imageRegOrigin =[self.image CGImage];
        
        unsigned long cSizeWidth = CGImageGetWidth(imageRegOrigin);
        unsigned long cSizeHeight = CGImageGetHeight(imageRegOrigin);
        CGImageRef imageReg = CGImageCreateWithImageInRect(imageRegOrigin, CGRectMake(cSizeWidth/4, 0, cSizeHeight, cSizeHeight));
        // 旋转位图
        UIImage * image = [UIImage imageWithCGImage:imageReg scale:1.0 orientation:UIImageOrientationRight];
        // Image Release
        CGImageRelease(imageReg);
        [self.delegate cameraViewControllerDidFinishedTakePhoto:image];
    }
}

#pragma mark Save Image To Photo Album

/**
 *  保存图片至相册
 *
 @param savedImage 拍摄图片
 */
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"保存图片结果提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancleAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

#pragma mark  聚焦

/**
 *  聚焦功能
 *
 @param gesture 手势
 */
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point{
    
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                _focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _focusView.hidden = YES;
            }];
        }];
    }
}

#pragma mark - Reuse Code
#pragma mark 检查相机权限

/**
 检查相机权限
 
 @return 相机是否有权限
 */
- (BOOL)canUseCamear{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"请打开相机权限" message:@"设置-隐私-相机" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:cancleAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return NO;
        
    } else { return YES; }
    
    return YES;
}


@end










