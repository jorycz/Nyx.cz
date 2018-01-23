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
#import "NewFeedPostVC.h"
#import "PeopleAutocompleteVC.h"
#import "PeopleRespondVC.h"
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(composeNewMessageFor:) name:kNotificationMailboxNewMessageFor object:nil];
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
    self.view.backgroundColor = COLOR_BACKGROUND_WHITE;
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
        
        self.nController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                                                             target:self
                                                                                                                             action:@selector(composeNewPost:)];
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
        
        UIBarButtonItem *composeMessage = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                        target:self
                                                                                        action:@selector(chooseNickname:)];
        UIBarButtonItem *searchMessage = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                       target:self.peopleTable
                                                                                       action:@selector(showSearchAlert:)];
        self.nController.topViewController.navigationItem.rightBarButtonItems = @[searchMessage, composeMessage];
        
        [self.peopleTable getDataForMailbox];
    }
    
    if ([self.menuKey isEqualToString:kMenuBookmarks])
    {
        self.listTable = [[ContentTableWithList alloc] initWithRowHeight:30];
        self.listTable.nController = self.nController;
        self.listTable.listTableMode = kListTableModeBookmarks;
        self.listTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.listTable.view];
        
//        self.nc.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
//                                                                                                                    target:self
//                                                                                                                    action:@selector(searchForBoard:)];
        [self.listTable getDataForBookmarks];
    }
    
    if ([self.menuKey isEqualToString:kMenuHistory])
    {
        self.listTable = [[ContentTableWithList alloc] initWithRowHeight:30];
        self.listTable.nController = self.nController;
        self.listTable.listTableMode = kListTableModeHistory;
        self.listTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.listTable.view];
        
//        self.nc.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
//                                                                                                                    target:self
//                                                                                                                    action:@selector(searchForBoard:)];
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
        
//        self.nc.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
//                                                                                                                    target:self
//                                                                                                                    action:@selector(chooseNickname:)];
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
        
        //        self.nc.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
        //                                                                                                                    target:self
        //                                                                                                                    action:@selector(chooseNickname:)];
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
        
        self.nController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                                             target:self.peopleTable
                                                                                                                             action:@selector(showSearchAlert:)];
        [self.peopleTable showSearchAlert:nil];
    }
}

#pragma mark - NEW FEED POST

- (void)composeNewPost:(id)sender
{
    NewFeedPostVC *newFeedPostVC = [[NewFeedPostVC alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:newFeedPostVC];
    [self.nController presentViewController:nc animated:YES completion:^{}];
}

#pragma mark - COMPOSE NEW MAIL MESSAGE

- (void)chooseNickname:(id)sender
{
    PeopleAutocompleteVC *mailPeopleFindNick = [[PeopleAutocompleteVC alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:mailPeopleFindNick];
    [self.nController presentViewController:nc animated:YES completion:^{}];
}

- (void)composeNewMessageFor:(NSNotification *)notification
{
    //    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), notification);
    NSDictionary *userData = [[notification userInfo] objectForKey:@"nKey"];
    NSString *nick = [userData objectForKey:@"nick"];
    NSString *lastActiveTimestamp = [[userData objectForKey:@"active"] objectForKey:@"time"];
    NSString *location = [[userData objectForKey:@"active"] objectForKey:@"location"];
    
    NSMutableString *body = [[NSMutableString alloc] initWithString:@"\nNová zpráva pro uživatele."];
    if (lastActiveTimestamp) {
        Timestamp *ts = [[Timestamp alloc] initWithTimestamp:lastActiveTimestamp];
        [body appendString:[NSString stringWithFormat:@"\nPoslední aktivita: %@", [ts getTime]]];
    }
    if (location) {
        [body appendString:[NSString stringWithFormat:@"\nPoslední lokace: %@", location]];
    }
    
    PeopleRespondVC *response = [[PeopleRespondVC alloc] init];
    response.nick = nick;
    response.bodyText = [[NSAttributedString alloc] initWithString:body];
    response.bodyHeight = 80;
    response.postId = @"";
    response.postData = @{@"other_nick": nick};
    response.nController = self.nController;
    response.peopleRespondMode = kPeopleTableModeMailbox;
    [self.nController pushViewController:response animated:YES];
}


#pragma mark - SEARCH BOARD

- (void)searchForBoard:(NSNotification *)sender
{
    // Na toto by mozna bylo lepsi dat target konkretni LIST tabulku (historii, bookmarky)
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Vyhledávání diskuzí"
                                                                   message:@"Není implementováno."
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:^{}];
}



@end

