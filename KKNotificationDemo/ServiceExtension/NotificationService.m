//
//  NotificationService.m
//  ServiceExtension
//
//  Created by 看影成痴 on 2020/6/6.
//  Copyright © 2020 看影成痴. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

// 收到通知
// 在这进行内容修改, 比如修改title, 语言本地化, 解密信息, 加载附件等等
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];

    // 修改标题
    NSString *title = self.bestAttemptContent.title;
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", title];
    NSLog(@"%s 原标题:%@, 修改后:%@", __func__, title, self.bestAttemptContent.title);
    
    // 下载附件
    NSDictionary *dict =  self.bestAttemptContent.userInfo;
    NSString *mediaType = dict[@"media"][@"type"];
    NSString *mediaUrl = dict[@"media"][@"url"];
    [self loadAttachmentForUrlString:mediaUrl mediaType:mediaType completionHandle:^(UNNotificationAttachment *attachment) {
        if (attachment) {
            self.bestAttemptContent.attachments = @[attachment];
        }
        // 回调, 如果类别是自定义的, 将会转到content extension
        self.contentHandler(self.bestAttemptContent);
    }];
}


// 修改超时
// 系统提供大约30秒的时间供内容修改, 如果到期还没调用contentHandler, 则将会强制终止, 在此方法作最后一次修改
- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    NSLog(@"%s 超时", __func__);
    self.contentHandler(self.bestAttemptContent);
}


#pragma mark - private

// 下载附件
- (void)loadAttachmentForUrlString:(NSString *)urlStr
                         mediaType:(NSString *)type
                  completionHandle:(void(^)(UNNotificationAttachment *attachment))completionHandler {
    NSLog(@"%s 开始下载附件 urlStr:%@", __func__, urlStr);
    
    __block UNNotificationAttachment *attachment = nil;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *URL = [NSURL URLWithString:urlStr];
    [[session downloadTaskWithURL:URL completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
        NSLog(@"%s 下载附件结束", __func__);
        if (error != nil) {
            NSLog(@"error:%@", error.localizedDescription);
        } else {
            // 下载过程中原来的扩展名变成了tmp,所以我们需替换成原先的扩展名
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *path = [temporaryFileLocation.path stringByDeletingPathExtension];    // 去掉.tmp后缀名 (包括.)
            NSString *fileExt = [urlStr pathExtension];                                     // 原先的后缀名 (不包括.)
            NSURL *localURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:fileExt]]; // 最终后缀名 (包括.)
            [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];  // 替换
            // 附件内容
            NSError *attachmentError = nil;
            attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:localURL options:nil error:&attachmentError];
            if (attachmentError) {
                NSLog(@"error:%@", attachmentError.localizedDescription);
            }
            // 如果是图片类型, 传递给content扩展程序来显示
            if ([type isEqualToString:@"image"]) {
                NSData *imageData = [NSData dataWithContentsOfURL:localURL];
                NSDictionary *userInfo = @{@"imageData" : imageData};
                self.bestAttemptContent.userInfo = userInfo;
            }
        }
        completionHandler(attachment);
    }] resume];
}


@end
