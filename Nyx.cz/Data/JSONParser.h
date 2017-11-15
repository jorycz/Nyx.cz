//
//  JSONParser.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONParser : NSObject

- (id)initWithData:(NSData *)data;

@property (nonatomic, strong) NSDictionary *jsonDictionary;

@property (nonatomic, strong) NSString *jsonErrorString;
@property (nonatomic, strong) NSString *jsonErrorDataString;


@end
