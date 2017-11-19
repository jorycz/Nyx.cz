//
//  Constants.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

// DEFINES
#define PRESENT_ERROR(s,ss) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowError object:nil userInfo:@{@"title" : (s), @"error" : (ss)}];
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


// CONSTANTS
extern NSString* const kServerAPIURL;
extern NSInteger const kCacheMaxDays;
extern NSString* const kNotificationShowError;

// API
extern NSString* const kApiLoguser;
extern NSString* const kApiLogpass;

extern NSString* const kApiBookmarks;

extern NSString* const kApiDiscussion;

extern NSString* const kApiEvents;

extern NSString* const kApiFeed;

extern NSString* const kApiMail;

extern NSString* const kApiMarket;

extern NSString* const kApiPeople;
extern NSString* const kApiPeopleStatus;

// Menu constants
extern NSString* const kMenuHome;
extern NSString* const kMenuMail;
extern NSString* const kMenuBookmarks;
extern NSString* const kMenuHistory;
extern NSString* const kMenuPeople;
extern NSString* const kMenuNotifications;
extern NSString* const kMenuSearchPosts;


@end
