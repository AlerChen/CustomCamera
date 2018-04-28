//
//  HomeViewController.m
//  testCamera0427_02
//
//  Created by TopScore-AI on 2018/4/27.
//  Copyright © 2018年 TopScore-AI. All rights reserved.
//

#import "HomeViewController.h"
#import <Masonry.h>
#import "CameraViewController.h"


@interface HomeViewController ()<CameraViewControllerDelegate>

@property(strong,nonatomic) UIButton * button;

@property(strong,nonatomic) UIImageView * imgView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureInfo];
    [self setupUI];
    
}

#pragma mark - Configure Info
- (void)configureInfo
{
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - SetupUI
- (void)setupUI
{
    [self setupButton];
    [self setupImgView];
}

- (void)setupButton
{
    _button = [[UIButton alloc]init];
    [self.view addSubview:_button];
    [_button mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.centerY.mas_equalTo(self.view);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
        
    }];
    _button.backgroundColor = [UIColor orangeColor];
    [_button setTitle:@"拍照" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonDidClick) forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)setupImgView{
    
    self.imgView = [[UIImageView alloc]init];
    [self.view addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.trailing.mas_equalTo(self.view.mas_trailing);
        make.top.mas_equalTo(self.view.mas_top).offset(200);
        make.width.height.mas_equalTo(100);
    }];
    self.imgView.backgroundColor = [UIColor orangeColor];
    
}

#pragma mark - Action Method
- (void)buttonDidClick
{
    
    CameraViewController * cameraVC = [[CameraViewController alloc]init];
    cameraVC.delegate = self;
    [self presentViewController:cameraVC animated:YES completion:nil];
        
}

#pragma mark - Delegate

/**
 拍照控制器即将消失事件
 */
- (void)cameraViewControllerWillDismiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"cameraViewDidDismiss");
    }];
    
}

/**
 拍照控制器完成事件
 
 @param photoImage 完成拍摄照片
 */
- (void)cameraViewControllerDidFinishedTakePhoto:(UIImage *)photoImage
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"cameraViewDidDismiss");
    }];
    
    
    [self.imgView setImage:photoImage];
    [self.imgView setNeedsDisplay];
}


@end



















