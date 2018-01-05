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

+ (void)setupPreferences;
+ (NSString *)lastUserPosition:(NSString *)value;
+ (NSString *)preferredStartingLocation:(NSString *)value;
+ (NSString *)showImagesInlineInPost:(NSString *)value;
+ (NSString *)openUrlsInSafari:(NSString *)value;
+ (NSString *)shareFullSizeImages:(NSString *)value;
+ (NSString *)maximumUnreadPostsLoad:(NSString *)value;
+ (NSString *)allowCopyOfHTMLSourceCode:(NSString *)value;


// UTILITY

// Cache for not finished messages
+ (NSArray *)messagesForDiscussion:(NSMutableArray *)value;
// Current status bar
+ (CGFloat)statusBarHeigh:(CGFloat)value;
// Save / Load time of background refresh
+ (NSString *)actualDateOfBackgroundRefresh:(NSString *)value;


@end
