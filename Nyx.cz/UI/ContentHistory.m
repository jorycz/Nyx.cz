//
//  ContentHistory.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ContentHistory.h"

#import "LoadingView.h"
#import "JSONParser.h"
#import "ApiBuilder.h"

#import "Constants.h"


@implementation ContentHistory

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        _firstInit = YES;
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
        self.table = [[ContentTableWithList alloc] initWithRowHeight:30];
        self.table.nController = self.nController;
        [self addSubview:self.table.view];
        
        CGRect f = self.bounds;
        CGFloat navigationBarHeight = self.nController.navigationBar.frame.size.height;
        CGFloat statusBarHeigh = [UIApplication sharedApplication].statusBarFrame.size.height;
        // NSLog(@"- navigation bar height %li - status bar height %li - ", (long)navigationBarHeight, (long)statusBarHeigh);
        self.table.view.frame = CGRectMake(0, navigationBarHeight + statusBarHeigh, f.size.width, f.size.height - (navigationBarHeight + statusBarHeigh));
        
        //        self.nController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
        //                                                                                                                             target:self
        //                                                                                                                             action:@selector(chooseNickname:)];
        [self refreshDataForMainContent];
    }
}

- (void)refreshDataForMainContent
{
    [self placeLoadingView];
    [self getFreshData];
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
    NSString *apiRequest = [ApiBuilder apiBookmarksHistory];
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
    //    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), nyxDictionary);
    
    NSDictionary *postDictionaries = [nyxDictionary objectForKey:@"data"];
    NSArray *discussions = [postDictionaries objectForKey:@"discussions"];
    
    [self.table.nyxSections removeAllObjects];
    [self.table.nyxSections addObject:kDisableTableSections];
    [self.table.nyxRowsForSections removeAllObjects];
    
    if (postDictionaries && discussions)
    {
        NSMutableArray *discussionsInSection = [[NSMutableArray alloc] init];
        for (NSDictionary *discussion in discussions)
        {
            [discussionsInSection addObject:discussion];
        }
        [self.table.nyxRowsForSections addObject:discussionsInSection];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadTableData];
    });
    [self removeLoadingView];
}


@end
