//
//  Preferences.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "Preferences.h"

@implementation Preferences

+ (void)resetPreferences
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

+ (void)dumpPreferences
{
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] description]);
}

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

@end
