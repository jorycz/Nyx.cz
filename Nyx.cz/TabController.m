//
//  TabController.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "TabController.h"
#import "Preferences.h"
#import "LoginScreenVC.h"


@interface TabController ()

@end

@implementation TabController

#pragma mark - INIT

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        UITabBarItem *home = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];
        UITabBarItem *bookmarks = [[UITabBarItem alloc] initWithTitle:@"Bookmarks" image:nil tag:1];
        UITabBarItem *settings = [[UITabBarItem alloc] initWithTitle:@"Settings" image:nil tag:2];
        
        TabHomeVC *tabHome = [[TabHomeVC alloc] init];
        tabHome.title = @"Home";
        tabHome.tabBarItem = home;
        
        TabBookmarksVC *tabBookmarks = [[TabBookmarksVC alloc] init];
        tabBookmarks.title = @"Bookmarks";
        tabBookmarks.tabBarItem = bookmarks;
        
        TabSettingsVC *tabSettings = [[TabSettingsVC alloc] init];
        tabSettings.title = @"Settings";
        tabSettings.tabBarItem = settings;
        
        self.tabBar.itemPositioning = UITabBarItemPositioningFill;
        self.tabBar.opaque = YES;
        self.viewControllers = @[tabHome, tabBookmarks, tabSettings];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
