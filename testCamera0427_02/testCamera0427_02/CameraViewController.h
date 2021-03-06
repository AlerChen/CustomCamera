//
//  CameraViewController.h
//  testCamera0427_02
//
//  Created by TopScore-AI on 2018/4/28.
//  Copyright © 2018年 TopScore-AI. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Protocol

@protocol CameraViewControllerDelegate <NSObject>
    
/**
 拍照控制器完成事件

 @param photoImage 完成拍摄照片
 */
- (void)cameraViewControllerDidFinishedTakePhoto:(UIImage *)photoImage;
    
/**
 拍照控制器即将消失事件
 */
- (void)cameraViewControllerWillDismiss;
    
@end

@interface CameraViewController : UIViewController
    
#pragma mark - Property
    
/**
 代理
 */
@property(assign,nonatomic) id <CameraViewControllerDelegate> delegate;

@end
