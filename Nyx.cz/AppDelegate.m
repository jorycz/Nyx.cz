//
//  AppDelegate.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "Preferences.h"

#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>


@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - IN CALL STATUS BAR

//- (void)inCallBar:(NSNotification *)notification
//{
//}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame
{
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), NSStringFromCGRect(newStatusBarFrame));
    NSLog(@"%@ - %@ : StatusBar height will change to [%li]", self, NSStringFromSelector(_cmd), (long)newStatusBarFrame.size.height);
    CGFloat c = newStatusBarFrame.size.height;
    [Preferences statusBarHeigh:c];
}

//- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
//{
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), NSStringFromCGRect(oldStatusBarFrame));
//}

#pragma mark - INIT

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.mainScreen = [[MainVC alloc] init];
    UINavigationController *mainNavigationController = [[UINavigationController alloc] initWithRootViewController:self.mainScreen];
    mainNavigationController.navigationBar.tintColor = COLOR_SYSTEM_TURQUOISE;
    
    // IN CALL STATUS BAR
    // Not needed with willChangeStatusBarFrame and didChangeStatusBarFrame methods above.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inCallBar:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inCallBar:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    [self initNotificationTopBar];
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), [paths objectAtIndex:0]);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = UIColorFromRGB(0xBAE0FF);
    self.window.rootViewController = mainNavigationController;
    [self.window makeKeyAndVisible];

    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusNotDetermined:
            {
                [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert|
                                                                                                       UNAuthorizationOptionSound|
                                                                                                       UNAuthorizationOptionBadge|
                                                                                                       UNAuthorizationOptionCarPlay)
                                                                                    completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                                                                        // Enable or disable features based on authorization.
                                                                                        if (granted) {
                                                                                            NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"GRANTED");
                                                                                        } else {
                                                                                            NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"DENIED");
                                                                                        }
                                                                                    }];
            }
                break;
                
            case UNAuthorizationStatusAuthorized:
                break;
                
            case UNAuthorizationStatusDenied:
                NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"NOTIFICATIONS DENIED!");
                break;
                
            default:
                break;
        }
    }];
    
    // Set background fetch interval - when set to "Minimum", it's enabled.
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Nyx_cz"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - NOTIFICATION TOP BAR INIT

- (void)initNotificationTopBar
{
    UserNotification *un = [[UserNotification alloc] init];
    self.userNotification = un;
}

#pragma mark - MEMORY CACHE

- (MemCache *)memCache
{
    if (!self.memoryCache) {
        self.memoryCache = [[MemCache alloc] init];
    }
    return self.memoryCache;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"Clearing memory cache.");
    self.memoryCache = nil;
}

#pragma mark - BACKGROUND REFRESH NOTIFICATION DATA

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    switch (application.applicationState) {
        case UIApplicationStateActive:
            NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"ACTIVE");
            break;
        case UIApplicationStateInactive:
            NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"INACTIVE");
            break;
        case UIApplicationStateBackground:
            NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"BACKGROUND");
            break;
        default:
            break;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    [Preferences actualDateOfBackgroundRefresh:dateStr];
    
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        BOOL badge = NO;
        
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusAuthorized:
                badge = YES;
                break;
            default:
                break;
        }
        
        if (badge) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.mainScreen getNewNyxNotifications];
            });
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }];
}

@end


