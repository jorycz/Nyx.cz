//
//  ApiBuilder.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ApiBuilder.h"

@implementation ApiBuilder

#pragma STRING ESCAPE PERCENT ENCODING

+ (NSString *)safeStringOf:(NSString *)unsafe
{
    // Encode ANY charracter (alphanumericCharacterSet) to make it possible send as escaped string in URL.
    NSString *safe = [unsafe stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    return safe;
}

#pragma mark - AUTHORIZATION

+ (NSString *)apiAuthorizeForUser:(NSString *)user
{
    return [NSString stringWithFormat:@"auth_nick=%@&auth_token=%@&l=help&l2=test", user, [Preferences auth_token:nil]];
}

#pragma mark - DEFAULT FOR ALL URLs

+ (NSString *)defaultApiRequestWithL:(NSString *)l andL2:(NSString *)l2
{
#if TARGET_OS_SIMULATOR
    return [NSString stringWithFormat:@"logpass=%@&loguser=%@&l=%@&l2=%@", [Preferences password:nil], [Preferences username:nil], l, l2];
#else
    NSString *user = [Preferences auth_nick:nil];
    NSString *pass = [Preferences auth_token:nil];
    return [NSString stringWithFormat:@"auth_nick=%@&auth_token=%@&l=%@&l2=%@", user, pass, l, l2];
#endif
}

#pragma mark - PEOPLE

+ (NSString *)apiPeopleStatusForNick:(NSString *)value
{
    return [NSString stringWithFormat:@"%@&nick=%@", [self defaultApiRequestWithL:kApiPeople andL2:kApiPeopleStatus], value];
}

+ (NSString *)apiPeopleAutocompleteForNick:(NSString *)nick
{
    return [NSString stringWithFormat:@"%@&nick=%@", [self defaultApiRequestWithL:kApiPeople andL2:kApiPeopleAutocomplete], nick];
}

+ (NSString *)apiPeopleFriends
{
    return [NSString stringWithFormat:@"%@", [self defaultApiRequestWithL:kApiPeople andL2:kApiPeopleFriends]];
}


#pragma mark - FRIENDS FEED

+ (NSString *)apiFeedOfFriends
{
    return [NSString stringWithFormat:@"%@", [self defaultApiRequestWithL:kApiFeed andL2:kApiFeedFriends]];
}

+ (NSString *)apiFeedOfFriendsPostsFor:(NSString *)nick withId:(NSString *)postId
{
    return [NSString stringWithFormat:@"%@&user=%@&id=%@", [self defaultApiRequestWithL:kApiFeed andL2:kApiFeedEntry], nick, postId];
}

+ (NSString *)apiFeedOfFriendsPostCommentAs:(NSString *)nick withId:(NSString *)postId sendMessage:(NSString *)message
{
    return [NSString stringWithFormat:@"%@&user=%@&id=%@&message=%@", [self defaultApiRequestWithL:kApiFeed andL2:kApiFeedSendComment], nick, postId, [self safeStringOf:message]];
}

+ (NSString *)apiFeedOfFriendsDeleteCommentAs:(NSString *)nick withId:(NSString *)postId commentId:(NSString *)commentId
{
    return [NSString stringWithFormat:@"%@&user=%@&id=%@&id_comment=%@", [self defaultApiRequestWithL:kApiFeed andL2:kApiFeedDeleteComment], nick, postId, commentId];
}

+ (NSString *)apiFeedOfFriendsDeletePostAs:(NSString *)nick withId:(NSString *)postId
{
    return [NSString stringWithFormat:@"%@&user=%@&id=%@", [self defaultApiRequestWithL:kApiFeed andL2:kApiFeedDeleteEntry], nick, postId];
}

+ (NSString *)apiFeedOfFriendsPostMessage:(NSString *)post
{
    return [NSString stringWithFormat:@"%@&message=%@", [self defaultApiRequestWithL:kApiFeed andL2:kApiFeedSendPost], [self safeStringOf:post]];
}

#pragma mark - NOTICES

+ (NSString *)apiFeedNoticesAndKeepNew:(BOOL)keepNew
{
    return [NSString stringWithFormat:@"%@&keep_new=%@", [self defaultApiRequestWithL:kApiFeed andL2:kApiFeedSendNotices], keepNew ? @"1" : @"0"];
}

#pragma mark - MAILBOX

+ (NSString *)apiMailbox
{
    return [NSString stringWithFormat:@"%@", [self defaultApiRequestWithL:kApiMail andL2:kApiMailMessages]];
}

+ (NSString *)apiMailboxLoadOlderMessagesFromId:(NSString *)fromId
{
    return [NSString stringWithFormat:@"%@&direction=older&id_mail=%@", [self defaultApiRequestWithL:kApiMail andL2:kApiMailMessages], fromId];
}

+ (NSString *)apiMailboxSendTo:(NSString *)recipient message:(NSString *)message
{
    return [NSString stringWithFormat:@"%@&recipient=%@&message=%@", [self defaultApiRequestWithL:kApiMail andL2:kApiMailMessageSend], recipient, [self safeStringOf:message]];
}

+ (NSString *)apiMailboxDeleteMessage:(NSString *)messageId
{
    return [NSString stringWithFormat:@"%@&id_mail=%@", [self defaultApiRequestWithL:kApiMail andL2:kApiMailDeleteMessage], messageId];
}

+ (NSDictionary *)apiMailboxSendWithAttachmentTo:(NSString *)recipient message:(NSString *)message
{
#if TARGET_OS_SIMULATOR
    NSDictionary *params = @{@"loguser"     : [Preferences username:nil],
                             @"logpass"     : [Preferences password:nil],
                             @"l"           : kApiMail,
                             @"l2"          : kApiMailMessageSend,
                             @"recipient"   : recipient,
                             @"message"     : message
                             };
    return params;
#else
    NSDictionary *params = @{@"auth_nick"     : [Preferences auth_nick:nil],
                             @"auth_token"     : [Preferences auth_token:nil],
                             @"l"           : kApiMail,
                             @"l2"          : kApiMailMessageSend,
                             @"recipient"   : recipient,
                             @"message"     : message
                             };
    return params;
#endif
}

#pragma mark - BOOKMARKS

+ (NSString *)apiBookmarks
{
    return [NSString stringWithFormat:@"%@", [self defaultApiRequestWithL:kApiBookmarks andL2:kApiBookmarksAll]];
}

+ (NSString *)apiBookmarksHistory
{
    return [NSString stringWithFormat:@"%@", [self defaultApiRequestWithL:kApiBookmarks andL2:kApiBookmarksHistory]];
}

#pragma mark - DISCUSSION

+ (NSString *)apiMessagesForDiscussion:(NSString *)discussionId
{
    return [NSString stringWithFormat:@"%@&id=%@", [self defaultApiRequestWithL:kApiDiscussion andL2:kApiDiscussionMessages], discussionId];
}

+ (NSString *)apiMessagesForDiscussion:(NSString *)discussionId loadMoreFromId:(NSString *)fromId
{
    return [NSString stringWithFormat:@"%@&id=%@&direction=older&id_wu=%@", [self defaultApiRequestWithL:kApiDiscussion andL2:kApiDiscussionMessages], discussionId, fromId];
}

+ (NSString *)apiMessagesForDiscussion:(NSString *)discussionId loadPreviousFromId:(NSString *)fromId
{
    return [NSString stringWithFormat:@"%@&id=%@&direction=newer&id_wu=%@", [self defaultApiRequestWithL:kApiDiscussion andL2:kApiDiscussionMessages], discussionId, fromId];
}

+ (NSDictionary *)apiDiscussionSendWithAttachment:(NSString *)discussionId message:(NSString *)message
{
#if TARGET_OS_SIMULATOR
    NSDictionary *params = @{@"loguser"     : [Preferences username:nil],
                             @"logpass"     : [Preferences password:nil],
                             @"l"           : kApiDiscussion,
                             @"l2"          : kApiDiscussionSend,
                             @"id"          : discussionId,
                             @"message"     : message
                             };
    return params;
#else
    NSDictionary *params = @{@"auth_nick"     : [Preferences auth_nick:nil],
                             @"auth_token"     : [Preferences auth_token:nil],
                             @"l"           : kApiDiscussion,
                             @"l2"          : kApiDiscussionSend,
                             @"id"          : discussionId,
                             @"message"     : message
                             };
    return params;
#endif
}

+ (NSString *)apiDiscussionDeleteMessage:(NSString *)discussionId postId:(NSString *)postId
{
    return [NSString stringWithFormat:@"%@&id=%@&id_wu=%@", [self defaultApiRequestWithL:kApiDiscussion andL2:kApiDiscussionDelete], discussionId, postId];
}

+ (NSString *)apiDiscussionGiveRatingInDiscussion:(NSString *)discussionId toPost:(NSString *)postId positiveRating:(BOOL)positiveRating
{
    NSString *r;
    positiveRating ? (r = @"positive") : (r = @"negative&neg_confirmation=1") ;
    return [NSString stringWithFormat:@"%@&rating=%@&id=%@&id_wu=%@&toggle=1", [self defaultApiRequestWithL:kApiDiscussion andL2:kApiDiscussionRatingGive], r, discussionId, postId];
}

+ (NSString *)apiDiscussionGetRatingInDiscussion:(NSString *)discussionId forPost:(NSString *)postId
{
    return [NSString stringWithFormat:@"%@&id=%@&id_wu=%@", [self defaultApiRequestWithL:kApiDiscussion andL2:kApiDiscussionRatingInfo], discussionId, postId];
}

+ (NSString *)apiDiscussionSearchInDiscussion:(NSString *)discussionId forNick:(NSString *)nickId withText:(NSString *)text
{
    return [NSString stringWithFormat:@"%@&id=%@&filter_user=%@&filter_text=%@", [self defaultApiRequestWithL:kApiDiscussion andL2:kApiDiscussionMessages], discussionId, nickId, text];
}

#pragma mark - GLOBAL SEARCH

+ (NSString *)apiSearchFor:(NSString *)nick andText:(NSString *)text forPosition:(NSString *)position
{
    return [NSString stringWithFormat:@"%@&filter_user=%@&filter_text=%@&position=%@", [self defaultApiRequestWithL:kApiSearch andL2:kApiSearchWriteups], nick, text, position];
}

#pragma mark - UTIL

+ (NSString *)apiUtilMakeInactive
{
    return [NSString stringWithFormat:@"%@", [self defaultApiRequestWithL:kApiUtil andL2:kApiUtilMakeInactive]];
}

+ (NSString *)apiUtilRemoveAuthorization
{
    return [NSString stringWithFormat:@"%@", [self defaultApiRequestWithL:kApiUtil andL2:kApiUtilRemoveAuthorization]];
}


@end

