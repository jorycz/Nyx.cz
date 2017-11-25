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
        
        CGRect f = self.bounds;
        CGFloat navigationBarHeight = self.nController.navigationBar.frame.size.height;
        CGFloat statusBarHeigh = [UIApplication sharedApplication].statusBarFrame.size.height;
        // NSLog(@"- navigation bar height %li - status bar height %li - ", (long)navigationBarHeight, (long)statusBarHeigh);
        self.table.view.frame = CGRectMake(0, navigationBarHeight + statusBarHeigh, f.size.width, f.size.height - (navigationBarHeight + statusBarHeigh));
        
        // - 65 is there because there is big avatar left of table cell body text view.
        _widthForTableCellBodyTextView = self.frame.size.width - kWidthForTableCellBodyTextViewSubstract;
        
        self.nController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                                                             target:self
                                                                                                                             action:@selector(chooseNickname:)];
        
        [self refreshDataForMainContent];
    }
}

- (void)refreshDataForMainContent
{
    [self placeLoadingView];
    [self getFreshData];
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
    NSString *apiRequest = [ApiBuilder apiMailbox];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.delegate = self;
    sc.identifitaion = _serverIdentificationMailbox;
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
                    [self configureTableWithJson:jp.jsonDictionary];
                }
                if ([identification isEqualToString:_serverIdentificationMailboxOlderMessages]) {
                    [self addDataToTableWithJson:jp.jsonDictionary];
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

#pragma mark - TABLE

- (void)configureTableWithJson:(NSDictionary *)nyxDictionary
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
            ComputeRowHeight *rowHeight = [[ComputeRowHeight alloc] initWithText:[d objectForKey:@"content"] forWidth:_widthForTableCellBodyTextView andWithMinHeight:40];
            [tempArrayForRowHeights addObject:[NSNumber numberWithFloat:rowHeight.heightForRow]];
            [tempArrayForRowBodyText addObject:rowHeight.attributedText];
        }
        [self.table.nyxRowsForSections removeAllObjects];
        [self.table.nyxRowsForSections addObjectsFromArray:@[tempArrayForRowSections]];
        [self.table.nyxPostsRowHeights removeAllObjects];
        [self.table.nyxPostsRowHeights addObjectsFromArray:@[tempArrayForRowHeights]];
        [self.table.nyxPostsRowBodyTexts removeAllObjects];
        [self.table.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table reloadTableData];
        });
    }
    [self removeLoadingView];
}

- (void)addDataToTableWithJson:(NSDictionary *)nyxDictionary
{
    //    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), nyxDictionary);
    
    // PRESERVE ALREADY INSERTED ARRAYS and add to these arrays !
    
    NSMutableArray * postDictionaries = [[NSMutableArray alloc] init];
    [postDictionaries addObjectsFromArray:[nyxDictionary objectForKey:@"data"]];
    
    if ([postDictionaries count] > 0)
    {
        [self.table.nyxSections removeAllObjects];
        [self.table.nyxSections addObjectsFromArray:@[kDisableTableSections]];
        
        // Add FEED post as first cell here also.
        NSMutableArray *tmpNyxRowsForSections = [[NSMutableArray alloc] initWithArray:[self.table.nyxRowsForSections objectAtIndex:0]];
        [tmpNyxRowsForSections addObjectsFromArray:postDictionaries];
        [self.table.nyxRowsForSections removeAllObjects];
        [self.table.nyxRowsForSections addObjectsFromArray:@[tmpNyxRowsForSections]];

        
        NSMutableArray *tempArrayForRowHeights = [[NSMutableArray alloc] init];
        NSMutableArray *tempArrayForRowBodyText = [[NSMutableArray alloc] init];
        
        for (NSDictionary *d in postDictionaries)
        {
            // Calculate heights and create array with same structure just only for row height.
            // 60 is minimum height - table ROW height is initialized to 70 below ( 70 - nick name )
            ComputeRowHeight *rowHeight = [[ComputeRowHeight alloc] initWithText:[d objectForKey:@"content"] forWidth:_widthForTableCellBodyTextView andWithMinHeight:40];
            [tempArrayForRowHeights addObject:[NSNumber numberWithFloat:rowHeight.heightForRow]];
            [tempArrayForRowBodyText addObject:rowHeight.attributedText];
        }
        
        NSMutableArray *tmpNyxPostsRowHeights = [[NSMutableArray alloc] initWithArray:[self.table.nyxPostsRowHeights objectAtIndex:0]];
        [tmpNyxPostsRowHeights addObjectsFromArray:tempArrayForRowHeights];
        [self.table.nyxPostsRowHeights removeAllObjects];
        [self.table.nyxPostsRowHeights addObjectsFromArray:@[tmpNyxPostsRowHeights]];
        
        NSMutableArray *tmpNyxPostsRowBodyTexts = [[NSMutableArray alloc] initWithArray:[self.table.nyxPostsRowBodyTexts objectAtIndex:0]];
        [tmpNyxPostsRowBodyTexts addObjectsFromArray:tempArrayForRowBodyText];
        [self.table.nyxPostsRowBodyTexts removeAllObjects];
        [self.table.nyxPostsRowBodyTexts addObjectsFromArray:@[tmpNyxPostsRowBodyTexts]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.nController.topViewController.navigationItem.rightBarButtonItem setEnabled:YES];
            [self.table reloadTableData];
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
