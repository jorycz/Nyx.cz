//
//  SettingsVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "SettingsVC.h"
#import "Constants.h"
#import "Preferences.h"


@interface SettingsVC ()

@end

@implementation SettingsVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.menuEntries = @[@"Spočítat velikost cache", @"Počáteční lokace", @"Smazat nastavení", @"Smazat nastavení včetně loginu!"];
        self.menuSubtitles = @[@"Spočítá a případně umožní vymazat obsah mezipaměti.", @"", @"Smaže veškeré nastavení kromě loginu.", @"Smaže veškeré nastavení včetně loginu, cache, atd."];
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
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                   target:self
                                                                                   action:@selector(dismissSettings)];
    self.navigationItem.rightBarButtonItem = dismissButton;
    
    self.title = @"Nastavení";
    
    self.table = [[UITableView alloc] init];
    [self.table setDelegate:self];
    [self.table setDataSource:self];
    [self.table setBackgroundColor:[UIColor clearColor]];
    [self.table setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.table setRowHeight:80];
    [self.view addSubview:self.table];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect f = self.view.bounds;
    CGFloat _maxHeight = f.size.height;
    CGFloat _currentHeight = 92 + ([self.menuEntries count] * 80);
    self.table.frame = CGRectMake(0, 0, self.view.frame.size.width, MIN(_maxHeight, _currentHeight));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - DISMISS

- (void)dismissSettings
{
    [self dismissViewControllerAnimated:YES completion:^{}];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdForReuse];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdForReuse];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:22];
    }
    
    cell.tag = (int)indexPath.row;
    cell.textLabel.text = [self.menuEntries objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSString *subtitle = [self.menuSubtitles objectAtIndex:indexPath.row];
    [subtitle length] > 0 ? cell.detailTextLabel.text = subtitle : NULL ;
    if (indexPath.row == 1) {
        NSString *startingLocation = [Preferences preferredStartingLocation:nil];
        NSString *missingLocation = [NSString stringWithFormat:@"Zatím neurčena. Poslední navštívená: %@", [Preferences lastUserPosition:nil]];
        startingLocation ? [cell.detailTextLabel setText:startingLocation] : [cell.detailTextLabel setText:missingLocation];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self countCache];
            break;
        case 1:
            [self chooseStartingLocation];
            break;
        case 2:
            [self deleteSettings];
            break;
        case 3:
            [self deleteAllData];
            break;
            
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Smazané věci nelze obnovit!";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.9];
}

#pragma mark - ACTIONS

- (void)countCache
{
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"");
}

- (void)chooseStartingLocation
{
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"");
}

- (void)deleteSettings
{
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"");
}

- (void)deleteAllData
{
    [self deleteSettings];
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"");
}


@end
