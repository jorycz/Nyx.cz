//
//  ApiBuilder.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface ApiBuilder : NSObject

// Login test ONLY
+ (NSString *)apiLoginTestForUser:(NSString *)user andPassword:(NSString *)pass;

// API URLs
+ (NSString *)apiPeopleStatusForNick:(NSString *)value;

@end
