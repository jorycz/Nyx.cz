//
//  NewNoticesForPost.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 03/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewNoticesForPost : NSObject
{
    NSMutableArray *_newPosts;
    NSMutableArray *_newThumbup;
    NSMutableArray *_newThumbsdown;
}


@property (nonatomic, strong) NSArray *nPosts;
@property (nonatomic, strong) NSArray *nThumbup;
@property (nonatomic, strong) NSArray *nThumbsdown;


- (instancetype)initWithPost:(NSDictionary *)d forLastVisit:(NSString *)lastVisit;


@end
