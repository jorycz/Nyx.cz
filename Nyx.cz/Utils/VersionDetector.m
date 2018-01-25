//
//  VersionDetector.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 25/01/2018.
//  Copyright © 2018 Josef Rysanek. All rights reserved.
//

#import "VersionDetector.h"
#import <UIKit/UIKit.h>


@implementation VersionDetector


+ (BOOL)isAppStoreVersionInstalled
{
    // Detect iPhone Simulator
    BOOL isSimulator = NO;
    if ([[[NSProcessInfo processInfo] environment] objectForKey:@"SIMULATOR_DEVICE_NAME"])
    {
        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"Simulator detected.");
        isSimulator = YES;
    } else {
        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), [[UIDevice currentDevice] model]);
    }
    
    // TOKNOW AppStore distribution install detection !
    NSString *provisionPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:provisionPath] || isSimulator)
    {
        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @" -> Developer install.");
        return NO;
    }
    else
    {
        // Appstore version
        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @" -> AppStore install.");
        return YES;
    }
}


@end
