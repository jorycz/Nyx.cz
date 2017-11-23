//
//  MemCache.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 20/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemCache : NSMutableDictionary
{
    NSMutableDictionary *_storage;
}


- (id)readCacheObjectForKey:(NSString *)key;
- (void)saveCacheObject:(id)obj forKey:(NSString *)key;


@end
