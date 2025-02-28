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


// CONSTANTS
extern NSString* const kServerAPIURL;
extern NSInteger const kCacheMaxDays;
extern NSInteger const kLoadingCoverViewTag;
extern NSString* const kDisableTableSections;
extern NSInteger const kWidthForTableCellBodyTextViewSubstract;
extern NSInteger const kMinimumPeopleTableCellHeight;
extern NSInteger const kNavigationBarHeight;
extern NSInteger const kStatusBarStandardHeight;
extern NSInteger const kHTTPRequestTimeout;


extern NSString* const kNotificationShowError;
extern NSString* const kNotificationShowInfo;
extern NSString* const kNotificationFriendsFeedChanged;
extern NSString* const kNotificationMailboxChanged;
extern NSString* const kNotificationMailboxNewMessageFor;
extern NSString* const kNotificationDiscussionLoadNewerFrom;
extern NSString* const kNotificationListTableChanged;
extern NSString* const kNotificationAvatarTapped;


extern NSString* const kPeopleTableModeFeed;
extern NSString* const kPeopleTableModeFeedDetail;
extern NSString* const kPeopleTableModeMailbox;
extern NSString* const kPeopleTableModeMailboxDetail;
extern NSString* const kPeopleTableModeFriends;
extern NSString* const kPeopleTableModeFriendsDetail;
extern NSString* const kPeopleTableModeDiscussion;
extern NSString* const kPeopleTableModeDiscussionDetail;
extern NSString* const kPeopleTableModeNotices;
extern NSString* const kPeopleTableModeNoticesDetail;
extern NSString* const kPeopleTableModeSearch;
extern NSString* const kPeopleTableModeRatingInfo;

extern NSString* const kListTableModeBookmarks;
extern NSString* const kListTableModeHistory;

extern CGFloat const kLongPressMinimumDuration;

extern NSString* const kApiIdentificationDataForFeedOfFriends;
extern NSString* const kApiIdentificationDataForDiscussion;
extern NSString* const kApiIdentificationDataForDiscussionFromID;
extern NSString* const kApiIdentificationDataForDiscussionRefreshAfterPost;
extern NSString* const kApiIdentificationPostDelete;
extern NSString* const kApiIdentificationPostThumbs;
extern NSString* const kApiIdentificationPostRefreshThumbs;
extern NSString* const kApiIdentificationPostGetRatingInfo;
extern NSString* const kApiIdentificationDataForMailbox;
extern NSString* const kApiIdentificationDataForMailboxOlderMessages;
extern NSString* const kApiIdentificationDataForFriendList;
extern NSString* const kApiIdentificationDataForNotices;
extern NSString* const kApiIdentificationDataForSearch;
extern NSString* const kApiIdentificationDataForSearchOlder;
extern NSString* const kApiIdentificationDataForSearchMailbox;
extern NSString* const kApiIdentificationDataForSearchMailboxOlder;
extern NSString* const kApiIdentificationDataForSearchDiscussion;
extern NSString* const kApiIdentificationDataForSearchDiscussionOlder;
extern NSString* const kApiIdentificationDataForBookmarks;
extern NSString* const kApiIdentificationDataForHistory;
extern NSString* const kApiIdentificationDataForLogin;
extern NSString* const kApiIdentificationDataForApnsRegistration;

extern NSString* const kApnsClientNameDev;
extern NSString* const kApnsClientNameProd;


// THEMES
extern NSString* const kThemeLight;
extern NSString* const kThemeDark;

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
extern NSString* const kApiDiscussionRatingGive;
extern NSString* const kApiDiscussionRatingInfo;

extern NSString* const kApiEvents;

extern NSString* const kApiFeed;
extern NSString* const kApiFeedFriends;
extern NSString* const kApiFeedEntry;
extern NSString* const kApiFeedSendComment;
extern NSString* const kApiFeedDeleteComment;
extern NSString* const kApiFeedDeleteEntry;
extern NSString* const kApiFeedSendPost;
extern NSString* const kApiFeedSendNotices;

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

extern NSString* const kApiSearch;
extern NSString* const kApiSearchWriteups;

extern NSString* const kApiUtil;
extern NSString* const kApiUtilMakeInactive;
extern NSString* const kApiUtilRemoveAuthorization;


// Menu constants
extern NSString* const kMenuOverview;
extern NSString* const kMenuMail;
extern NSString* const kMenuBookmarks;
extern NSString* const kMenuHistory;
extern NSString* const kMenuFriendList;
extern NSString* const kMenuNotifications;
extern NSString* const kMenuSearchPosts;
extern NSString* const kMenuMarket;
extern NSString* const kMenuCalendar;


// Main buttons - logout, contact, settings
extern NSString* const kMainButtonNotification;
extern NSString* const kMainButtonLogout;
extern NSString* const kMainButtonContact;
extern NSString* const kMainButtonSettings;

// APNS
extern NSString* const kApiApns;
extern NSString* const kApiApnsRegister;
extern NSString* const kApiApnsTest;


// MACROS
#define PRESENT_ERROR(s,ss) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowError object:nil userInfo:@{@"title" : (s), @"error" : (ss)}];
#define PRESENT_INFO(s,ss) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowInfo object:nil userInfo:@{@"title" : (s), @"info" : (ss)}];

#define NOTIFICATION_MAIN_BUTTON_PRESSED(s) [[NSNotificationCenter defaultCenter] postNotificationName:kMainButtonNotification object:nil userInfo:@{@"button" : (s)}];

#define POST_NOTIFICATION_FRIENDS_FEED_CHANGED [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFriendsFeedChanged object:nil userInfo:nil];
#define POST_NOTIFICATION_MAILBOX_CHANGED [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMailboxChanged object:nil userInfo:nil];
#define POST_NOTIFICATION_MAILBOX_NEW_MESSAGE_FOR(s) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMailboxNewMessageFor object:nil userInfo:@{@"nKey" : (s)}];

#define POST_NOTIFICATION_DISCUSSION_LOAD_NEWER_FROM(s) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDiscussionLoadNewerFrom object:nil userInfo:@{@"nKey" : (s)}];

#define POST_NOTIFICATION_LIST_TABLE_CHANGED [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationListTableChanged object:nil userInfo:nil];

#define NOTIFICATION_AVATARTAPPED(s,ss) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAvatarTapped object:nil userInfo:@{@"idxPath" : (s), @"nick" : (ss)}];


#define PERFSTART NSDate *now = [NSDate date];
#define PERFSTOP NSLog(@"%@ / %@: TIME : %f", [self class], NSStringFromSelector(_cmd), [[NSDate date] timeIntervalSinceDate:now]);
#define PERFSTART1 NSDate *now1 = [NSDate date];
#define PERFSTOP1 NSLog(@"%@ / %@: TIME 1 : %f", [self class], NSStringFromSelector(_cmd), [[NSDate date] timeIntervalSinceDate:now1]);
#define PERFSTART2 NSDate *now2 = [NSDate date];
#define PERFSTOP2 NSLog(@"%@ / %@: TIME 2 : %f", [self class], NSStringFromSelector(_cmd), [[NSDate date] timeIntervalSinceDate:now2]);


@end
