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
        
//        NSLog(@"%@ - %@ CACHE : [%@]", self, NSStringFromSelector(_cmd), self.cacheRoot);
        
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
    [self.fileManager removeItemAtPath:documentPath error:nil];
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
//        NSLog(@"%@ - %@ : ERROR READING IMAGE [%@]", self, NSStringFromSelector(_cmd), [error localizedDescription]);
        return nil;
    }
}

- (void)copyFileFromUrl:(NSURL *)from toCacheName:(NSString *)cacheName
{
    NSError *error = nil;
    NSURL *destination = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@/%@", self.imageCacheRoot, cacheName]];
    [self.fileManager removeItemAtURL:destination error:nil];
    [self.fileManager copyItemAtURL:from toURL:destination error:&error];
    if (error) {
        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), error);
    }
}

#pragma mark - COUNT CACHE

- (NSDictionary *)countCache
{
    NSDirectoryEnumerator *dirEnum = [self.fileManager enumeratorAtPath:self.imageCacheRoot];
    NSString *file;
    NSUInteger filesSize = 0;
    NSUInteger filesCount = 0;
    while (file = [dirEnum nextObject])
    {
        NSDictionary *attrs = [dirEnum fileAttributes];
        if ([attrs valueForKey:@"NSFileType"] == NSFileTypeRegular) {
            // Keep file and count file size in. :-)
            filesSize += [[attrs valueForKey:@"NSFileSize"] unsignedIntegerValue];
            filesCount++;
        }
    }
    NSUInteger mb = (filesSize / 1024 / 1024);
//    NSLog(@"%@ - %@ : Cache size [%luMB]", self, NSStringFromSelector(_cmd), mb);
    return @{@"files": [NSNumber numberWithInteger:filesCount], @"size": [NSNumber numberWithInteger:mb]};
}

- (void)emptyCache
{
    NSDirectoryEnumerator *dirEnum = [self.fileManager enumeratorAtPath:self.imageCacheRoot];
    NSString *file;
    while (file = [dirEnum nextObject])
    {
        NSDictionary *attrs = [dirEnum fileAttributes];
        if ([attrs valueForKey:@"NSFileType"] == NSFileTypeRegular) {
            NSError *error = nil;
            [self.fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", self.imageCacheRoot, file] error:&error];
            if (error) {
                NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), [error localizedDescription]);
            }
        }
    }
}


@end


