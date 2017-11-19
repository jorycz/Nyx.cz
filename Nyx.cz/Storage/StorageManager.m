//
//  StorageManager.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "StorageManager.h"

@implementation StorageManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.cacheRoot = [caches objectAtIndex:0];
        
        self.imageCacheRoot = [NSString stringWithFormat:@"%@/imageCacheRoot", self.cacheRoot];
        
        NSLog(@"%@ - %@ CACHE : [%@]", self, NSStringFromSelector(_cmd), self.cacheRoot);
        
        self.fileManager = [NSFileManager defaultManager];
        
        NSArray *dirs = @[self.imageCacheRoot];
        
        static dispatch_once_t createDirToken = 0;
        __block BOOL directoryCreated = YES;
        dispatch_once(&createDirToken, ^{
            NSError *dirsError = nil;
            for (NSString *dir in dirs)
            {
                [self.fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&dirsError];
                if (dirsError) {
                    NSLog(@"%@ - %@ : ERROR. Can't create directory! [%@]", self, NSStringFromSelector(_cmd), dir);
                    directoryCreated = NO;
                }
            }
        });
        if (!directoryCreated) {
            return nil;
        }
    }
    return self;
}


- (BOOL)storeImage:(NSData *)image withName:(NSString *)name
{
    NSString *documentPath = [NSString stringWithFormat:@"%@/%@", self.imageCacheRoot, name];
    NSError *error = nil;
    [image writeToFile:documentPath options:NSDataWritingAtomic error:&error];
    if (!error)
    {
        return YES;
    }
    return NO;
}

- (NSData *)readImage:(NSString *)name
{
    NSString *documentPath = [[NSString alloc] initWithFormat:@"%@/%@", self.imageCacheRoot, name];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:documentPath options:NSDataReadingMappedIfSafe error:&error];
    if (!error)
    {
        return data;
    }
    else
    {
        NSLog(@"%@ - %@ : ERROR READING IMAGE [%@]", self, NSStringFromSelector(_cmd), [error localizedDescription]);
        return nil;
    }
}


@end
