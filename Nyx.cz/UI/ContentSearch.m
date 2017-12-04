//
//  ContentSearch.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ContentSearch.h"

#import "LoadingView.h"
#import "JSONParser.h"
#import "ApiBuilder.h"
#import "ComputeRowHeight.h"


@implementation ContentSearch

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        _firstInit = YES;
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataForMainContent) name:kNotificationFriendsFeedChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrameForCurrentStatusBar) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
        
        _nickToSearch = [[NSMutableString alloc] init];
        _textToSearch = [[NSMutableString alloc] init];
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
        self.table.peopleTableMode = kPeopleTableModeSearch;
        [self addSubview:self.table.view];
        
        [self adjustFrameForCurrentStatusBar];
        
        // - 65 is there because there is big avatar left of table cell body text view.
        _widthForTableCellBodyTextView = self.frame.size.width - kWidthForTableCellBodyTextViewSubstract;
        
        self.nController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                                                             target:self
                                                                                                                             action:@selector(showSearchDialog)];
        
        [self showSearchDialog];
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

#pragma mark - SEARCH DIALOG

- (void)showSearchDialog
{
    [self.nController.topViewController.navigationItem.rightBarButtonItem setEnabled:NO];
    
    [_nickToSearch setString:@""];
    [_textToSearch setString:@""];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Vyhledávání"
                                                                   message:@"Vyhledat je možné dle nicku a textu."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *login = [UIAlertAction actionWithTitle:@"Vyhledat" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action) {
                                                      [_nickToSearch setString:[[alert.textFields objectAtIndex:0] text]];
                                                      [_textToSearch setString:[[alert.textFields objectAtIndex:1] text]];
                                                      [self refreshDataForMainContent];
                                                  }];
    [alert addAction:login];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Nick";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Text";
    }];
    [self.nController presentViewController:alert animated:YES completion:^{}];
}

#pragma mark - DATA

- (void)getFreshData
{
    NSString *apiRequest = [ApiBuilder apiSearchFor:_nickToSearch andText:_textToSearch forPosition:@""];
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
                NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), [jp.jsonDictionary objectForKey:@"error"]);
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
    
    NSMutableArray *postDictionaries = [[NSMutableArray alloc] init];
    [postDictionaries addObjectsFromArray:[nyxDictionary objectForKey:@"data"]];
    
    if ([postDictionaries count] > 0)
    {
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
        
        // First discussion load - remove all data and start again
        [self.table.nyxRowsForSections removeAllObjects];
        [self.table.nyxRowsForSections addObjectsFromArray:@[tempArrayForRowSections]];
        
        [self.table.nyxPostsRowHeights removeAllObjects];
        [self.table.nyxPostsRowHeights addObjectsFromArray:@[tempArrayForRowHeights]];
        
        [self.table.nyxPostsRowBodyTexts removeAllObjects];
        [self.table.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.nController.topViewController.navigationItem.rightBarButtonItem setEnabled:YES];
            [self.table reloadTableDataWithScrollToTop:YES];
        });
    } else {
        PRESENT_ERROR(@"Error", @"No data from server.")
    }
    
    [self removeLoadingView];
}

@end
