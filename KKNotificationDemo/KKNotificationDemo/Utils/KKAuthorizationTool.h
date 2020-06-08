//
//  KKAuthorizationTool.h
//  LXDisk
//
//  Created by lexin on 2020/1/2.
//  Copyright © 2020 Kang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface KKAuthorizationTool : NSObject

// 检查相册权限
+ (void)checkAlbumAuthorizationWithBlock:(void (^) (BOOL authorized))block;

// 检查相机权限
+ (void)checkCameraAuthorizationWithBlock:(void (^) (BOOL authorized))block;

// 检查录音权限
+ (void)checkAudioAuthorizationWithBlock:(void (^) (BOOL authorized))block;

// 检查通知授权状态
+ (void)checkNotificationAuthorizationWithCompletion:(void (^) (BOOL granted))completion;

@end


NS_ASSUME_NONNULL_END
