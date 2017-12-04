//
//  ContentMailbox.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 21/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ContentMailbox.h"

#import "LoadingView.h"
#import "JSONParser.h"
#import "ApiBuilder.h"
#import "ComputeRowHeight.h"

#import "PeopleAutocompleteVC.h"
#import "PeopleRespondVC.h"
#import "Constants.h"
#import "Timestamp.h"


@implementation ContentMailbox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        _firstInit = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataForMainContent) name:kNotificationMailboxChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrameForCurrentStatusBar) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMoreMailsFromId:) name:kNotificationMailboxLoadFrom object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(composeNewMessageFor:) name:kNotificationMailboxNewMessageFor object:nil];
        _serverIdentificationMailbox = @"mailbox";
        _serverIdentificationMailboxOlderMessages = @"olderMessages";
        _serverIdentificationNewMessage = @"newMessage";
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    if (self.window && _firstInit)
    {
        _firstInit = NO;
        
        // Is allocated and going to be present - one time only.
        self.table = [[ContentTableWithPeople alloc] initWithRowHeight:70];
        self.table.nController = self.nController;
        self.table.allowsSelection = YES;
        self.table.peopleTableMode = kPeopleTableModeMailbox;
        [self addSubview:self.table.view];
        
        [self adjustFrameForCurrentStatusBar];
        
        // - 65 is there because there is big avatar left of table cell body text view.
        _widthForTableCellBodyTextView = self.frame.size.width - kWidthForTableCellBodyTextViewSubstract;
        
        self.nController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                                                             target:self
                                                                                                                             action:@selector(chooseNickname:)];
        
        [self refreshDataForMainContent];
    }
}

- (void)adjustFrameForCurrentStatusBar
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect f = self.bounds;
        self.table.view.frame = CGRectMake(0, kNavigationBarHeight + kStatusBarStandardHeight, f.size.width, f.size.height - (kNavigationBarHeight + kStatusBarStandardHeight));
    });
}

- (void)refreshDataForMainContent
{
    [self getFreshData];
}

#pragma mark - LOADING VIEW

- (void)placeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.nController.topViewController.navigationItem.rightBarButtonItem setEnabled:NO];
        LoadingView *lv = [[LoadingView alloc] initWithFrame:self.bounds];
        [self addSubview:lv];
    });
}

- (void)removeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.nController.topViewController.navigationItem.rightBarButtonItem setEnabled:YES];
        [[self viewWithTag:kLoadingCoverViewTag] removeFromSuperview];
    });
}

#pragma mark - DATA

- (void)getFreshData
{
    [self placeLoadingView];
    
    NSString *apiRequest = [ApiBuilder apiMailbox];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.delegate = self;
    sc.identifitaion = _serverIdentificationMailbox;
    [sc downloadDataForApiRequest:apiRequest];
}

- (void)loadMoreMailsFromId:(NSNotification *)sender
{
    [self placeLoadingView];
    
    NSString *fromID = [[sender userInfo] objectForKey:@"nKey"];
    NSString *apiRequest = [ApiBuilder apiMailboxLoadOlderMessagesFromId:fromID];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.delegate = self;
    sc.identifitaion = _serverIdentificationMailboxOlderMessages;
    [sc downloadDataForApiRequest:apiRequest];
}

#pragma mark - DELEGATE

- (void)downloadFinishedWithData:(NSData *)data withIdentification:(NSString *)identification
{
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
                [self presentErrorWithTitle:@"Chyba ze serveru:" andMessage:[jp.jsonDictionary objectForKey:@"error"]];
            }
            else
            {
                if ([identification isEqualToString:_serverIdentificationMailbox]) {
                    [self configureTableWithJson:jp.jsonDictionary addData:NO];
                }
                if ([identification isEqualToString:_serverIdentificationMailboxOlderMessages]) {
                    [self configureTableWithJson:jp.jsonDictionary addData:YES];
                }
            }
        }
    }
}

- (void)presentErrorWithTitle:(NSString *)title andMessage:(NSString *)message
{
    [self removeLoadingView];
    PRESENT_ERROR(title, message)
}

#pragma mark - TABLE CONFIGURATION - DATA

