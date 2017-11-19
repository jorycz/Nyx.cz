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
        self.backgroundColor = UIColorFromRGB(0xBAE0FF);
        self.menuEntries = @[kMenuHome, kMenuMail, kMenuBookmarks, kMenuHistory, kMenuPeople, kMenuNotifications, kMenuSearchPosts];
        
        self.table = [[UITableView alloc] init];
        [self.table setDelegate:self];
        [self.table setDataSource:self];
        [self.table setBackgroundColor:[UIColor lightGrayColor]];
        [self.table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.table setRowHeight:40];
        [self addSubview:self.table];
        
        self.topSection = [[SideMenuTopSection alloc] init];
        [self addSubview:self.topSection];
        
        self.bottomSection = [[SideMenuBottomSection alloc] init];
        [self addSubview:self.bottomSection];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect f = self.frame;
    CGFloat yPosTable = f.size.height * 0.25;
    CGFloat heightTable = f.size.height * 0.58;
    self.table.frame = CGRectMake(0, yPosTable, self.sideMenuMaxShift, heightTable);
    
    self.topSection.frame = CGRectMake(0, 66, self.sideMenuMaxShift, yPosTable - 67);
    self.bottomSection.frame = CGRectMake(0, yPosTable + heightTable + 1, self.sideMenuMaxShift, f.size.height - yPosTable - heightTable - 2);
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
    cell.textLabel.text = [self.menuEntries objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate sideMenuSelectedItem:[self.menuEntries objectAtIndex:indexPath.row]];
    
//    NSString *selectedBranch = [NSString stringWithFormat:@"%@", [[self.branches objectAtIndex:indexPath.row] objectForKey:@"id"]];
//    [SBUserDefaults saveBranch:selectedBranch];
//    NSString *selectedBranchName = [NSString stringWithFormat:@"%@", [[self.branches objectAtIndex:indexPath.row] objectForKey:@"name"]];
//    [SBUserDefaults saveBranchName:selectedBranchName];
//
//    // Close detail text view for cells when some cell is selected - final state.
//    _shouldExtend = NO;
//    [self reloadRowsFromCellOnIndex:-1];
//
//    POST_NOTIFICATION_BRUNCH_MENU_DONE
}


@end
