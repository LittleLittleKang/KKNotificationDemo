//
//  NotificationViewController.m
//  ContentExtension
//
//  Created by 看影成痴 on 2020/6/6.
//  Copyright © 2020 看影成痴. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
    NSLog(@"%s", __func__);
}

- (void)didReceiveNotification:(UNNotification *)notification {
    NSLog(@"%s", __func__);
    
    self.label.text = notification.request.content.title;
    self.subLabel.text = notification.request.content.subtitle;
    self.bodyLabel.text = notification.request.content.body;
    
    // 如果附件是图片, 显示之
    NSDictionary *dict =  notification.request.content.userInfo;
    if (dict.count) {
        NSData *imageData = dict[@"imageData"];
        UIImage *image = [UIImage imageWithData:imageData];
        self.imageView.image = image;
    }
}

@end
