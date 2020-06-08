//
//  KKAuthorizationTool.m
//  LXDisk
//
//  Created by lexin on 2020/1/2.
//  Copyright © 2020 Kang. All rights reserved.
//

#import "KKAuthorizationTool.h"
#import <Photos/Photos.h>
#import <CoreLocation/CLLocationManager.h>
#import <UserNotifications/UserNotifications.h>


@implementation KKAuthorizationTool


// 检查相册权限
+ (void)checkAlbumAuthorizationWithBlock:(void (^) (BOOL authorized))block {
    
    // 判断授权状态
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusNotDetermined) {         // 用户还没有做出选择
        
        // 弹框请求用户授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {    // 用户第一次同意了访问相册权限
                if (block) block(YES);
            } else {                                            // 用户第一次拒绝了访问相机权限
                if (block) block(NO);
            }
        }];
        
    } else if (status == PHAuthorizationStatusAuthorized) {     // 用户允许当前应用访问相册
        
        if (block) block(YES);
        
    } else  {                                                   // 用户拒绝当前应用访问相册
        
        if (block) block(NO);
        
    }
}


// 检查相机权限
+ (void)checkCameraAuthorizationWithBlock:(void (^) (BOOL authorized))block {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (device) {
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (status) {
                
            case AVAuthorizationStatusNotDetermined:        // 未询问
            {
                // 询问
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (block) block(granted);
                }];
            }
                break;
                
            case AVAuthorizationStatusAuthorized:           // 允许
                if (block) block(YES);
                break;
                
            case AVAuthorizationStatusDenied:               // 拒绝
                if (block) block(NO);
                break;
                
            case AVAuthorizationStatusRestricted:           // 受限制的 (可能是家长控制权限)
                if (block) block(NO);
                break;
            
            default:
                if (block) block(NO);
                break;
        }
    }
}


// 检查录音权限
+ (void)checkAudioAuthorizationWithBlock:(void (^) (BOOL authorized))block {

    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {        // 未询问
        
        // 询问
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (block) block(granted);
            }];
        }
        
    } else if(videoAuthStatus == AVAuthorizationStatusRestricted ||     // 未授权
              videoAuthStatus == AVAuthorizationStatusDenied) {
        
        if (block) block(NO);
        
    } else{                                                             // 已授权
        
        if (block) block(YES);
        
    }
}


// 检查通知授权状态
+ (void)checkNotificationAuthorizationWithCompletion:(void (^) (BOOL granted))completion {
    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        switch (settings.authorizationStatus) {
                
            // 未询问
            case UNAuthorizationStatusNotDetermined:
                {
                    // 询问之 (注意options中要列举要使用到的权限选项, 不然在设置中将不显示该权限选项)
                    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        if (granted) {
                            NSLog(@"用户首次授权通知");
                            if (completion) completion(YES);
                        }else {
                            NSLog(@"用户首次拒绝通知");
                            if (completion) completion(NO);
                        }
                    }];
                }
                break;
                
            // 已拒绝
            case UNAuthorizationStatusDenied:
                {
                    NSLog(@"用户已拒绝通知");
                    if (completion) completion(NO);
                }
                break;
                
            // 已授权
            case UNAuthorizationStatusAuthorized:
            default:
                {
                    NSLog(@"用户已授权通知");
                    if (completion) completion(YES);
                }
                break;
        }
    }];
}


@end
