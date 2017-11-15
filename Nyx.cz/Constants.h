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


@end
