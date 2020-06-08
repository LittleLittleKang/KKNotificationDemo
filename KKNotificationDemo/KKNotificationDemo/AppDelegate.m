//
//  AppDelegate.m
//  KKNotificationDemo
//
//  Created by 看影成痴 on 2020/6/3.
//  Copyright © 2020 看影成痴. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "KKAuthorizationTool.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    // 检查网络
    [self checkNetword];
    
    // 设置通知代理
    [self setNotificationDelegate];
    // 注册通知类别 (可选实现)
    [self setNotificationCategories];
    // 注册远程通知 (获取设备令牌)
//    [self registerRemoteNotifications];
  
    return YES;
}


// 新打开/后台到前台/挂起到运行 均调用  (挂起比如来电/双击home)
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // App icon上的徽章清零
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


/// 注册远程通知 成功
/// @param application App
/// @param deviceToken 设备令牌
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *deviceTokenStr = [self deviceTokenStrWithDeviceToken:deviceToken];
    
    NSLog(@"注册远程通知 成功 deviceToken:%@, deviceTokenStr:%@", deviceToken, deviceTokenStr);
}


/// 注册远程通知 失败
/// @param application App
/// @param error 错误信息
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
    
    NSLog(@"注册远程通知 失败 error:%@", error);
}


#pragma mark - UNUserNotificationCenterDelegate

/// 仅当App在前台运行时, 准备呈现通知时, 才会调用该委托方法.
/// 一般在此方法里选择将通知显示为声音, 徽章, 横幅, 或显示在通知列表中.
/// @param center 用户通知中心
/// @param notification 当前通知
/// @param completionHandler 回调通知选项: 横幅, 声音, 徽章...
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {

    UNNotificationRequest *request = notification.request;
    UNNotificationContent *conten = request.content;
    NSDictionary *userInfo = conten.userInfo;

    if ([request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"即将展示远程通知");
    }else {
        NSLog(@"即将展示本地通知");
    }
    NSLog(@"title:%@, subtitle:%@, body:%@, categoryIdentifier:%@, sound:%@, badge:%@, userInfo:%@", conten.title, conten.subtitle, conten.body, conten.categoryIdentifier, conten.sound, conten.badge, userInfo);

    // 以下是在App前台运行时, 仍要显示的通知选项
    completionHandler(UNNotificationPresentationOptionAlert + UNNotificationPresentationOptionSound + UNNotificationPresentationOptionBadge);
}


/// 当用户通过点击通知打开App/关闭通知或点击通知按钮时, 调用该方法.
/// (必须在application:didFinishLaunchingWithOptions:里设置代理)
/// @param center 用户通知中心
/// @param response 响应事件
/// @param completionHandler 处理完成的回调
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {

    UNNotificationRequest *request = response.notification.request;
    UNNotificationContent *conten = request.content;
    NSDictionary *userInfo = conten.userInfo;

    if ([request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"点击了远程通知");
    }else {
        NSLog(@"点击了本地通知");
    }
    NSLog(@"title:%@, subtitle:%@, body:%@, categoryIdentifier:%@, sound:%@, badge:%@, userInfo:%@, actionIdentifier:%@", conten.title, conten.subtitle, conten.body, conten.categoryIdentifier, conten.sound, conten.badge, userInfo, response.actionIdentifier);

    completionHandler();
}


#pragma mark - private

// 检查联网状态 (为了使国行手机在第一次运行App时弹出网络权限弹框, 故需要请求网络连接)
- (void)checkNetword {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];
}


/// 设置通知代理
/// 系统为App提供了内部处理通知的机会(通过user notification代理方法), 比如修改消息内容, 是否显示消息横幅或者声音等
/// 当App在前台运行时, 我们需要实现user notification的代理方法, 否则不显示通知
- (void)setNotificationDelegate {
    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
}


/// 注册通知类别 (可选实现)
/// 不同的类别用于区别不同的可操作通知(actionable notifications), 不同的可操作通知体现为: 我们可以为其定义一个或者多个不同的按钮
/// 如果实现, 系统首先根据categoryIdentifier匹配自定义的可操作通知; 如果没有, 将显示系统默认通知(没有按钮).
- (void)setNotificationCategories {
    
    /* 类别1(有一个按钮) */
    UNNotificationAction *closeAction = [UNNotificationAction actionWithIdentifier:@"CLOSE_ACTION" title:@"关闭" options:UNNotificationActionOptionNone];
    UNNotificationCategory *category1 = [UNNotificationCategory categoryWithIdentifier:@"CATEGORY1"
                                                                               actions:@[closeAction]
                                                                     intentIdentifiers:@[]
                                                                               options:UNNotificationCategoryOptionCustomDismissAction];

    /* 类别2(有四个按钮) */
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"ACTION1" title:@"按钮1" options:UNNotificationActionOptionNone];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"ACTION2" title:@"按钮2" options:UNNotificationActionOptionNone];
    UNNotificationAction *action3 = [UNNotificationAction actionWithIdentifier:@"ACTION3" title:@"按钮3" options:UNNotificationActionOptionNone];
    UNNotificationAction *action4 = [UNNotificationAction actionWithIdentifier:@"ACTION4" title:@"按钮4" options:UNNotificationActionOptionNone];
    UNNotificationCategory *category2 = [UNNotificationCategory categoryWithIdentifier:@"CATEGORY2"
                                                                               actions:@[action1, action2, action3, action4]
                                                                     intentIdentifiers:@[]
                                                                               options:UNNotificationCategoryOptionCustomDismissAction];

    // 注册上面这2个通知类别
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center setNotificationCategories:[NSSet setWithObjects:category1, category2, nil]];
}


/// 注册远程通知 (获取设备令牌)
/// 如果手机可联网, 将回调
/// 成功 application:didRegisterForRemoteNotificationsWithDeviceToken:
/// 失败 application:didFailToRegisterForRemoteNotificationsWithError:
- (void)registerRemoteNotifications {
    
    // 检查权限
    [KKAuthorizationTool checkNotificationAuthorizationWithCompletion:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }
    }];
}


// 将deviceToken转换成字符串
- (NSString *)deviceTokenStrWithDeviceToken:(NSData *)deviceToken {

    NSString *tokenStr;
    
    if (deviceToken) {
        if ([[deviceToken description] containsString:@"length = "]) {  // iOS 13 DeviceToken 适配。
            NSMutableString *deviceTokenString = [NSMutableString string];
            const char *bytes = deviceToken.bytes;
            NSInteger count = deviceToken.length;
            for (int i = 0; i < count; i++) {
                [deviceTokenString appendFormat:@"%02x", bytes[i]&0x000000FF];
            }
            tokenStr = [NSString stringWithString:deviceTokenString];
        }else {
            tokenStr = [[[[deviceToken description]stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
    
    return tokenStr;
}


@end
