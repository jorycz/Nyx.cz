//
//  Preferences.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject


+ (void)resetPreferences;

// SIMULATOR ONLY -----------------------
+ (NSString *)username:(NSString *)value;
+ (NSString *)password:(NSString *)value;
// --------------------------------------

+ (NSString *)auth_nick:(NSString *)value;
+ (NSString *)auth_token:(NSString *)value;


+ (NSString *)lastUserPosition:(NSString *)value;
+ (NSString *)preferredStartingLocation:(NSString *)value;
+ (NSString *)showImagesInlineInPost:(NSString *)value;


@end
