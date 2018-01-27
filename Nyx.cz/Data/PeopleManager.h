//
//  PeopleManager.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 27/01/2018.
//  Copyright © 2018 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerConnector.h"
#import "JSONParser.h"
#import "ApiBuilder.h"


@protocol PeopleManager
- (void)peopleManagerFinished:(id)sender;
@end




@interface PeopleManager : NSObject
{
    BOOL _dataForExactNickMatch;
}


@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSDictionary *rawData;

// Search for fragment of nick - could be more results
@property (nonatomic, strong) NSMutableArray *userSectionsHeaders;
@property (nonatomic, strong) NSMutableArray *userSectionsData;
@property (nonatomic, strong) NSMutableArray *userAvatarNames;
// Search Exact nick - will be only there
@property (nonatomic, strong) NSDictionary *userDataForExactNick;

// Fragment
- (void)getDataForNickFragment:(NSString *)nick;
// Exact
- (void)getDataForExactNick:(NSString *)nick;




@end
