//
//  MainContentVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "MainContentVC.h"

#import "Preferences.h"
#import "Constants.h"
#import "Colors.h"


@interface MainContentVC ()

@end

@implementation MainContentVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.menuKey = [[NSMutableString alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrameForCurrentStatusBar:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor themeColorMainBackgroundDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _mainScreen = self.view.bounds;
    self.peopleTable.view.frame = CGRectMake(0, [Preferences statusNavigationBarsHeights:0], _mainScreen.size.width, _mainScreen.size.height - [Preferences statusNavigationBarsHeights:0]);
    self.listTable.view.frame = CGRectMake(0, [Preferences statusNavigationBarsHeights:0], _mainScreen.size.width, _mainScreen.size.height - [Preferences statusNavigationBarsHeights:0]);
}

- (void)adjustFrameForCurrentStatusBar:(id)sender
{
    [self.view setNeedsLayout];
}


#pragma mark - TABLES

- (void)loadContentWithNavigationController:(UINavigationController *)navController
{
    self.nController = navController;
    
    // - 65 is there because there is big avatar left of table cell body text view.
    _widthForTableCellBodyTextView = self.view.frame.size.width - kWidthForTableCellBodyTextViewSubstract;
    
    self.nController.topViewController.navigationItem.rightBarButtonItems = nil;
    [self.peopleTable.view removeFromSuperview];
    [self.listTable.view removeFromSuperview];
    
    if ([self.menuKey isEqualToString:kMenuOverview])
    {
        self.peopleTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
        self.peopleTable.nController = self.nController;
        self.peopleTable.allowsSelection = YES;
        self.peopleTable.peopleTableMode = kPeopleTableModeFeed;
        self.peopleTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.peopleTable.view];
        [self.peopleTable getDataForFeedOfFriends];
    }
    
    if ([self.menuKey isEqualToString:kMenuMail])
    {
        self.peopleTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
        self.peopleTable.nController = self.nController;
        self.peopleTable.allowsSelection = YES;
        self.peopleTable.peopleTableMode = kPeopleTableModeMailbox;
        self.peopleTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.peopleTable.view];
        [self.peopleTable getDataForMailbox];
    }
    
    if ([self.menuKey isEqualToString:kMenuBookmarks])
    {
        self.listTable = [[ContentTableWithList alloc] initWithRowHeight:30];
        self.listTable.nController = self.nController;
        self.listTable.listTableMode = kListTableModeBookmarks;
        self.listTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.listTable.view];
        [self.listTable getDataForBookmarks];
    }
    
    if ([self.menuKey isEqualToString:kMenuHistory])
    {
        self.listTable = [[ContentTableWithList alloc] initWithRowHeight:30];
        self.listTable.nController = self.nController;
        self.listTable.listTableMode = kListTableModeHistory;
        self.listTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.listTable.view];
        [self.listTable getDataForHistory];
    }
    
    if ([self.menuKey isEqualToString:kMenuFriendList])
    {
        self.peopleTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
        self.peopleTable.nController = self.nController;
        self.peopleTable.allowsSelection = YES;
        self.peopleTable.peopleTableMode = kPeopleTableModeFriends;
        self.peopleTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.peopleTable.view];
        [self.peopleTable getDataForFriendList];
    }
    
    if ([self.menuKey isEqualToString:kMenuNotifications])
    {
        self.peopleTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
        self.peopleTable.nController = self.nController;
        self.peopleTable.allowsSelection = YES;
        self.peopleTable.peopleTableMode = kPeopleTableModeNotices;
        self.peopleTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.peopleTable.view];
        [self.peopleTable getDataForNotices];
    }
    
    if ([self.menuKey isEqualToString:kMenuSearchPosts])
    {
        self.peopleTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
        self.peopleTable.nController = self.nController;
        self.peopleTable.allowsSelection = YES;
        self.peopleTable.peopleTableMode = kPeopleTableModeSearch;
        self.peopleTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.peopleTable.view];
        [self.peopleTable showSearchAlert:nil];
    }
}



@end

