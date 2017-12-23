//
//  BackgroundDownloader.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 23/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "BackgroundDownloader.h"
#import "NewNoticesForPost.h"

#import <UserNotifications/UserNotifications.h>


@implementation BackgroundDownloader

- (instancetype)init
{
    self = [super init];
    if (self) {
        _identificationDataRefresh = @"dataRefresh";
    }
    return self;
}


- (void)getNewData
{
    NSString *apiRequest = [ApiBuilder apiFeedNoticesAndKeepNew:YES];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.identifitaion = _identificationDataRefresh;
    sc.delegate = self;
    [sc downloadDataForApiRequest:apiRequest];
}


- (void)downloadFinishedWithData:(NSData *)data withIdentification:(NSString *)identification
{
    if (!data)
    {
        NSLog(@"%@ - %@ : ERROR - Background [%@]", self, NSStringFromSelector(_cmd), @"No data (NSData nil)!");
    }
    else
    {
        JSONParser *jp = [[JSONParser alloc] initWithData:data];
        if (!jp.jsonDictionary)
        {
            NSLog(@"%@ - %@ : ERROR - Background [%@]", self, NSStringFromSelector(_cmd), jp.jsonErrorString);
        }
        else
        {
            if ([[jp.jsonDictionary objectForKey:@"result"] isEqualToString:@"error"])
            {
                NSLog(@"%@ - %@ : ERROR - Background [%@]", self, NSStringFromSelector(_cmd), [jp.jsonDictionary objectForKey:@"error"]);
            }
            else
            {
                if ([identification isEqualToString:_identificationDataRefresh]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self notifcationData:jp.jsonDictionary];
                    });
                }
            }
        }
    }
}

- (void)notifcationData:(NSDictionary *)data
{
    NSInteger mail = 0;
    NSInteger notification = 0;
    
    NSString *mailData = [[data objectForKey:@"system"] objectForKey:@"unread_post"];
    if (mailData && [mailData length] > 0) {
        mail = [mailData integerValue];
    }
    
    NSString *lastVisit = [[data objectForKey:@"data"] objectForKey:@"notice_last_visit"];
    NSArray *notices = [[data objectForKey:@"data"] objectForKey:@"items"];
    
//    NSInteger last = [lastVisit integerValue];
    for (NSDictionary *n in notices)
    {
//        NSInteger nTime = [[n objectForKey:@"time"] integerValue];
//        if (nTime > last) {
//            notification++;
//        }
        NewNoticesForPost *np = [[NewNoticesForPost alloc] initWithPost:n forLastVisit:lastVisit];
        if (np.nPosts && [np.nPosts count] > 0) {
            notification += [np.nPosts count];
        }
        if (np.nThumbup && [np.nThumbup count] > 0) {
            notification += [np.nThumbup count];
        }
        if (np.nThumbsdown && [np.nThumbsdown count] > 0) {
            notification += [np.nThumbsdown count];
        }
    }
    
    switch ([[UIApplication sharedApplication] applicationState]) {
        case UIApplicationStateActive:
        {
        }
            break;
        case UIApplicationStateInactive:
        {
        }
            break;
        case UIApplicationStateBackground:
        {
            if (mail || notification)
            {
                [self notifyUserWithData:data withMails:mail andNotifications:notification];
            } else {
                [self badge:0];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - BACKGROUND

- (void)notifyUserWithData:(NSDictionary *)data withMails:(NSInteger)m andNotifications:(NSInteger)n
{
    [self badge:(m + n)];
    NSString *body = [NSString stringWithFormat:@"Nové maily (%li) nebo upozornění (%li).", (long)m, (long)n];
    
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"Nyx.cz";
    content.body = body;
    content.sound = [UNNotificationSound defaultSound];
    
    NSString *identifier = @"NYXLocalNotification";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                          content:content trigger:nil];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong: %@",error);
        }
    }];
}

- (void)badge:(NSInteger)b
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:b];
}


@end
