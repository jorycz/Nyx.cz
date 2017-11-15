//
//  JSONParser.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "JSONParser.h"

@implementation JSONParser

- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        if (data || [data length] > 0) {
            NSError *jsonError = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            if (jsonError)
            {
                self.jsonErrorString = [jsonError localizedDescription];
                self.jsonErrorDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            else
            {
                self.jsonDictionary = [[NSDictionary alloc] initWithDictionary:dict];
            }
        }
    }
    return self;
}


@end
