//
//  SideMenu.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "SideMenu.h"
#import "Constants.h"
#import "SideMenuCell.h"

@implementation SideMenu

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = UIColorFromRGB(0xBAE0FF);
        self.menuEntries = @[@"Přehled", @"Pošta", @"Sledované", @"Historie", @"Nastavení"];
        
        self.table = [[UITableView alloc] init];
        [self.table setDelegate:self];
        [self.table setDataSource:self];
        [self.table setBackgroundColor:[UIColor lightGrayColor]];
        [self.table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.table setRowHeight:20];
        [self addSubview:self.table];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.table.frame = CGRectMake(10, 100, 150, 400);
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
//        cell.delegate = self;
    }
    
    cell.tag = (int)indexPath.row;
    cell.textLabel.text = [self.menuEntries objectAtIndex:indexPath.row];
//    [cell.country setString:[self countryForBranchAtPosition:indexPath.row]];
//    [cell.detail setString:[self detailTextForBranchAtPosition:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
