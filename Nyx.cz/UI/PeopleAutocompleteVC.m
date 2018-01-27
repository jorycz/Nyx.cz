//
//  PeopleAutocompleteVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 22/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "PeopleAutocompleteVC.h"
#import <QuartzCore/QuartzCore.h>
#import "Timestamp.h"
#import "Colors.h"


@interface PeopleAutocompleteVC ()

@end

@implementation PeopleAutocompleteVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.title = @"Adresát";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        _firstInit = YES;
        _loadingInProgress = NO;
        self.autocompleteData = [[NSMutableArray alloc] init];
        self.nickAvatarsToDownload = [[NSMutableArray alloc] init];
        self.avatarImagesByNick = [[NSMutableDictionary alloc] init];
        self.sections = [[NSMutableArray alloc] init];
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
    self.view.backgroundColor = [UIColor themeColorMainBackgroundDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _table = [[UITableView alloc] init];
    [self.view addSubview:_table];
    
    [_table setBackgroundColor:[UIColor themeColorMainBackgroundDefault]];
    [_table setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
    [_table setDataSource:self];
    [_table setDelegate:self];
    [_table setRowHeight:60];
    [_table setAllowsSelection:YES];
    [self.view addSubview:_table];
    
    _searchField = [[UITextField alloc] init];
    _searchField.delegate = self;
    _searchField.backgroundColor = [UIColor themeColorMainBackgroundDefault];
    _searchField.clipsToBounds = YES;
    _searchField.layer.cornerRadius = 6.0f;
    [_searchField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    // Set space to left side of search field
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10., 10.)];
    [_searchField setLeftViewMode:UITextFieldViewModeAlways];
    [_searchField setLeftView:spacerView];
    _searchField.textColor = [UIColor themeColorStandardText];
    
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor themeColorBackgroundRespondElement];
    [_topView addSubview:_searchField];
    [self.view addSubview:_topView];
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                   target:self
                                                                                   action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = dismissButton;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (_firstInit) {
        _firstInit = NO;
        
        CGFloat bars = [Preferences statusNavigationBarsHeights:0]; // 64 / 84 ... = navigation bar + status bar
        CGFloat composeView = 50;
        CGRect f = self.view.bounds;
        
        _topView.frame = CGRectMake(0, bars, f.size.width, composeView);
        _searchField.frame = CGRectMake(10, 10, f.size.width - 20, composeView - 20);
        [_table setFrame:CGRectMake(f.origin.x, f.origin.y + composeView + bars, f.size.width, f.size.height - bars - composeView)];
        _tableFrame = _table.frame;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_searchField becomeFirstResponder];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (_choosenUser) {
            POST_NOTIFICATION_MAILBOX_NEW_MESSAGE_FOR(_choosenUser)
        }
    }];
}

#pragma mark - TABLE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.autocompleteData objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdForReuse = @"uniqCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdForReuse];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdForReuse];
    }
    NSString *nick = [[[self.autocompleteData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"nick"];
    NSString *timeActive = [[[[self.autocompleteData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"active"] objectForKey:@"time"];
    cell.textLabel.text = nick;
    cell.detailTextLabel.text = nil;
    if (timeActive) {
        Timestamp *ts = [[Timestamp alloc] initWithTimestamp:timeActive];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Poslední aktivita: %@", [ts getTime]];
    }
    cell.imageView.image = [self.avatarImagesByNick objectForKey:nick];
    cell.textLabel.textColor = [UIColor themeColorStandardText];
    cell.textLabel.backgroundColor = [UIColor themeColorMainBackgroundDefault];
    
    cell.detailTextLabel.textColor = [UIColor themeColorStandardText];
    cell.detailTextLabel.backgroundColor = [UIColor themeColorMainBackgroundDefault];
    
    cell.backgroundColor = [UIColor themeColorMainBackgroundDefault];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_searchField resignFirstResponder];
    _choosenUser = [[self.autocompleteData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self dismiss];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sections objectAtIndex:section];
}


#pragma mark - CACHE

- (void)cacheComplete:(CacheManager *)cache
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.avatarImagesByNick setObject:[UIImage imageWithData:cache.cacheData] forKey:[self.nickAvatarsToDownload objectAtIndex:0]];
        [self.nickAvatarsToDownload removeObjectAtIndex:0];
    });
    [self downloadAvatar];
}


#pragma mark - KEYBOARD

- (void)keyboardWillChangeFrame:(NSNotification *) notification
{
    _keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self performSelectorOnMainThread:@selector(keyboardChanged) withObject:nil waitUntilDone:YES];
}

- (void)keyboardChanged
{
    CGRect newFrameTable = CGRectMake(_tableFrame.origin.x, _tableFrame.origin.y, _tableFrame.size.width, _tableFrame.size.height - _keyboardSize.height);
    _table.frame = newFrameTable;
}


#pragma mark - SEARCH DELEGATE

- (void)textFieldDidChange:(UITextField *)sender
{
    NSString *text = sender.text;
    if ([text length] > 2)
    {
        if (!_loadingInProgress) {
            _loadingInProgress = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [self searchForNickFragment:text];
        }
    } else {
        [self.sections removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_table reloadData];
        });
    }
}


#pragma mark - USER SEARCH - PEOPLE MANAGER

- (void)searchForNickFragment:(NSString *)nick
{
    self.pm = [[PeopleManager alloc] init];
    self.pm.delegate = self;
    [self.pm getDataForNickFragment:nick];
}

- (void)peopleManagerFinished:(id)sender
{
    PeopleManager *pm = (PeopleManager *)sender;
    
    // Delete old data
    [self.sections removeAllObjects];
    [self.autocompleteData removeAllObjects];
    
    // Add new
    [self.sections addObjectsFromArray:pm.userSectionsHeaders];
    [self.autocompleteData addObjectsFromArray:pm.userSectionsData];
    
    // Create download queue for nick images
    [self.nickAvatarsToDownload addObjectsFromArray:pm.userAvatarNames];
    [self downloadAvatar];
}


#pragma mark - DOWNLOAD AVATARS

- (void)downloadAvatar
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.nickAvatarsToDownload count] > 0) {
            self.cache = [[CacheManager alloc] init];
            self.cache.delegate = self;
            NSString *avatar = [self.nickAvatarsToDownload firstObject];
            [self.cache getAvatarForNick:avatar];
        } else {
            [_table reloadData];
            _loadingInProgress = NO;
        }
    });
}


@end




