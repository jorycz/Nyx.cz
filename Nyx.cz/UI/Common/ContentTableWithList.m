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
#import "ComputeRowHeight.h"


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
        _firstInit = YES;
        _currentDiscussionId = [[NSMutableString alloc] init];
        _serverIdentificationDiscussion = @"discussion";
        _serverIdentificationDiscussionFromId = @"discussionFromId";
        _serverIdentificationDiscussionRefreshAfterNewPost = @"refreshAfterNewPost";
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMorePostsFromId:) name:kNotificationDiscussionLoadOlderFrom object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewerPostsFromId:) name:kNotificationDiscussionLoadNewerFrom object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _table = [[UITableView alloc] init];
    [self.view addSubview:_table];
    
    [_table setBackgroundColor:[UIColor clearColor]];
    [_table setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
    [_table setDataSource:self];
    [_table setDelegate:self];
    [_table setRowHeight:_rh];
    
    self.nController.topViewController.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [_table setFrame:self.view.bounds];
    
    if (_firstInit) {
        _firstInit = NO;
        
        // DISCUSSION TABLE INIT !
        // Is allocated and going to be present - one time only.
        self.discussionTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
        self.discussionTable.nController = self.nController;
        self.discussionTable.allowsSelection = YES;
        self.discussionTable.canEditFirstRow = YES;
        self.discussionTable.peopleTableMode = kPeopleTableModeDiscussion;
    }
    
    // - 65 is there because there is big avatar left of table cell body text view.
    _widthForTableCellBodyTextView = self.view.frame.size.width - kWidthForTableCellBodyTextViewSubstract;
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
    
    NSDictionary *userPostData = [[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), userPostData);
    
    self.discussionTable.title = [userPostData objectForKey:@"jmeno"];
    
    if ([userPostData objectForKey:@"id_klub"]) {
        [self getDataForDiscussion:[userPostData objectForKey:@"id_klub"]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - TABLE ACTIONS & DATA

- (void)loadNewerPostsFromId:(NSNotification *)sender
{
    NSString *fromID = [[sender userInfo] objectForKey:@"nKey"];
    NSString *api = [ApiBuilder apiMessagesForDiscussion:_currentDiscussionId loadPreviousFromId:fromID];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.identifitaion = _serverIdentificationDiscussionRefreshAfterNewPost;
    sc.delegate = self;
    [sc downloadDataForApiRequest:api];
}

- (void)getDataForDiscussion:(NSString *)disId
{
    [self placeLoadingView];
    [_currentDiscussionId setString:disId];
    
    NSString *api = [ApiBuilder apiMessagesForDiscussion:_currentDiscussionId];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.identifitaion = _serverIdentificationDiscussion;
    sc.delegate = self;
    [sc downloadDataForApiRequest:api];
}

- (void)loadMorePostsFromId:(NSNotification *)sender
{
    NSString *fromID = [[sender userInfo] objectForKey:@"nKey"];
    NSString *apiRequest = [ApiBuilder apiMessagesForDiscussion:_currentDiscussionId loadMoreFromId:fromID];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.delegate = self;
    sc.identifitaion = _serverIdentificationDiscussionFromId;
    [sc downloadDataForApiRequest:apiRequest];
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
//                NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), jp.jsonDictionary);
                [self configureTableWithJson:jp.jsonDictionary withIdentification:identification];
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

#pragma mark - DISCUSSION TABLE CONFIGURATION - DATA

- (void)configureTableWithJson:(NSDictionary *)nyxDictionary withIdentification:(NSString *)identification
{
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), nyxDictionary);
    
    // To forward all information about current discussion club. NEEDED ONLY FOR DISCUSSION CLUB TABLES.
    self.discussionTable.disscussionClubData = [nyxDictionary objectForKey:@"discussion"];
    
    NSMutableArray *postDictionaries = [[NSMutableArray alloc] init];
    [postDictionaries addObjectsFromArray:[nyxDictionary objectForKey:@"data"]];
    
    if ([postDictionaries count] > 0)
    {
        [self.discussionTable.nyxSections removeAllObjects];
        [self.discussionTable.nyxSections addObjectsFromArray:@[kDisableTableSections]];
        
        NSMutableArray *tempArrayForRowSections = [[NSMutableArray alloc] init];
        NSMutableArray *tempArrayForRowHeights = [[NSMutableArray alloc] init];
        NSMutableArray *tempArrayForRowBodyText = [[NSMutableArray alloc] init];
        
        for (NSDictionary *d in postDictionaries)
        {
            [tempArrayForRowSections addObject:d];
            // Calculate heights and create array with same structure just only for row height.
            // 60 is minimum height - table ROW height is initialized to 70 below ( 70 - nick name )
            ComputeRowHeight *rowHeight = [[ComputeRowHeight alloc] initWithText:[d objectForKey:@"content"]
                                                                        forWidth:_widthForTableCellBodyTextView
                                                                       minHeight:kMinimumPeopleTableCellHeight
                                                                    inlineImages:[Preferences showImagesInlineInPost:nil]];
            [tempArrayForRowHeights addObject:[NSNumber numberWithFloat:rowHeight.heightForRow]];
            [tempArrayForRowBodyText addObject:rowHeight.attributedText];
        }
        
        if ([identification isEqualToString:_serverIdentificationDiscussionFromId])
        {
            // Add new posts data at the END of previous posts data.
            NSMutableArray *previousNyxRowsForSections = [[NSMutableArray alloc] initWithArray:[self.discussionTable.nyxRowsForSections objectAtIndex:0]];
            [previousNyxRowsForSections addObjectsFromArray:tempArrayForRowSections];
            [self.discussionTable.nyxRowsForSections removeAllObjects];
            [self.discussionTable.nyxRowsForSections addObjectsFromArray:@[previousNyxRowsForSections]];
            
            NSMutableArray *previousNyxPostsRowHeights = [[NSMutableArray alloc] initWithArray:[self.discussionTable.nyxPostsRowHeights objectAtIndex:0]];
            [previousNyxPostsRowHeights addObjectsFromArray:tempArrayForRowHeights];
            [self.discussionTable.nyxPostsRowHeights removeAllObjects];
            [self.discussionTable.nyxPostsRowHeights addObjectsFromArray:@[previousNyxPostsRowHeights]];
            
            NSMutableArray *previousNyxPostsRowBodyTexts = [[NSMutableArray alloc] initWithArray:[self.discussionTable.nyxPostsRowBodyTexts objectAtIndex:0]];
            [previousNyxPostsRowBodyTexts addObjectsFromArray:tempArrayForRowBodyText];
            [self.discussionTable.nyxPostsRowBodyTexts removeAllObjects];
            [self.discussionTable.nyxPostsRowBodyTexts addObjectsFromArray:@[previousNyxPostsRowBodyTexts]];
        }
        if ([identification isEqualToString:_serverIdentificationDiscussion])
        {
            // First discussion load - remove all data and start again
            [self.discussionTable.nyxRowsForSections removeAllObjects];
            [self.discussionTable.nyxRowsForSections addObjectsFromArray:@[tempArrayForRowSections]];
            
            [self.discussionTable.nyxPostsRowHeights removeAllObjects];
            [self.discussionTable.nyxPostsRowHeights addObjectsFromArray:@[tempArrayForRowHeights]];
            
            [self.discussionTable.nyxPostsRowBodyTexts removeAllObjects];
            [self.discussionTable.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
        }
        if ([identification isEqualToString:_serverIdentificationDiscussionRefreshAfterNewPost])
        {
            // Add new posts data at the BEGINNING of previous posts data.
            [tempArrayForRowSections addObjectsFromArray:[self.discussionTable.nyxRowsForSections objectAtIndex:0]];
            [self.discussionTable.nyxRowsForSections removeAllObjects];
            [self.discussionTable.nyxRowsForSections addObjectsFromArray:@[tempArrayForRowSections]];
            
            [tempArrayForRowHeights addObjectsFromArray:[self.discussionTable.nyxPostsRowHeights objectAtIndex:0]];
            [self.discussionTable.nyxPostsRowHeights removeAllObjects];
            [self.discussionTable.nyxPostsRowHeights addObjectsFromArray:@[tempArrayForRowHeights]];
            
            [tempArrayForRowBodyText addObjectsFromArray:[self.discussionTable.nyxPostsRowBodyTexts objectAtIndex:0]];
            [self.discussionTable.nyxPostsRowBodyTexts removeAllObjects];
            [self.discussionTable.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.nController.topViewController.navigationItem.rightBarButtonItem setEnabled:YES];
            // RELOAD
            if ([identification isEqualToString:_serverIdentificationDiscussionFromId]) {
                [self.discussionTable reloadTableDataWithScrollToTop:NO];
            } else {
                [self.discussionTable reloadTableDataWithScrollToTop:YES];
            }
            // CREATE IF NEEDED
            if ([identification isEqualToString:_serverIdentificationDiscussion])
            {
                [self.nController pushViewController:self.discussionTable animated:YES];
                [self removeLoadingView];
            }
        });
    } else {
        PRESENT_ERROR(@"Error", @"No data from server.")
    }
}



@end



