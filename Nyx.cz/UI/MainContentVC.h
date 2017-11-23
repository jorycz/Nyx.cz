//
//  MainContentVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

#import "ContentFriendsFeed.h"
#import "ContentMailbox.h"
#import "ContentBookmarks.h"
#import "ContentHistory.h"
#import "ContentPeople.h"
#import "ContentNotification.h"
#import "ContentSearch.h"


@interface MainContentVC : UIViewController
{
    UITextField *_info;
}


@property (nonatomic, strong) NSMutableString *menuKey;

@property (nonatomic, strong) ContentFriendsFeed *cFriendFeeds;
@property (nonatomic, strong) ContentMailbox *cMailBox;
@property (nonatomic, strong) ContentBookmarks *cBookmarks;
@property (nonatomic, strong) ContentHistory *cHistory;
@property (nonatomic, strong) ContentPeople *cPeople;
@property (nonatomic, strong) ContentNotification *cNotifications;
@property (nonatomic, strong) ContentSearch *cSearch;


- (void)loadContentWithNavigationController:(UINavigationController *)navController;


@end
