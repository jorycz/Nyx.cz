//
//  SideMenu.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "SideMenu.h"
#import "SideMenuCell.h"


@implementation SideMenu

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.menuEntries = @[kMenuOverview, kMenuMail, kMenuBookmarks, kMenuHistory, kMenuPeople, kMenuNotifications, kMenuSearchPosts];
        
        self.table = [[UITableView alloc] init];
        [self.table setDelegate:self];
        [self.table setDataSource:self];
        [self.table setBackgroundColor:[UIColor clearColor]];
        [self.table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.table setRowHeight:40];
        [self addSubview:self.table];
        
        self.topSection = [[SideMenuTopSection alloc] init];
        [self addSubview:self.topSection];
        
        self.bottomSection = [[SideMenuBottomSection alloc] init];
        [self addSubview:self.bottomSection];
        
        _topBorder = [[UIView alloc] init];
        _topBorder.backgroundColor = [UIColor lightGrayColor];
        _topBorder.alpha = .3;
        _bottomBorder = [[UIView alloc] init];
        _bottomBorder.backgroundColor = [UIColor lightGrayColor];
        _bottomBorder.alpha = .3;
        [self addSubview:_topBorder];
        [self addSubview:_bottomBorder];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect f = self.frame;
    CGFloat yPosTable = f.size.height * 0.25;
    CGFloat heightTable = f.size.height * 0.58;
    NSInteger fuckingIos11UIKitBugConstantForIphone8Plus = 50;
    self.table.frame = CGRectMake(0, yPosTable, self.sideMenuMaxShift + fuckingIos11UIKitBugConstantForIphone8Plus, heightTable);
    
    self.topSection.frame = CGRectMake(0, 66, self.sideMenuMaxShift, yPosTable - 67);
    self.bottomSection.frame = CGRectMake(0, yPosTable + heightTable + 1, self.sideMenuMaxShift, f.size.height - yPosTable - heightTable - 2);
    
    _topBorder.frame = CGRectMake(5, yPosTable - 2, self.sideMenuMaxShift - 10, 1);
    _bottomBorder.frame = CGRectMake(5, yPosTable + heightTable + 2, self.sideMenuMaxShift - 10, 1);
}

#pragma mark - TABLE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdForReuse = @"uniqCell";
    SideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdForReuse];
    if (cell == nil)
    {
        cell = [[SideMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdForReuse];
    }
    cell.tag = (int)indexPath.row;
    [cell updateMenuLabel:[self.menuEntries objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate sideMenuSelectedItem:[self.menuEntries objectAtIndex:indexPath.row]];
    [self reloadCellsConfiguration];
}

- (void)reloadCellsConfiguration
{
    NSArray *cells = [self.table visibleCells];
    for (SideMenuCell *c in cells) {
        [c updateLabelColor];
    }
}

#pragma mark - NYX NOTIFICATION

- (void)showNewMailAlert:(NSInteger)mailAlert andNyxNotificationAlert:(NSInteger)nyxNotificationAlert
{
    SideMenuCell *cMail = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cMail showNewNotificationAlert:mailAlert];
    
    SideMenuCell *cNotification = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    [cNotification showNewNotificationAlert:nyxNotificationAlert];
}

@end
