//
//  Preferences.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "Preferences.h"
#import "Constants.h"

@implementation Preferences

#pragma mark - !!! DELETE ALL PREFERENCES STORAGE !!!

//+ (void)resetPreferences
//{
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
//}

+ (void)dumpPreferences
{
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] description]);
}

#pragma mark - AUTHORIZATION

+ (NSString *)username:(NSString *)value
{
    NSString *key = @"_USERNAME";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
}

+ (NSString *)password:(NSString *)value
{
    NSString *key = @"_PASSWORD";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
}

+ (NSString *)auth_nick:(NSString *)value
{
    NSString *key = @"_AUTH_NICK";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
}

+ (NSString *)auth_token:(NSString *)value
{
    NSString *key = @"_AUTH_TOKEN";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
}

#pragma mark - UTILITY

+ (NSArray *)messagesForDiscussion:(NSMutableArray *)value
{
    NSString *key = @"_STOREDMESSAGESFORDISCUSSION";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
}

+ (NSString *)actualDateOfBackgroundRefresh:(NSString *)value
{
    NSString *key = @"_TIMEOFBACKGROUNDREFRESH";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
}

+ (NSString *)apnsDeviceToken:(NSString *)value
{
    NSString *key = @"_APNSDEVICETOKEN";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
}

+ (NSString *)apnsRegistrationStatus:(NSString *)value
{
    NSString *key = @"_APNSREGSTATUS";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
}

+ (CGFloat)statusNavigationBarsHeights:(CGFloat)value
{
    NSString *key = @"_STATUSANDNAVIGATIONBARHEIGHTS";
    if (value > 0) {
        [[NSUserDefaults standardUserDefaults] setFloat:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return 0;
    } else {
        return [[NSUserDefaults standardUserDefaults] floatForKey:key];
    }
}


#pragma mark - USER PREFERENCES / USER SETTINGS

+ (void)setupPreferencesUsingForce:(BOOL)force
{
    NSString *key = @"_FIRST_RUN_";
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:key];
        // First run EVER SETUP.
    }
    
    // Setup DEFAULTS:
    
    if (force)
    {
        [self lastUserPosition:@""];
        [self preferredStartingLocation:@""];
        [self showImagesInlineInPost:@""];
        [self openUrlsInSafari:@""];
    }
    
    if (![self shareFullSizeImages:nil] || force)
        [self shareFullSizeImages:@"yes"];
    if (![self maximumUnreadPostsLoad:nil]  || force)
        [self maximumUnreadPostsLoad:@"500"];
    if (![self allowCopyOfHTMLSourceCode:nil]  || force)
        [self allowCopyOfHTMLSourceCode:@""];
    if (![self theme:nil]  || force)
        [self theme:kThemeLight];
}

+ (NSString *)lastUserPosition:(NSString *)value
{
    NSString *key = @"_LASTUSERPOSITION";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
}

+ (NSString *)preferredStartingLocation:(NSString *)value
{
    NSString *key = @"_PREFERREDSTARTINGLOCATION";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
}

+ (NSString *)showImagesInlineInPost:(NSString *)value
{
    NSString *key = @"_INLINEIMAGES";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
}

+ (NSString *)openUrlsInSafari:(NSString *)value
{
    NSString *key = @"_URLSINSAFARI";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
}

+ (NSString *)shareFullSizeImages:(NSString *)value
{
    NSString *key = @"_SHAREFULLSIZEIMAGES";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
}

+ (NSString *)maximumUnreadPostsLoad:(NSString *)value
{
    NSString *key = @"_MAXIMUMUNREADPOSTSLOAD";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
}

+ (NSString *)allowCopyOfHTMLSourceCode:(NSString *)value
{
    NSString *key = @"_ALLOWCOPYHTMLSOURCE";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
}

+ (NSString *)theme:(NSString *)value
{
    NSString *key = @"_THEME";
    if (value) {
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    } else {
        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
}


@end

