//
//  CacheManager.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ServerConnector.h"
#import "StorageManager.h"
#import "MemCache.h"

@class CacheManager;

@protocol CacheManagerDelegate
@optional
- (void)cacheComplete:(CacheManager *)cache;
@end


@interface CacheManager : NSObject <ServerConnectorDelegate>
{
    NSString *_currentCacheObjectName;
    MemCache *_cache;
}


@property (nonatomic, strong) ServerConnector *serverConnector;
@property (nonatomic, strong) StorageManager *storageManager;
@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) NSInteger cacheTag;
@property (nonatomic, strong) NSData *cacheData;


- (void)getAvatarForNick:(NSString *)nick;
- (void)getImageFromUrl:(NSURL *)url;


@end
