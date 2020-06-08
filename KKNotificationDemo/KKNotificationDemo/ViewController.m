//
//  ViewController.m
//  KKNotificationDemo
//
//  Created by 看影成痴 on 2020/6/3.
//  Copyright © 2020 看影成痴. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "KKAuthorizationTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - UI action

// 本地通知
- (IBAction)localNotificationAction:(UIButton *)sender {
    
    // 检查通知授权状态 (由于用户可随时更改通知权限, 所以需要在设置通知前检查权限)
    __weak typeof(self) weakSelf = self;
    [KKAuthorizationTool checkNotificationAuthorizationWithCompletion:^(BOOL granted) {
        if (granted) {
            // 设置一个基于时间的本地通知
            [weakSelf setLocalNotification];
        }else {
            [weakSelf showAlertWithTitle:nil message:@"请于设置中开启App的通知权限" delay:2.0];
        }
    }];
}


#pragma mark - private

// 基于时间的本地通知
- (void)setLocalNotification {

    // 设置显示内容
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    // 使用localizedUserNotificationStringForKey:arguments:获取本地化后的字符串
    content.title = [NSString localizedUserNotificationStringForKey:@"title" arguments:nil];
    content.subtitle = [NSString localizedUserNotificationStringForKey:@"subtitle" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:@"body" arguments:nil];
    content.categoryIdentifier = @"CATEGORY2";  // 注释这行则显示系统通知样式
    content.sound = [UNNotificationSound soundNamed:@"123.mp3"];    // 声音
    content.badge = @(1);   // 徽章数字
    // 附件
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"apple" ofType:@"png"];
    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"image" URL:[NSURL fileURLWithPath:imagePath] options:nil error:nil];
    content.attachments = @[attachment];
    
    // 设置触发时间
    NSDateComponents* date = [[NSDateComponents alloc] init];
    date.hour = 13;
    date.minute = 51;
    UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:date repeats:NO];
     
    // 根据内容和触发条件生成一个通知请求
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"KKAlarmID" content:content trigger:nil];    // trigger为nil则立即触发通知

    // 将该请求添加到用户通知中心
    __weak typeof(self) weakSelf = self;
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
       if (error != nil) {
           NSLog(@"%@", error.localizedDescription);
       }else {
           [weakSelf showAlertWithTitle:nil message:@"设置本地通知成功" delay:2.0];
       }
    }];
}


// 提示框
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message delay:(float)delay {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertC animated:YES completion:nil];
        // delay 2s
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertC dismissViewControllerAnimated:YES completion:nil];
        });
    });
}


@end
