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
        _cache = [app memCache];
        NSData *cachedData = [_cache readCacheObjectForKey:_currentCacheObjectName];
        if (cachedData)
        {
            [self downloadFinishedWithData:cachedData withIdentification:nil];
        }
        else
        {
            // Try to read from storage
            NSData *data = [self.storageManager readImage:nick];
            if (!data)
            {
                // https://i.nyx.cz/A/AILAS.gif
                NSString *firstChar = [nick substringWithRange:NSMakeRange(0, 1)];
                NSString *url = [NSString stringWithFormat:@"https://i.nyx.cz/%@/%@.gif", firstChar, nick];
                [self.serverConnector downloadDataFromURL:url];
            }
            else
            {
                [self downloadFinishedWithData:data withIdentification:nil];
            }
        }
    }
    else
    {
        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"Can't read avatar because no Username stored yet!");
        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), nick);
        [self downloadFinishedWithData:nil withIdentification:nil];
    }
        
}

- (void)getImageFromUrl:(NSURL *)url
{
    if (url && [[url absoluteString] length] > 0)
    {
        NSData *fileNameData = [[url absoluteString] dataUsingEncoding:NSUTF8StringEncoding];
        _currentCacheObjectName = [[fileNameData base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"=" withString:@""];
        
        // Try to read from memory
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            _cache = [app memCache];
            NSData *cachedData = [_cache readCacheObjectForKey:_currentCacheObjectName];
            if (cachedData)
            {
//                NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"MEM");
                [self downloadFinishedWithData:cachedData withIdentification:nil];
            }
            else
            {
                NSData *data = [self.storageManager readImage:_currentCacheObjectName];
                if (!data)
                {
//                    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"DONWLOAD");
                    [self.serverConnector downloadDataFromURL:[url absoluteString]];
                }
                else
                {
//                    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"HDD");
                    [self downloadFinishedWithData:data withIdentification:nil];
                }
            }
        });
    }
}

#pragma mark - CALLBACK

- (void)downloadFinishedWithData:(NSData *)data withIdentification:(NSString *)identification
{
    [self.storageManager storeImage:data withName:_currentCacheObjectName];
    [_cache saveCacheObject:data forKey:_currentCacheObjectName];
    self.cacheData = data;
    if (self.delegate && [self.delegate respondsToSelector:@selector(cacheComplete:)])
    {
        [self.delegate performSelector:@selector(cacheComplete:) withObject:self];
    } else {
        NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"Missing delegate.");
    }
}

#pragma mark - BASE64

- (NSString *)base64forData:(NSData *)theData
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


@end

