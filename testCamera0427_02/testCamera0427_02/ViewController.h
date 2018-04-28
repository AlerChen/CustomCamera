//
//  ViewController.h
//  testCamera0427_02
//
//  Created by TopScore-AI on 2018/4/27.
//  Copyright © 2018年 TopScore-AI. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Protocol

@protocol ViewControllerDelegate <NSObject>

/**
 拍照控制器即将消失事件
 */
- (void)cameraViewControllerWillDismiss;

@end

@interface ViewController : UIViewController

#pragma mark - Property

/**
 代理
 */
@property(assign,nonatomic) id <ViewControllerDelegate> delegate;

//@property(weak,nonatomic) id <ViewControllerDelegate> delegate;


@end

