//
//  Timestamp.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timestamp : NSObject
{
    NSString *_timeStamp;
}


- (id)initWithTimestamp:(NSString *)timestamp;
- (NSString *)getDayDate;
- (NSString *)getTime;
- (NSString *)getTimeWithDate;


@end
