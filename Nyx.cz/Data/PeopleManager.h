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


@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSDictionary *rawData;

@property (nonatomic, strong) NSMutableArray *userSectionsHeaders;
@property (nonatomic, strong) NSMutableArray *userSectionsData;
@property (nonatomic, strong) NSMutableArray *userAvatarNames;


- (void)getDataForNickFragment:(NSString *)nick;




@end
