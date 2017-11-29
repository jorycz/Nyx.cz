//
//  MainContentVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "MainContentVC.h"


@interface MainContentVC ()

@end

@implementation MainContentVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.menuKey = [[NSMutableString alloc] init];
    }
    return self;
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
    
    _info = [[UITextField alloc] init];
    _info.text = @"...";
    _info.userInteractionEnabled = NO;
    _info.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_info];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _info.frame = self.view.bounds;
}

- (void)loadContentWithNavigationController:(UINavigationController *)navController
{
    [self.cFriendFeeds removeFromSuperview];
    self.cFriendFeeds = nil;
    [self.cMailBox removeFromSuperview];
    self.cMailBox = nil;
    [self.cBookmarks removeFromSuperview];
    self.cBookmarks = nil;
    [self.cHistory removeFromSuperview];
    self.cHistory = nil;
    [self.cPeople removeFromSuperview];
    self.cPeople = nil;
    [self.cNotifications removeFromSuperview];
    self.cNotifications = nil;
    [self.cSearch removeFromSuperview];
    self.cSearch = nil;
    
    if ([self.menuKey isEqualToString:kMenuOverview]) {
        self.cFriendFeeds = [[ContentFriendsFeed alloc] initWithFrame:self.view.bounds];
        self.cFriendFeeds.nController = navController;
        [self.view addSubview:self.cFriendFeeds];
    }
    if ([self.menuKey isEqualToString:kMenuMail]) {
        self.cMailBox = [[ContentMailbox alloc] initWithFrame:self.view.bounds];
        self.cMailBox.nController = navController;
        [self.view addSubview:self.cMailBox];
    }
    if ([self.menuKey isEqualToString:kMenuBookmarks]) {
        self.cBookmarks = [[ContentBookmarks alloc] initWithFrame:self.view.bounds];
        self.cBookmarks.nController = navController;
        [self.view addSubview:self.cBookmarks];
    }
    if ([self.menuKey isEqualToString:kMenuHistory]) {
        self.cHistory = [[ContentHistory alloc] initWithFrame:self.view.bounds];
        self.cHistory.nController = navController;
        [self.view addSubview:self.cHistory];
    }
    if ([self.menuKey isEqualToString:kMenuPeople]) {
        self.cPeople = [[ContentPeople alloc] initWithFrame:self.view.bounds];
        self.cPeople.nController = navController;
        [self.view addSubview:self.cPeople];
    }
    if ([self.menuKey isEqualToString:kMenuNotifications]) {
        self.cNotifications = [[ContentNotification alloc] initWithFrame:self.view.bounds];
        self.cNotifications.nController = navController;
        [self.view addSubview:self.cNotifications];
    }
    if ([self.menuKey isEqualToString:kMenuSearchPosts]) {
        self.cSearch = [[ContentSearch alloc] initWithFrame:self.view.bounds];
        self.cSearch.nController = navController;
        [self.view addSubview:self.cSearch];
    }
}

@end

