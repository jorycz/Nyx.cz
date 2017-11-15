//
//  ServerConnector.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ServerConnector.h"
#import "Constants.h"

@implementation ServerConnector

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)downloadDataForApiRequest:(NSString *)apiRequest
{
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kServerAPIURL]
                                                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                              timeoutInterval:10];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:[apiRequest dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:mutableRequest
                                                       completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                             {
                                                 if (error)
                                                 {
                                                     NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), [error localizedDescription]);
                                                     [self downloadDidEndWithData:nil];
                                                 }
                                                 else
                                                 {
                                                     // **** DEBUG ****
                                                     //            NSLog(@"= DEBUG: %@: Response length %lu", [self class], (unsigned long)[data length]);
                                                     //            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                     //            NSLog(@"= DEBUG: DATA [%@]", dataString);
                                                     // **** DEBUG ****
                                                     [self downloadDidEndWithData:data];
                                                 }
                                             }];
    [sessionDataTask resume];
}

- (void)downloadDidEndWithData:(NSData *)data
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadFinishedWithData:)])
    {
        [self.delegate performSelector:@selector(downloadFinishedWithData:) withObject:data];
    }
}

@end
