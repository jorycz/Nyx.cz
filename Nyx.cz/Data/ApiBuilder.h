//
//  ApiBuilder.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Preferences.h"


@interface ApiBuilder : NSObject

// AUTH
+ (NSString *)apiAuthorizeForUser:(NSString *)user;

// API URLs
+ (NSString *)apiPeopleStatusForNick:(NSString *)value;
+ (NSString *)apiPeopleAutocompleteForNick:(NSString *)nick;
+ (NSString *)apiPeopleFriends;

+ (NSString *)apiFeedOfFriends;
+ (NSString *)apiFeedOfFriendsPostsFor:(NSString *)nick withId:(NSString *)postId;
+ (NSString *)apiFeedOfFriendsPostCommentAs:(NSString *)nick withId:(NSString *)postId sendMessage:(NSString *)message;
+ (NSString *)apiFeedOfFriendsDeleteCommentAs:(NSString *)nick withId:(NSString *)postId commentId:(NSString *)commentId;
+ (NSString *)apiFeedOfFriendsDeletePostAs:(NSString *)nick withId:(NSString *)postId;
+ (NSString *)apiFeedOfFriendsPostMessage:(NSString *)post;

+ (NSString *)apiMailbox;
+ (NSString *)apiMailboxLoadOlderMessagesFromId:(NSString *)fromId;
+ (NSString *)apiMailboxSendTo:(NSString *)recipient message:(NSString *)message;
+ (NSString *)apiMailboxDeleteMessage:(NSString *)messageId;
+ (NSDictionary *)apiMailboxSendWithAttachmentTo:(NSString *)recipient message:(NSString *)message;

+ (NSString *)apiBookmarks;
+ (NSString *)apiBookmarksHistory;

+ (NSString *)apiMessagesForDiscussion:(NSString *)discussionId;
+ (NSString *)apiMessagesForDiscussion:(NSString *)discussionId loadMoreFromId:(NSString *)fromId;
+ (NSString *)apiMessagesForDiscussion:(NSString *)discussionId loadPreviousFromId:(NSString *)fromId;
+ (NSString *)apiDiscussionSendMessage:(NSString *)discussionId message:(NSString *)message;
+ (NSDictionary *)apiDiscussionSendWithAttachment:(NSString *)discussionId message:(NSString *)message;
+ (NSString *)apiDiscussionDeleteMessage:(NSString *)discussionId postId:(NSString *)postId;


@end
