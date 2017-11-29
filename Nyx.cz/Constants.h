//
//  Constants.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>
// CGFloat
#import <UIKit/UIKit.h>


@interface Constants : NSObject

// DEFINES
#define PRESENT_ERROR(s,ss) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowError object:nil userInfo:@{@"title" : (s), @"error" : (ss)}];
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define NOTIFICATION_MAIN_BUTTON_PRESSED(s) [[NSNotificationCenter defaultCenter] postNotificationName:kMainButtonNotification object:nil userInfo:@{@"button" : (s)}];

#define POST_NOTIFICATION_FRIENDS_FEED_CHANGED [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFriendsFeedChanged object:nil userInfo:nil];

#define POST_NOTIFICATION_MAILBOX_CHANGED [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMailboxChanged object:nil userInfo:nil];
#define POST_NOTIFICATION_MAILBOX_LOAD_FROM(s) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMailboxLoadFrom object:nil userInfo:@{@"nKey" : (s)}];
#define POST_NOTIFICATION_MAILBOX_NEW_MESSAGE_FOR(s) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMailboxNewMessageFor object:nil userInfo:@{@"nKey" : (s)}];

#define POST_NOTIFICATION_DISCUSSION_LOAD_OLDER_FROM(s) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDiscussionLoadOlderFrom object:nil userInfo:@{@"nKey" : (s)}];
#define POST_NOTIFICATION_DISCUSSION_LOAD_NEWER_FROM(s) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDiscussionLoadNewerFrom object:nil userInfo:@{@"nKey" : (s)}];

#define POST_NOTIFICATION_LIST_TABLE_CHANGED [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationListTableChanged object:nil userInfo:nil];

#define PERFSTART NSDate *now = [NSDate date];
#define PERFSTOP NSLog(@"%@ / %@: TIME : %f", [self class], NSStringFromSelector(_cmd), [[NSDate date] timeIntervalSinceDate:now]);
#define PERFSTART1 NSDate *now1 = [NSDate date];
#define PERFSTOP1 NSLog(@"%@ / %@: TIME 1 : %f", [self class], NSStringFromSelector(_cmd), [[NSDate date] timeIntervalSinceDate:now1]);
#define PERFSTART2 NSDate *now2 = [NSDate date];
#define PERFSTOP2 NSLog(@"%@ / %@: TIME 2 : %f", [self class], NSStringFromSelector(_cmd), [[NSDate date] timeIntervalSinceDate:now2]);


#define COLOR_SYSTEM_TURQUOISE UIColorFromRGB(0x3fbeb8)
#define COLOR_SYSTEM_TURQUOISE_LIGHT UIColorFromRGB(0xEBFFFE)

// CONSTANTS
extern NSString* const kServerAPIURL;
extern NSInteger const kCacheMaxDays;
extern NSInteger const kLoadingCoverViewTag;
extern NSString* const kDisableTableSections;
extern NSInteger const kWidthForTableCellBodyTextViewSubstract;
extern NSInteger const kNavigationBarHeight;
extern NSInteger const kStatusBarStandardHeight;


extern NSString* const kNotificationShowError;
extern NSString* const kNotificationFriendsFeedChanged;
extern NSString* const kNotificationMailboxChanged;
extern NSString* const kNotificationMailboxLoadFrom;
extern NSString* const kNotificationMailboxNewMessageFor;
extern NSString* const kNotificationDiscussionLoadOlderFrom;
extern NSString* const kNotificationDiscussionLoadNewerFrom;
extern NSString* const kNotificationListTableChanged;

extern NSString* const kPeopleTableModeFeed;
extern NSString* const kPeopleTableModeFeedDetail;
extern NSString* const kPeopleTableModeMailbox;
extern NSString* const kPeopleTableModeMailboxDetail;
extern NSString* const kPeopleTableModeFriends;
extern NSString* const kPeopleTableModeFriendsDetail;
extern NSString* const kPeopleTableModeDiscussion;
extern NSString* const kPeopleTableModeDiscussionDetail;

extern CGFloat const kLongPressMinimumDuration;

// API
extern NSString* const kApiLoguser;
extern NSString* const kApiLogpass;

// API - first row is always l and all below are l2
extern NSString* const kApiBookmarks;
extern NSString* const kApiBookmarksAll;
extern NSString* const kApiBookmarksHistory;

extern NSString* const kApiDiscussion;
extern NSString* const kApiDiscussionMessages;
extern NSString* const kApiDiscussionSend;
extern NSString* const kApiDiscussionDelete;

extern NSString* const kApiEvents;

extern NSString* const kApiFeed;
extern NSString* const kApiFeedFriends;
extern NSString* const kApiFeedEntry;
extern NSString* const kApiFeedSendComment;
extern NSString* const kApiFeedDeleteComment;
extern NSString* const kApiFeedDeleteEntry;
extern NSString* const kApiFeedSendPost;

extern NSString* const kApiMail;
extern NSString* const kApiMailMessages;
extern NSString* const kApiMailMessageSend;
extern NSString* const kApiMailDeleteMessage;
extern NSString* const kApiMailMessageSendWithAttachment;

extern NSString* const kApiMarket;

extern NSString* const kApiPeople;
extern NSString* const kApiPeopleStatus;
extern NSString* const kApiPeopleAutocomplete;
extern NSString* const kApiPeopleFriends;


// Menu constants
extern NSString* const kMenuOverview;
extern NSString* const kMenuMail;
extern NSString* const kMenuBookmarks;
extern NSString* const kMenuHistory;
extern NSString* const kMenuPeople;
extern NSString* const kMenuNotifications;
extern NSString* const kMenuSearchPosts;

// Main buttons - logout, contact, settings
extern NSString* const kMainButtonNotification;
extern NSString* const kMainButtonLogout;
extern NSString* const kMainButtonContact;
extern NSString* const kMainButtonSettings;


@end
