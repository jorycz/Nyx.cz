//
//  SideMenu.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "SideMenuTopSection.h"
#import "SideMenuBottomSection.h"


@protocol SideMenuDelegate
- (void)sideMenuSelectedItem:(NSString *)kMenuKey;
@end


@interface SideMenu : UIView <UITableViewDataSource, UITableViewDelegate>
{
    UIView *_topBorder, *_bottomBorder;
}


@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSArray *menuEntries;
@property (nonatomic, assign) CGFloat sideMenuMaxShift;
@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) SideMenuTopSection *topSection;
@property (nonatomic, strong) SideMenuBottomSection *bottomSection;


- (void)showNewMailAlert:(BOOL)mailAlert andNyxNotificationAlert:(BOOL)nyxNotificationAlert;


@end
