//
//  ApiBuilder.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ApiBuilder.h"

@implementation ApiBuilder

#pragma mark - LOGIN TEST ONLY

+ (NSString *)apiLoginTestForUser:(NSString *)user andPassword:(NSString *)pass
{
    return [NSString stringWithFormat:@"loguser=%@&logpass=%@&l=%@&l2=%@&nick=%@", user, pass, kApiPeople, kApiPeopleStatus, user];
}

#pragma mark - DEFAULT FOR ALL URLs

+ (NSString *)defaultApiRequestWithL:(NSString *)l andL2:(NSString *)l2
{
    return [NSString stringWithFormat:@"l=%@&l2=%@", l, l2];
}

#pragma mark - EXTERN

+ (NSString *)apiPeopleStatusForNick:(NSString *)value
{
    return [NSString stringWithFormat:@"%@&nick=%@", [self defaultApiRequestWithL:kApiPeople andL2:kApiPeopleStatus], value];
}

@end
