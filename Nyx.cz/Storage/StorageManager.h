//
//  StorageManager.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StorageManager : NSObject


@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonatomic, retain) NSString *cacheRoot;
@property (nonatomic, retain) NSString *imageCacheRoot;


- (BOOL)storeImage:(NSData *)image withName:(NSString *)name;
- (NSData *)readImage:(NSString *)name;

- (void)copyFileFromUrl:(NSURL *)from toCacheName:(NSString *)cacheName;

- (NSDictionary *)countCache;
- (void)emptyCache;


@end
