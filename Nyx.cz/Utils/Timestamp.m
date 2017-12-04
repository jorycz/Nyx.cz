//
//  Timestamp.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "Timestamp.h"

@implementation Timestamp

- (instancetype)initWithTimestamp:(NSString *)timestamp
{
    self = [super init];
    if (self) {
        _timeStamp = timestamp;
    }
    return self;
}

- (NSString *)getDayDate
{
    if ([_timeStamp length] > 0) {
        NSInteger ts = [_timeStamp integerValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:ts];
//        NSDate *date = [NSDate dateWithTimeIntervalSince1970:ts/1000];
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"dd. MM. yyyy"];
        return [dateformatter stringFromDate:date];
    } else {
//        NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"No timestamp!");
        return nil;
    }
}

- (NSString *)getTime
{
    if ([_timeStamp length] > 0) {
        NSInteger ts = [_timeStamp integerValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:ts];
        //        NSDate *date = [NSDate dateWithTimeIntervalSince1970:ts/1000];
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"HH:mm:ss"];
        return [dateformatter stringFromDate:date];
    } else {
//        NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"No timestamp!");
        return nil;
    }
}

- (NSString *)getTimeWithDate
{
    if ([_timeStamp length] > 0) {
        NSInteger ts = [_timeStamp integerValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:ts];
        //        NSDate *date = [NSDate dateWithTimeIntervalSince1970:ts/1000];
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"dd. MM. yyyy HH:mm"];
        return [dateformatter stringFromDate:date];
    } else {
//        NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"No timestamp!");
        return nil;
    }
}

@end
