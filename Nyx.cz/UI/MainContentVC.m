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


@interface MainContentVC ()

@end

@implementation MainContentVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.menuKey = [[NSMutableString alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrameForCurrentStatusBar) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
        
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
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)adjustFrameForCurrentStatusBar
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        CGFloat navigationBarHeight = self.nController.navigationBar.frame.size.height;
//        CGFloat statusBarHeigh = [UIApplication sharedApplication].statusBarFrame.size.height;
//        NSLog(@"- navigation bar height %li - status bar height %li - ", (long)navigationBarHeight, (long)statusBarHeigh);
        CGRect f = self.view.bounds;
        self.peopleTable.view.frame = CGRectMake(0, kNavigationBarHeight + kStatusBarStandardHeight, f.size.width, f.size.height - (kNavigationBarHeight + [Preferences statusBarHeigh:0]));
        self.listTable.view.frame = CGRectMake(0, kNavigationBarHeight + kStatusBarStandardHeight, f.size.width, f.size.height - (kNavigationBarHeight + [Preferences statusBarHeigh:0]));
    });
}

#pragma mark - TABLES

- (void)loadContentWithNavigationController:(UINavigationController *)navController
{
    self.nc = navController;
    
    // - 65 is there because there is big avatar left of table cell body text view.
    _widthForTableCellBodyTextView = self.view.frame.size.width - kWidthForTableCellBodyTextViewSubstract;
    
    self.nc.topViewController.navigationItem.rightBarButtonItem = nil;
    self.peopleTable = nil;
    self.listTable = nil;
    
    if ([self.menuKey isEqualToString:kMenuOverview])
    {
        self.peopleTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
        self.peopleTable.nController = self.nc;
        self.peopleTable.allowsSelection = YES;
        self.peopleTable.peopleTableMode = kPeopleTableModeFeed;
        self.peopleTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.peopleTable.view];

        [self adjustFrameForCurrentStatusBar];
        
        self.nc.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                                                    target:self
                                                                                                                    action:@selector(composeNewPost:)];
        [self.peopleTable getDataForFeedOfFriends];
    }
    
    if ([self.menuKey isEqualToString:kMenuMail])
    {
        self.peopleTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
        self.peopleTable.nController = self.nc;
        self.peopleTable.allowsSelection = YES;
        self.peopleTable.peopleTableMode = kPeopleTableModeMailbox;
        self.peopleTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.peopleTable.view];
        
        [self adjustFrameForCurrentStatusBar];
        
        self.nc.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                                                             target:self
                                                                                                                             action:@selector(chooseNickname:)];
        [self.peopleTable getDataForMailbox];
    }
    
    if ([self.menuKey isEqualToString:kMenuBookmarks])
    {
        self.listTable = [[ContentTableWithList alloc] initWithRowHeight:30];
        self.listTable.nController = self.nc;
        self.listTable.listTableMode = kListTableModeBookmarks;
        self.listTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.listTable.view];
        
        [self adjustFrameForCurrentStatusBar];
        
        self.nc.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                                    target:self
                                                                                                                    action:@selector(searchForBoard:)];
        [self.listTable getDataForBookmarks];
    }
    
    if ([self.menuKey isEqualToString:kMenuHistory])
    {
        self.listTable = [[ContentTableWithList alloc] initWithRowHeight:30];
        self.listTable.nController = self.nc;
        self.listTable.listTableMode = kListTableModeHistory;
        self.listTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.listTable.view];
        
        [self adjustFrameForCurrentStatusBar];
        
        //        self.nController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
        //                                                                                                                             target:self
        //                                                                                                                             action:@selector(refreshDataForMainContent)];
        [self.listTable getDataForHistory];
    }
    
    if ([self.menuKey isEqualToString:kMenuFriendList])
    {
        self.peopleTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
        self.peopleTable.nController = self.nc;
        self.peopleTable.allowsSelection = YES;
        self.peopleTable.peopleTableMode = kPeopleTableModeFriends;
        self.peopleTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.peopleTable.view];
        
        [self adjustFrameForCurrentStatusBar];
        
//        self.nc.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
//                                                                                                                    target:self
//                                                                                                                    action:@selector(chooseNickname:)];
        [self.peopleTable getDataForFriendList];
    }
    
    if ([self.menuKey isEqualToString:kMenuNotifications])
    {
        self.peopleTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
        self.peopleTable.nController = self.nc;
        self.peopleTable.allowsSelection = YES;
        self.peopleTable.peopleTableMode = kPeopleTableModeNotices;
        self.peopleTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.peopleTable.view];
        
        [self adjustFrameForCurrentStatusBar];
        
        //        self.nc.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
        //                                                                                                                    target:self
        //                                                                                                                    action:@selector(chooseNickname:)];
        [self.peopleTable getDataForNotices];
    }
    
    if ([self.menuKey isEqualToString:kMenuSearchPosts])
    {
        self.peopleTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
        self.peopleTable.nController = self.nc;
        self.peopleTable.allowsSelection = YES;
        self.peopleTable.peopleTableMode = kPeopleTableModeSearch;
        self.peopleTable.widthForTableCellBodyTextView = _widthForTableCellBodyTextView;
        [self.view addSubview:self.peopleTable.view];
        
        [self adjustFrameForCurrentStatusBar];
        
        self.nc.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                                                    target:self
                                                                                                                    action:@selector(showSearchDialog)];
        [self showSearchDialog];
    }
}

#pragma mark - NEW FEED POST

- (void)composeNewPost:(id)sender
{
    NewFeedPostVC *new = [[NewFeedPostVC alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:new];
    [self.nc presentViewController:nc animated:YES completion:^{}];
}

#pragma mark - COMPOSE NEW MAIL MESSAGE

- (void)chooseNickname:(id)sender
{
    PeopleAutocompleteVC *pAuto = [[PeopleAutocompleteVC alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:pAuto];
    [self.nc presentViewController:nc animated:YES completion:^{}];
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
    response.nController = self.nc;
    response.peopleRespondMode = kPeopleTableModeMailbox;
    [self.nc pushViewController:response animated:YES];
}

#pragma mark - SEARCH DIALOG

- (void)showSearchDialog
{
    [self.nc.topViewController.navigationItem.rightBarButtonItem setEnabled:NO];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Vyhledávání"
                                                                   message:@"Vyhledat je možné dle nicku a textu."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *login = [UIAlertAction actionWithTitle:@"Vyhledat" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action) {
                                                      NSString *n = [[alert.textFields objectAtIndex:0] text];
                                                      NSString *t = [[alert.textFields objectAtIndex:1] text];
                                                      [self.peopleTable getDataForSearchNick:n andText:t];
                                                  }];
    [alert addAction:login];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Nick";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Text";
    }];
    [self.nc presentViewController:alert animated:YES completion:^{}];
}

#pragma mark - SEARCH BOARD

- (void)searchForBoard:(NSNotification *)sender
{
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"");
}



@end

