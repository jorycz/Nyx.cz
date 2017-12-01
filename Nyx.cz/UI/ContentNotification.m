//
//  ContentNotification.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ContentNotification.h"

#import "LoadingView.h"
#import "JSONParser.h"
#import "ApiBuilder.h"
#import "ComputeRowHeight.h"


@implementation ContentNotification

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        _firstInit = YES;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataForMainContent) name:kNotificationFriendsFeedChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrameForCurrentStatusBar) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"");
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
        self.table.peopleTableMode = kPeopleTableModeFeed;
        [self addSubview:self.table.view];
        
        [self adjustFrameForCurrentStatusBar];
        
        // - 65 is there because there is big avatar left of table cell body text view.
        _widthForTableCellBodyTextView = self.frame.size.width - kWidthForTableCellBodyTextViewSubstract;
        
//        self.nController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
//                                                                                                                             target:self
//                                                                                                                             action:@selector(composeNewPost:)];
        
        [self refreshDataForMainContent];
    }
}

- (void)adjustFrameForCurrentStatusBar
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect f = self.bounds;
        //        CGFloat navigationBarHeight = self.nController.navigationBar.frame.size.height;
        //        CGFloat statusBarHeigh = [UIApplication sharedApplication].statusBarFrame.size.height;
        //         NSLog(@"- navigation bar height %li - status bar height %li - ", (long)navigationBarHeight, (long)statusBarHeigh);
        self.table.view.frame = CGRectMake(0, kNavigationBarHeight + kStatusBarStandardHeight, f.size.width, f.size.height - (kNavigationBarHeight + [Preferences statusBarHeigh:0]));
    });
}

- (void)refreshDataForMainContent
{
    [self placeLoadingView];
    [self getFreshData];
}

- (void)placeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.nController.topViewController.navigationItem.rightBarButtonItem setEnabled:NO];
        LoadingView *lv = [[LoadingView alloc] initWithFrame:self.bounds];
        [self addSubview:lv];
    });
}

- (void)removeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.nController.topViewController.navigationItem.rightBarButtonItem setEnabled:YES];
        [[self viewWithTag:kLoadingCoverViewTag] removeFromSuperview];
    });
}

#pragma mark - DATA

- (void)getFreshData
{
    NSString *apiRequest = [ApiBuilder apiFeedNoticesAndKeepNew:YES];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.delegate = self;
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
                [self configureTableWithJson:jp.jsonDictionary];
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
//    NSMutableArray *_dateSections = [[NSMutableArray alloc] init];
//    NSMutableArray *_datePosts = [[NSMutableArray alloc] init];
//    NSMutableArray *_postsRowHeights = [[NSMutableArray alloc] init];
//    NSMutableArray *_postsRowBodyTexts = [[NSMutableArray alloc] init];
//
//    // Search for unique dates.
//    for (NSDictionary *d in [nyxDictionary objectForKey:@"data"])
//    {
//        Timestamp *ts = [[Timestamp alloc] initWithTimestamp:[d objectForKey:@"time"]];
//        NSString *date = [ts getDayDate];
//        if ([_dateSections indexOfObject:date] == NSNotFound)
//        {
//            [_dateSections addObject:date];
//
//            // Assign object with same day to temp array and then insert this temp array to array which will be DS for rows (in section).
//            NSMutableArray *tempArrayForPosts = [[NSMutableArray alloc] init];
//            NSMutableArray *tempArrayForRowHeights = [[NSMutableArray alloc] init];
//            NSMutableArray *tempArrayForRowBodyText = [[NSMutableArray alloc] init];
//            for (NSDictionary *d in [nyxDictionary objectForKey:@"data"])
//            {
//                Timestamp *tsForAll = [[Timestamp alloc] initWithTimestamp:[d objectForKey:@"time"]];
//                NSString *dateForAll = [tsForAll getDayDate];
//                if ([dateForAll isEqualToString:date]) {
//                    [tempArrayForPosts addObject:d];
//
//                    // Calculate heights and create array with same structure just only for row height.
//                    // 60 is minimum height - table ROW height is initialized to 70 below ( 70 - nick name )
//                    ComputeRowHeight *rowHeight = [[ComputeRowHeight alloc] initWithText:[d objectForKey:@"text"] forWidth:_widthForTableCellBodyTextView minHeight:40 inlineImages:nil];
//                    [tempArrayForRowHeights addObject:[NSNumber numberWithFloat:rowHeight.heightForRow]];
//                    [tempArrayForRowBodyText addObject:rowHeight.attributedText];
//                }
//            }
//            [_datePosts addObject:tempArrayForPosts];
//            [_postsRowHeights addObject:tempArrayForRowHeights];
//            [_postsRowBodyTexts addObject:tempArrayForRowBodyText];
//        }
//    }
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        // SECTIONS - dates in this case
//        [self.table.nyxSections removeAllObjects];
//        [self.table.nyxSections addObjectsFromArray:_dateSections];
//        // WHOLE dictionaries with all data
//        [self.table.nyxRowsForSections removeAllObjects];
//        [self.table.nyxRowsForSections addObjectsFromArray:_datePosts];
//        // Heights computed by attributed texts for rows
//        [self.table.nyxPostsRowHeights removeAllObjects];
//        [self.table.nyxPostsRowHeights addObjectsFromArray:_postsRowHeights];
//        // Formated attributed texts
//        [self.table.nyxPostsRowBodyTexts removeAllObjects];
//        [self.table.nyxPostsRowBodyTexts addObjectsFromArray:_postsRowBodyTexts];
//
//        [self.table reloadTableData];
//    });
    [self removeLoadingView];
}



@end
