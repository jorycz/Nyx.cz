//
//  AppDelegate.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "AppDelegate.h"
#import "Preferences.h"
#import "Colors.h"

#import <AVFoundation/AVFoundation.h>


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
    [Preferences setupPreferences];
    
    self.mainScreen = [[MainVC alloc] init];
    UINavigationController *mainNavigationController = [[UINavigationController alloc] initWithRootViewController:self.mainScreen];
    mainNavigationController.navigationBar.tintColor = COLOR_SYSTEM_TURQUOISE;
    
    // IN CALL STATUS BAR
    // Not needed with willChangeStatusBarFrame and didChangeStatusBarFrame methods above.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inCallBar:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inCallBar:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    // Notification Top Bar Init.
    self.userNotification = [[UserNotification alloc] init];
    
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
                                                                                            NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @" - Registering for PUSH Notifications!");
                                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                [[UIApplication sharedApplication] registerForRemoteNotifications];
                                                                                            });
                                                                                        } else {
                                                                                            NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"DENIED");
                                                                                            NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), error.localizedRecoveryOptions);
                                                                                            NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), error.localizedRecoverySuggestion);
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
    
    // HANDLE LAUNCH FROM NOTIFICATION
    if (launchOptions != nil)
    {
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"Launched from push notification.");
            [self manageRemoteNotification:dictionary];
        }
    }
    
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

#pragma mark - DEVICE TOKEN DATA TO STRING

- (NSString *)stringWithDeviceToken:(NSData *)deviceToken
{
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    
    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    return [token copy];
}

#pragma mark - PUSH NOTIFICATIONS

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), deviceToken);
    NSString *token = [self stringWithDeviceToken:deviceToken];
    if (token && [token length] > 0)
    {
//        NSLog(@"%@ - %@ : APNS DEVICE TOKEN [%@]", self, NSStringFromSelector(_cmd), token);
        [Preferences apnsDeviceToken:token];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"!!! ERROR REGISTERING REMOTE PUSH NOTIFICATIONS - NO TOKEN !!!");
    NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), error.localizedDescription);
    NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), error.localizedRecoveryOptions);
    NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), error.localizedRecoverySuggestion);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"REMOTE SILENT NOTIFICATION ARRIVED.");
    
    if(application.applicationState == UIApplicationStateInactive)
    {
        NSLog(@"Inactive - the user has tapped in the notification when app was closed or in background");
        //do some tasks
        [self manageRemoteNotification:userInfo];
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if (application.applicationState == UIApplicationStateBackground)
    {
        NSLog(@"application Background - notification has arrived when app was in background");
        NSString* contentAvailable = [NSString stringWithFormat:@"%@", [[userInfo valueForKey:@"aps"] valueForKey:@"content-available"]];
        if([contentAvailable isEqualToString:@"1"]) {
            // do tasks
            [self manageRemoteNotification:userInfo];
            NSLog(@"content-available is equal to 1");
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }
    else
    {
        NSLog(@"application Active - notication has arrived while app was opened");
        //Show an in-app banner
        //do tasks
        [self manageRemoteNotification:userInfo];
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

- (void)manageRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@ - %@ : ==> NOTIFICATION DATA [%@]", self, NSStringFromSelector(_cmd), userInfo);
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
    
//    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
//
//        switch (settings.authorizationStatus) {
//            case UNAuthorizationStatusAuthorized:
//            {
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    self.bgd = [[BackgroundDownloader alloc] init];
//                    [self.bgd getNewData];
//                });
//                completionHandler(UIBackgroundFetchResultNewData);
//            }
//                break;
//            default:
//                completionHandler(UIBackgroundFetchResultNoData);
//                break;
//        }
//    }];
}


@end




