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


@protocol CacheManagerDelegate
@optional
- (void)cacheComplete:(NSData *)cache;
@end


@interface CacheManager : NSObject <ServerConnectorDelegate>
{
    NSString *_currentCacheObjectName;
}


@property (nonatomic, strong) ServerConnector *serverConnector;
@property (nonatomic, strong) StorageManager *storageManager;
@property (nonatomic, strong) id delegate;


- (void)getAvatar;


@end
