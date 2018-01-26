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
NSInteger const kHTTPRequestTimeout = 15;

NSString* const kNotificationShowError = @"kNotificationShowError";
NSString* const kNotificationShowInfo = @"kNotificationShowInfo";
NSString* const kNotificationFriendsFeedChanged = @"kNotificationFriendsFeedChanged";
NSString* const kNotificationMailboxChanged = @"kNotificationMailboxChanged";
NSString* const kNotificationMailboxNewMessageFor = @"kNotificationMailboxNewMessageFor";
NSString* const kNotificationDiscussionLoadNewerFrom = @"kNotificationDiscussionLoadNewerFrom";
NSString* const kNotificationListTableChanged = @"kNotificationListTableChanged";
NSString* const kNotificationAvatarTapped = @"kNotificationAvatarTapped";


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
NSString* const kPeopleTableModeRatingInfo = @"kPeopleTableModeRatingInfo";

NSString* const kListTableModeBookmarks = @"kListTableModeBookmarks";
NSString* const kListTableModeHistory = @"kListTableModeHistory";

CGFloat const kLongPressMinimumDuration = 0.3f;

NSString* const kApiIdentificationDataForFeedOfFriends = @"kApiIdentificationDataForFeedOfFriends";
NSString* const kApiIdentificationDataForDiscussion = @"kApiIdentificationDataForDiscussion";
NSString* const kApiIdentificationDataForDiscussionFromID = @"kApiIdentificationDataForDiscussionFromID";
NSString* const kApiIdentificationDataForDiscussionRefreshAfterPost = @"kApiIdentificationDataForDiscussionRefreshAfterPost";
NSString* const kApiIdentificationPostDelete = @"kApiIdentificationPostDelete";
NSString* const kApiIdentificationPostThumbs = @"kApiIdentificationPostThumbs";
NSString* const kApiIdentificationPostRefreshThumbs = @"kApiIdentificationPostRefreshThumbs";
NSString* const kApiIdentificationPostGetRatingInfo = @"kApiIdentificationPostGetRatingInfo";
NSString* const kApiIdentificationDataForMailbox = @"kApiIdentificationDataForMailbox";
NSString* const kApiIdentificationDataForMailboxOlderMessages = @"kApiIdentificationDataForMailboxOlderMessages";
NSString* const kApiIdentificationDataForFriendList = @"kApiIdentificationDataForFriendList";
NSString* const kApiIdentificationDataForNotices = @"kApiIdentificationDataForNotices";
NSString* const kApiIdentificationDataForSearch = @"kApiIdentificationDataForSearch";
NSString* const kApiIdentificationDataForSearchOlder = @"kApiIdentificationDataForSearchOlder";
NSString* const kApiIdentificationDataForSearchMailbox = @"kApiIdentificationDataForSearchMailbox";
NSString* const kApiIdentificationDataForSearchMailboxOlder = @"kApiIdentificationDataForSearchMailboxOlder";
NSString* const kApiIdentificationDataForSearchDiscussion = @"kApiIdentificationDataForSearchDiscussion";
NSString* const kApiIdentificationDataForSearchDiscussionOlder = @"kApiIdentificationDataForSearchDiscussionOlder";
NSString* const kApiIdentificationDataForBookmarks = @"kApiIdentificationDataForBookmarks";
NSString* const kApiIdentificationDataForHistory = @"kApiIdentificationDataForHistory";
NSString* const kApiIdentificationDataForLogin = @"kApiIdentificationDataForLogin";
NSString* const kApiIdentificationDataForApnsRegistration = @"kApiIdentificationDataForApnsRegistration";


NSString* const kApnsClientNameDev = @"alias-dev";
NSString* const kApnsClientNameProd = @"alias";

// THEMES
NSString* const kThemeLight = @"Světlé";
NSString* const kThemeDark = @"Tmavé";

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
NSString* const kMenuFriendList = @"Lidé";
NSString* const kMenuNotifications = @"Upozornění";
NSString* const kMenuSearchPosts = @"Hledání příspěvků";
NSString* const kMenuMarket = @"Tržiště";
NSString* const kMenuCalendar = @"Kalendář";

// Main buttons - logout, contact, settings
NSString* const kMainButtonNotification = @"kMainButtonNotification";
NSString* const kMainButtonLogout = @"kMainButtonLogout";
NSString* const kMainButtonContact = @"kMainButtonContact";
NSString* const kMainButtonSettings = @"kMainButtonSettings";

// APNS
NSString* const kApiApns = @"apns";
NSString* const kApiApnsRegister = @"register";
NSString* const kApiApnsTest = @"test";



@end
