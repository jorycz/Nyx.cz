//
//  NewNoticesForPost.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 03/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "NewNoticesForPost.h"

@implementation NewNoticesForPost

- (instancetype)initWithPost:(NSDictionary *)d forLastVisit:(NSString *)lastVisit
{
    self = [super init];
    if (self)
    {
        if (d && [[d allKeys] count] > 0)
        {
            _oldPosts = [[NSMutableArray alloc] init];
            _newPosts = [[NSMutableArray alloc] init];
            _newThumbup = [[NSMutableArray alloc] init];
            _newThumbsdown = [[NSMutableArray alloc] init];
            NSInteger _last = [lastVisit integerValue];
            
            for (id a in [d allValues])
            {
                // Some array found in post - replies or ratings.
                if (a && [a isKindOfClass:[NSArray class]] && [a count] > 0)
                {
                    for (NSInteger index = 0; index < [a count]; index++)
                    {
                        // Loop through array to get notices times.
                        NSString *t = [[a objectAtIndex:index] objectForKey:@"time"];
                        if (t && [t length] > 0)
                        {
                            NSInteger noticeTime = [t integerValue];
                            if (noticeTime > _last)
                            {
                                NSString *key = [[d allKeysForObject:a] firstObject];
                                if ([key isEqualToString:@"replies"]) {
                                    [_newPosts addObject:[a objectAtIndex:index]];
                                }
                                if ([key isEqualToString:@"thumbs_up"]) {
                                    [_newThumbup addObject:[a objectAtIndex:index]];
                                }
                                if ([key isEqualToString:@"thumbs_down"]) {
                                    [_newThumbsdown addObject:[a objectAtIndex:index]];
                                }
                            }
                            else
                            {
                                // Check for any OLD replies.
                                NSString *key = [[d allKeysForObject:a] firstObject];
                                if ([key isEqualToString:@"replies"] && [[d objectForKey:@"replies"] count] > 0) {
                                    [_oldPosts addObject:[a objectAtIndex:index]];
                                }
                            }
                        }
                    }
                }
            }
        }
        
        self.oPosts = (NSArray *)_oldPosts;
        self.nPosts = (NSArray *)_newPosts;
        self.nThumbup = (NSArray *)_newThumbup;
        self.nThumbsdown = (NSArray *)_newThumbsdown;
        
//        NSLog(@"%@ - %@ : N POSTS [%@]", self, NSStringFromSelector(_cmd), self.nPosts);
//        NSLog(@"%@ - %@ : N THUP [%@]", self, NSStringFromSelector(_cmd), self.nThumbup);
//        NSLog(@"%@ - %@ : N THDOWN [%@]", self, NSStringFromSelector(_cmd), self.nThumbsdown);
        
//        NSLog(@"%@ - %@ : N POSTS [%li]", self, NSStringFromSelector(_cmd), (long)[self.nPosts count]);
//        NSLog(@"%@ - %@ : N THUP [%li]", self, NSStringFromSelector(_cmd), (long)[self.nThumbup count]);
//        NSLog(@"%@ - %@ : N THDOWN [%li]", self, NSStringFromSelector(_cmd), (long)[self.nThumbsdown count]);
    }
    return self;
}

@end
