//
//  CacheManager.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//


#import "CacheManager.h"
#import "Preferences.h"


@implementation CacheManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.serverConnector = [[ServerConnector alloc] init];
        self.serverConnector.delegate = self;
        self.storageManager = [[StorageManager alloc] init];
    }
    return self;
}

- (void)dealloc
{
}

#pragma mark - CACHE

- (void)getAvatar
{
    NSString *avName = [[Preferences username:nil] uppercaseString];
    _currentCacheObjectName = avName;
    NSData *data = [self.storageManager readImage:avName];
    
    if (!data) {
        // https://i.nyx.cz/A/AILAS.gif
        NSString *firstChar = [avName substringWithRange:NSMakeRange(0, 1)];
        NSString *url = [NSString stringWithFormat:@"https://i.nyx.cz/%@/%@.gif", firstChar, avName];
        [self.serverConnector downloadDataFromURL:url];
    }
    else
    {
        [self downloadFinishedWithData:data];
    }
}

#pragma mark - CALLBACK

- (void)downloadFinishedWithData:(NSData *)data
{
    [self.storageManager storeImage:data withName:_currentCacheObjectName];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cacheComplete:)]) {
        [self.delegate performSelector:@selector(cacheComplete:) withObject:data];
    } else {
        NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"Missing delegate.");
    }
}

@end

