//
//  ContentTableWithList.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 25/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ContentTableWithList.h"
#import "Constants.h"
#import "JSONParser.h"
#import "ApiBuilder.h"
#import "LoadingView.h"

#import "TableConfigurator.h"


@interface ContentTableWithList ()

@end

@implementation ContentTableWithList

- (id)initWithRowHeight:(CGFloat)rowHeight
{
    self = [super init];
    if (self)
    {
        _rh = rowHeight;
        self.nyxSections = [[NSMutableArray alloc] init];
        self.nyxRowsForSections = [[NSMutableArray alloc] init];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kNotificationListTableChanged object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _table = [[UITableView alloc] init];
    [self.view addSubview:_table];
    
    [_table setBackgroundColor:[UIColor whiteColor]];
    [_table setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
    [_table setDataSource:self];
    [_table setDelegate:self];
    [_table setRowHeight:_rh];
    
    UIRefreshControl *refreshControll = [[UIRefreshControl alloc] init];
    [refreshControll addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControll];
    [_table insertSubview:refreshControll atIndex:0];
    refreshControll.layer.zPosition = -1;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [_table setFrame:self.view.bounds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - LOADING VIEW

- (void)placeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.nController.topViewController.navigationItem.rightBarButtonItem setEnabled:NO];
        LoadingView *lv = [[LoadingView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:lv];
    });
}

- (void)removeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.nController.topViewController.navigationItem.rightBarButtonItem setEnabled:YES];
        [[self.view viewWithTag:kLoadingCoverViewTag] removeFromSuperview];
    });
}

#pragma mark - Table view data source

- (void)reloadTableData
{
    [_table reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.nyxSections)
        return [self.nyxSections count];
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.nyxRowsForSections && [self.nyxRowsForSections count] > 0)
        return [[self.nyxRowsForSections objectAtIndex:section] count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdForReuse = @"uniqCell";
    ContentTableWithListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdForReuse];
    if (cell == nil)
    {
        cell = [[ContentTableWithListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdForReuse];
    }
    
    NSDictionary *cellData = [[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (cellData)
    {
        cell.boardName = [cellData objectForKey:@"jmeno"];
        cell.unreadCount = [cellData objectForKey:@"unread"];
        [cell configureCellForIndexPath:indexPath];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[self.nyxSections firstObject] isEqualToString:kDisableTableSections]) {
        return nil;
    }
    return [self.nyxSections objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // DISCUSSION TABLE INIT !
    self.nestedPeopleTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
    self.nestedPeopleTable.nController = self.nController;
    self.nestedPeopleTable.allowsSelection = YES;
    self.nestedPeopleTable.canEditFirstRow = YES;
    self.nestedPeopleTable.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
    self.nestedPeopleTable.peopleTableMode = kPeopleTableModeDiscussion;
    
    NSDictionary *userPostData = [[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), userPostData);
    
    self.nestedPeopleTable.title = [userPostData objectForKey:@"jmeno"];
    
    if ([userPostData objectForKey:@"id_klub"]) {
        [self.nController pushViewController:self.nestedPeopleTable animated:YES];
        [self.nestedPeopleTable getDataForDiscussion:[userPostData objectForKey:@"id_klub"]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - REFRESH DATA

- (void)refreshData
{
    if ([self.listTableMode isEqualToString:kListTableModeHistory])
        [self getDataForHistory];
    if ([self.listTableMode isEqualToString:kListTableModeBookmarks])
        [self getDataForBookmarks];
}

#pragma mark - PULL TO REFRESH

- (void)pullToRefresh:(id)sender
{
    [_table setScrollEnabled:NO];
    [_table setScrollEnabled:YES];
    
    [self refreshData];
    
    [(UIRefreshControl *)sender endRefreshing];
}

#pragma mark - DATA / API CALL

- (void)serverApiCall:(NSString *)api andIdentification:(NSString *)identification
{
    [self placeLoadingView];
    
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.identifitaion = identification;
    sc.delegate = self;
    [sc downloadDataForApiRequest:api];
}

- (void)getDataForBookmarks
{
    NSString *apiRequest = [ApiBuilder apiBookmarks];
    [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForBookmarks];
}

- (void)getDataForHistory
{
    NSString *apiRequest = [ApiBuilder apiBookmarksHistory];
    [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForHistory];
}

#pragma mark - SERVER DELEGATE

- (void)downloadFinishedWithData:(NSData *)data withIdentification:(NSString *)identification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
    if (!data)
    {
        [self presentErrorWithTitle:@"Žádná data" andMessage:@"Nelze se připojit na server."];
    }
    else
    {
        JSONParser *jp = [[JSONParser alloc] initWithData:data];
        if (!jp.jsonDictionary)
        {
            NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), jp.jsonErrorString);
            NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), jp.jsonErrorDataString);
            [self presentErrorWithTitle:@"Chyba při parsování" andMessage:jp.jsonErrorString];
        }
        else
        {
            if ([[jp.jsonDictionary objectForKey:@"result"] isEqualToString:@"error"])
            {
                NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), jp.jsonDictionary);
                [self presentErrorWithTitle:@"Chyba ze serveru:" andMessage:[jp.jsonDictionary objectForKey:@"error"]];
            }
            else
            {
                if ([identification isEqualToString:kApiIdentificationDataForHistory])
                {
                    TableConfigurator *tc = [[TableConfigurator alloc] init];
                    tc.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
                    [tc configureListTableHistory:self withData:jp.jsonDictionary];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self reloadTableData];
                        [self removeLoadingView];
                    });
                }
                
                if ([identification isEqualToString:kApiIdentificationDataForBookmarks])
                {
                    TableConfigurator *tc = [[TableConfigurator alloc] init];
                    [tc configureListTableBookmark:self withData:jp.jsonDictionary];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self reloadTableData];
                        [self removeLoadingView];
                    });
                }
            }
        }
    }
}

#pragma mark - RESULT

- (void)presentErrorWithTitle:(NSString *)title andMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        PRESENT_ERROR(title, message)
    });
}



@end



