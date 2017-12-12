//
//  Constants.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "Constants.h"


@implementation Constants


// CONSTANTS
NSString *const kServerAPIURL = @"https://www.nyx.cz/api.php";
NSInteger const kCacheMaxDays = 31;
NSInteger const kLoadingCoverViewTag = 666;
NSString* const kDisableTableSections = @"kDisableTableSections";
NSInteger const kWidthForTableCellBodyTextViewSubstract = 60;
NSInteger const kMinimumPeopleTableCellHeight = 45;
NSInteger const kNavigationBarHeight = 44;
NSInteger const kStatusBarStandardHeight = 20;

NSString* const kNotificationShowError = @"kNotificationShowError";
NSString* const kNotificationFriendsFeedChanged = @"kNotificationFriendsFeedChanged";
NSString* const kNotificationMailboxChanged = @"kNotificationMailboxChanged";
NSString* const kNotificationMailboxLoadFrom = @"kNotificationMailboxLoadFrom";
NSString* const kNotificationMailboxNewMessageFor = @"kNotificationMailboxNewMessageFor";
NSString* const kNotificationDiscussionLoadOlderFrom = @"kNotificationDiscussionLoadOlderFrom";
NSString* const kNotificationDiscussionLoadNewerFrom = @"kNotificationDiscussionLoadNewerFrom";
NSString* const kNotificationListTableChanged = @"kNotificationListTableChanged";
NSString* const kNotificationPeopleChanged = @"kNotificationPeopleChanged";
NSString* const kNotificationNoticesChanged = @"kNotificationNoticesChanged";


NSString* const kPeopleTableModeFeed = @"kPeopleTableModeFeed";
NSString* const kPeopleTableModeFeedDetail = @"kPeopleTableModeFeedDetail";
NSString* const kPeopleTableModeMailbox = @"kPeopleTableModeMailbox";
NSString* const kPeopleTableModeMailboxDetail = @"kPeopleTableModeMailboxDetail";
NSString* const kPeopleTableModeFriends = @"kPeopleTableModeFriends";
NSString* const kPeopleTableModeFriendsDetail = @"kPeopleTableModeFriendsDetail";
NSString* const kPeopleTableModeDiscussion = @"kPeopleTableModeDiscussion";
NSString* const kPeopleTableModeDiscussionDetail = @"kPeopleTableModeDiscussionDetail";
NSString* const kPeopleTableModeNotices = @"kPeopleTableModeNotices";
NSString* const kPeopleTableModeNoticesDetail = @"kPeopleTableModeNoticesDetail";
NSString* const kPeopleTableModeSearch = @"kPeopleTableModeSearch";

CGFloat const kLongPressMinimumDuration = 0.3f;

// API
NSString* const kApiLoguser = @"loguser";
NSString* const kApiLogpass = @"logpass";

// API - first row is always l and all below are l2
NSString* const kApiBookmarks = @"bookmarks";
NSString* const kApiBookmarksAll = @"all";
NSString* const kApiBookmarksHistory = @"history";

NSString* const kApiDiscussion = @"discussion";
NSString* const kApiDiscussionMessages = @"messages";
NSString* const kApiDiscussionSend = @"send";
NSString* const kApiDiscussionDelete = @"delete";
NSString* const kApiDiscussionRatingGive = @"rating_give";
NSString* const kApiDiscussionRatingInfo = @"rating_info";

NSString* const kApiEvents = @"events";

NSString* const kApiFeed = @"feed";
NSString* const kApiFeedFriends = @"friends";
NSString* const kApiFeedEntry = @"entry";
NSString* const kApiFeedSendComment = @"send_comment";
NSString* const kApiFeedDeleteComment = @"delete_comment";
NSString* const kApiFeedDeleteEntry = @"delete_entry";
NSString* const kApiFeedSendPost = @"send";
NSString* const kApiFeedSendNotices = @"notices";

NSString* const kApiMail = @"mail";
NSString* const kApiMailMessages = @"messages";
NSString* const kApiMailMessageSend = @"send";
NSString* const kApiMailDeleteMessage = @"delete";
NSString* const kApiMailMessageSendWithAttachment = @"kApiMailMessageSendWithAttachment";

NSString* const kApiMarket = @"market";

NSString* const kApiPeople = @"people";
NSString* const kApiPeopleStatus = @"status";
NSString* const kApiPeopleAutocomplete = @"autocomplete";
NSString* const kApiPeopleFriends = @"friends";

NSString* const kApiSearch = @"search";
NSString* const kApiSearchWriteups = @"writeups";

NSString* const kApiUtil = @"util";
NSString* const kApiUtilMakeInactive = @"make_inactive";
NSString* const kApiUtilRemoveAuthorization = @"remove_authorization";


// Menu constants
NSString* const kMenuOverview = @"Přehled";
NSString* const kMenuMail = @"Pošta";
NSString* const kMenuBookmarks = @"Sledované";
NSString* const kMenuHistory = @"Historie";
NSString* const kMenuPeople = @"Lidé";
NSString* const kMenuNotifications = @"Upozornění";
NSString* const kMenuSearchPosts = @"Hledání příspěvků";

// Main buttons - logout, contact, settings
NSString* const kMainButtonNotification = @"kMainButtonNotification";
NSString* const kMainButtonLogout = @"kMainButtonLogout";
NSString* const kMainButtonContact = @"kMainButtonContact";
NSString* const kMainButtonSettings = @"kMainButtonSettings";



@end
