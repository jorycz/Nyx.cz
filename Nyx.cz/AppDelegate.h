//
//  AppDelegate.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <UserNotifications/UserNotifications.h>

#import "UserNotification.h"
#import "MainVC.h"
#import "MemCache.h"
#import "BackgroundDownloader.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>
{
    UIBackgroundTaskIdentifier _backgroundTask;
}


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UserNotification *userNotification;
@property (nonatomic, strong) MainVC *mainScreen;
@property (nonatomic, strong) MemCache *memoryCache;
@property (nonatomic, strong) BackgroundDownloader *bgd;
@property (nonatomic, strong) UINavigationController *mainNavigationController;

@property (readonly, strong) NSPersistentContainer *persistentContainer;


- (void)saveContext;

- (MemCache *)memCache;


@end

