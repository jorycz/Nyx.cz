//
//  Preferences.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>
// CGFloat
#import <UIKit/UIKit.h>


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
+ (NSString *)openUrlsInSafari:(NSString *)value;

// Cache for not finished messages
+ (NSArray *)messagesForDiscussion:(NSMutableArray *)value;
// Current status bar
+ (CGFloat)statusBarHeigh:(CGFloat)value;
// Save / Load time of background refresh
+ (NSString *)actualDateOfBackgroundRefresh:(NSString *)value;


@end
