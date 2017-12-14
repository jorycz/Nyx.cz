//
//  TableConfigurator.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 14/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ContentTableWithList.h"
#import "ContentTableWithPeople.h"


@interface TableConfigurator : NSObject


@property (nonatomic, assign) CGFloat widthForTableCellBodyTextView;


// LIST TABLE
- (void)configureListTableBookmark:(ContentTableWithList *)table withData:(NSDictionary *)dict;
- (void)configureListTableHistory:(ContentTableWithList *)table withData:(NSDictionary *)dict;


// PEOPLE TABLE
- (void)configurePeopleTableFriendsFeed:(ContentTableWithPeople *)table withData:(NSDictionary *)dict;
- (void)configurePeopleTableMailbox:(ContentTableWithPeople *)table withData:(NSDictionary *)dict addingData:(BOOL)addData;
- (void)configurePeopleTablePeople:(ContentTableWithPeople *)table withData:(NSDictionary *)dict;
- (void)configurePeopleTableNotices:(ContentTableWithPeople *)table withData:(NSDictionary *)dict;
- (void)configurePeopleTableSearch:(ContentTableWithPeople *)table withData:(NSDictionary *)dict;


// POEPLE TABLE - RECONFIGURATION
- (void)reconfigurePeopleTableDiscussion:(ContentTableWithPeople *)table
                                withData:(NSDictionary *)dict
                withActionIdentification:(NSString *)identification;


// POEPLE TABLE - RE/CONFIGURATION FOR RESPOND SCREEN
- (void)reconfigurePeopleTableForResponseScreen:(ContentTableWithPeople *)table
                                       withData:(NSDictionary *)dict
                                  withTableMode:(NSString *)tableMode
                                       postData:(NSDictionary *)postData
                                       moreRows:(NSArray *)moreRows
                                    moreHeights:(NSArray *)moreHeights
                                      moreTexts:(NSArray *)moreTexts;

- (void)configurePeopleTableRatingInfo:(ContentTableWithPeople *)table withData:(NSDictionary *)dict;


@end
