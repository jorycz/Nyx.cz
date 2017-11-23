//
//  CacheManager.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//


#import "CacheManager.h"
#import "Preferences.h"

#import "AppDelegate.h"
#import "MemCache.h"


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

- (void)getAvatarForNick:(NSString *)nick
{
    if (nick && [nick length] > 0) {
        _currentCacheObjectName = nick;
        
        // Try to read from memory
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        MemCache *cache = [app getMemCache];
        NSData *cachedData = [cache readCacheObjectForKey:_currentCacheObjectName];
        if (cachedData)
        {
            [self downloadFinishedWithData:cachedData withIdentification:nil];
        }
        else
        {
            // Try to read from storage
            NSData *data = [self.storageManager readImage:nick];
            if (!data) {
                // https://i.nyx.cz/A/AILAS.gif
                NSString *firstChar = [nick substringWithRange:NSMakeRange(0, 1)];
                NSString *url = [NSString stringWithFormat:@"https://i.nyx.cz/%@/%@.gif", firstChar, nick];
                [self.serverConnector downloadDataFromURL:url];
            }
            else
            {
                // Donwload
                [self downloadFinishedWithData:data withIdentification:nil];
            }
        }
    }
    else
    {
        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"Can't read avatar because no Username stored yet!");
        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), nick);
        NSLog(@"%@", [NSThread callStackSymbols]);
        [self downloadFinishedWithData:nil withIdentification:nil];
    }
        
}

#pragma mark - CALLBACK

- (void)downloadFinishedWithData:(NSData *)data withIdentification:(NSString *)identification
{
    [self.storageManager storeImage:data withName:_currentCacheObjectName];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cacheComplete:)]) {
        [self.delegate performSelector:@selector(cacheComplete:) withObject:data];
    } else {
        NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"Missing delegate.");
    }
}

@end

