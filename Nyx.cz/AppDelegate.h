//
//  AppDelegate.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "UserNotification.h"
#import "MainVC.h"
#import "MemCache.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIBackgroundTaskIdentifier _backgroundTask;
}


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UserNotification *userNotification;
@property (nonatomic, strong) MainVC *mainScreen;
@property (nonatomic, strong) MemCache *memoryCache;

@property (readonly, strong) NSPersistentContainer *persistentContainer;


- (void)saveContext;

- (MemCache *)memCache;


@end