- (void)configureTableWithJson:(NSDictionary *)nyxDictionary addData:(BOOL)addData
{
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), nyxDictionary);
    
    NSMutableArray *postDictionaries = [[NSMutableArray alloc] init];
    [postDictionaries addObjectsFromArray:[nyxDictionary objectForKey:@"data"]];
    
    if ([postDictionaries count] > 0)
    {
        // Add FEED post as first cell here also.
        [self.table.nyxSections removeAllObjects];
        [self.table.nyxSections addObjectsFromArray:@[kDisableTableSections]];
        
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
        
        if (addData)
        {
            // Add new posts complete data to previous complete posts data.
            NSMutableArray *previousNyxRowsForSections = [[NSMutableArray alloc] initWithArray:[self.table.nyxRowsForSections objectAtIndex:0]];
            [previousNyxRowsForSections addObjectsFromArray:tempArrayForRowSections];
            [self.table.nyxRowsForSections removeAllObjects];
            [self.table.nyxRowsForSections addObjectsFromArray:@[previousNyxRowsForSections]];
            
            NSMutableArray *previousNyxPostsRowHeights = [[NSMutableArray alloc] initWithArray:[self.table.nyxPostsRowHeights objectAtIndex:0]];
            [previousNyxPostsRowHeights addObjectsFromArray:tempArrayForRowHeights];
            [self.table.nyxPostsRowHeights removeAllObjects];
            [self.table.nyxPostsRowHeights addObjectsFromArray:@[previousNyxPostsRowHeights]];
            
            NSMutableArray *previousNyxPostsRowBodyTexts = [[NSMutableArray alloc] initWithArray:[self.table.nyxPostsRowBodyTexts objectAtIndex:0]];
            [previousNyxPostsRowBodyTexts addObjectsFromArray:tempArrayForRowBodyText];
            [self.table.nyxPostsRowBodyTexts removeAllObjects];
            [self.table.nyxPostsRowBodyTexts addObjectsFromArray:@[previousNyxPostsRowBodyTexts]];
        }
        else
        {
            [self.table.nyxRowsForSections removeAllObjects];
            [self.table.nyxRowsForSections addObjectsFromArray:@[tempArrayForRowSections]];
            
            [self.table.nyxPostsRowHeights removeAllObjects];
            [self.table.nyxPostsRowHeights addObjectsFromArray:@[tempArrayForRowHeights]];
            
            [self.table.nyxPostsRowBodyTexts removeAllObjects];
            [self.table.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.nController.topViewController.navigationItem.rightBarButtonItem setEnabled:YES];
            if (addData) {
                [self.table reloadTableDataWithScrollToTop:NO];
            } else {
                [self.table reloadTableDataWithScrollToTop:YES];
            }
        });
    }
    [self removeLoadingView];
}

#pragma mark - COMPOSE NEW MAIL MESSAGE

- (void)chooseNickname:(id)sender
{
    PeopleAutocompleteVC *pAuto = [[PeopleAutocompleteVC alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:pAuto];
    [self.nController presentViewController:nc animated:YES completion:^{}];
}

- (void)composeNewMessageFor:(NSNotification *)notification
{
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), notification);
    NSDictionary *userData = [[notification userInfo] objectForKey:@"nKey"];
    NSString *nick = [userData objectForKey:@"nick"];
    NSString *lastActiveTimestamp = [[userData objectForKey:@"active"] objectForKey:@"time"];
    NSString *location = [[userData objectForKey:@"active"] objectForKey:@"location"];
    
    NSMutableString *body = [[NSMutableString alloc] initWithString:@"\nNová zpráva pro uživatele."];
    if (lastActiveTimestamp) {
        Timestamp *ts = [[Timestamp alloc] initWithTimestamp:lastActiveTimestamp];
        [body appendString:[NSString stringWithFormat:@"\nPoslední aktivita: %@", [ts getTime]]];
    }
    if (location) {
        [body appendString:[NSString stringWithFormat:@"\nPoslední lokace: %@", location]];
    }
    
    PeopleRespondVC *response = [[PeopleRespondVC alloc] init];
    response.nick = nick;
    response.bodyText = [[NSAttributedString alloc] initWithString:body];
    response.bodyHeight = 80;
    response.postId = @"";
    response.postData = @{@"other_nick": nick};
    response.nController = self.nController;
    response.peopleRespondMode = kPeopleTableModeMailbox;
    [self.nController pushViewController:response animated:YES];
}


@end
