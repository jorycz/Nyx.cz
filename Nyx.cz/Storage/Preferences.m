//
//  Preferences.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "Preferences.h"

@implementation Preferences

#pragma mark - !!! DELETE ALL PREFERENCES STORAGE !!!

+ (void)resetPreferences
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

+ (void)dumpPreferences
{
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] description]);
}

#pragma mark - AUTHORIZATION

//+ (NSString *)username:(NSString *)value
//{
//    NSString *key = @"_USERNAME";
//    if (value) {
//        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        return nil;
//    } else {
//        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
//    }
//}
//
//+ (NSString *)password:(NSString *)value
//{
//    NSString *key = @"_PASSWORD";
//    if (value) {
//        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        return nil;
//    } else {
//        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
//    }
//}

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

#pragma mark - PREFERENCES / SETTINGS

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


@end


