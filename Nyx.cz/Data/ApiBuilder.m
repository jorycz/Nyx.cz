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
    NSString *user = [Preferences auth_nick:nil];
    NSString *pass = [Preferences auth_token:nil];
    return [NSString stringWithFormat:@"auth_nick=%@&auth_token=%@&l=%@&l2=%@", user, pass, l, l2];
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
    NSDictionary *params = @{@"auth_nick"     : [Preferences auth_nick:nil],
                             @"auth_token"     : [Preferences auth_token:nil],
                             @"l"           : @"mail",
                             @"l2"          : @"send",
                             @"recipient"   : recipient,
                             @"message"     : message};
    return params;
}



@end

