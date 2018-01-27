//
//  PeopleManager.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 27/01/2018.
//  Copyright © 2018 Josef Rysanek. All rights reserved.
//

#import "PeopleManager.h"


@implementation PeopleManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userSectionsHeaders = [[NSMutableArray alloc] init];
        self.userSectionsData = [[NSMutableArray alloc] init];
        self.userAvatarNames = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - SETUP & GO AHEAD

- (void)getDataForNickFragment:(NSString *)nick
{
    NSString *apiRequest = [ApiBuilder apiPeopleAutocompleteForNick:nick];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.delegate = self;
    [sc downloadDataForApiRequest:apiRequest];
}

#pragma mark - SERVER CONNECTOR DELEGATE DATA RESULT

- (void)downloadFinishedWithData:(NSData *)data withIdentification:(NSString *)identification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
    if (!data)
    {
        [self presentErrorWithTitle:@"Žádná data" andMessage:@"Nelze se připojit na server."];
    }
    else
    {
        JSONParser *jp = [[JSONParser alloc] initWithData:data];
        if (!jp.jsonDictionary)
        {
            NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), jp.jsonErrorString);
            NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), jp.jsonErrorDataString);
            [self presentErrorWithTitle:@"Chyba při parsování" andMessage:jp.jsonErrorString];
        }
        else
        {
            if ([[jp.jsonDictionary objectForKey:@"result"] isEqualToString:@"error"])
            {
                [self presentErrorWithTitle:@"Chyba ze serveru:" andMessage:[jp.jsonDictionary objectForKey:@"error"]];
            }
            else
            {
                //                NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), jp.jsonDictionary);
                [self createAutocompleteDataWithDict:jp.jsonDictionary];
            }
        }
    }
}

#pragma mark - DATA PARSE

- (void)createAutocompleteDataWithDict:(NSDictionary *)d
{
    // insert all 3 fields to self.autocompleteData
    //    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), d);
    NSDictionary *fields = [[NSDictionary alloc] initWithDictionary:[d objectForKey:@"data"]];
    NSArray *exact = [fields objectForKey:@"exact"];
    NSArray *friends = [fields objectForKey:@"friends"];
    NSArray *others = [fields objectForKey:@"others"];
    
    if ([exact count] > 0) {
        [self.userSectionsHeaders addObject:@"Uživatel"];
        [self.userSectionsData addObject:exact];
    }
    if ([friends count] > 0) {
        [self.userSectionsHeaders addObject:@"Přátelé"];
        [self.userSectionsData addObject:friends];
    }
    if ([others count] > 0) {
        [self.userSectionsHeaders addObject:@"Ostatní"];
        [self.userSectionsData addObject:others];
    }
    
    // Get nick by key nick.
    for (NSDictionary *d in exact) {
        [self.userAvatarNames addObject:[d objectForKey:@"nick"]];
    }
    for (NSDictionary *d in friends) {
        [self.userAvatarNames addObject:[d objectForKey:@"nick"]];
    }
    for (NSDictionary *d in others) {
        [self.userAvatarNames addObject:[d objectForKey:@"nick"]];
    }
    
    [self managerDone];
}


#pragma mark - SEND RESULT

- (void)managerDone
{
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), self.userSectionsHeaders);
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), self.userSectionsData);
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), self.userAvatarNames);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(peopleManagerFinished:)]) {
        [self.delegate performSelector:@selector(peopleManagerFinished:) withObject:self];
    }
}

- (void)presentErrorWithTitle:(NSString *)title andMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        PRESENT_ERROR(title, message)
    });
}



@end
