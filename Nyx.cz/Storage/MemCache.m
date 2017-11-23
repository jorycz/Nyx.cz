//
//  MemCache.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 20/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "MemCache.h"

@implementation MemCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _storage = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)readCacheObjectForKey:(NSString *)key
{
    return [_storage objectForKey:key];
}

- (void)saveCacheObject:(id)obj forKey:(NSString *)key
{
    @synchronized(self)
    {
        [_storage setObject:obj forKey:key];
    }
}



@end
