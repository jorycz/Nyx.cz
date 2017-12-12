//
//  ContentPeople.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ContentPeople.h"

#import "LoadingView.h"
#import "JSONParser.h"
#import "ApiBuilder.h"

// #import "PeopleRespondVC.h" psat mail rovnou z listu ? nebo presmerovat do posty pomoci notifikace ? ....
#import "Constants.h"
#import "Timestamp.h"


@implementation ContentPeople

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataForMainContent) name:kNotificationPeopleChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrameForCurrentStatusBar) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
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
        self.table = [[ContentTableWithPeople alloc] initWithRowHeight:70];
        self.table.nController = self.nController;
        self.table.allowsSelection = YES;
        self.table.peopleTableMode = kPeopleTableModeFriends;
        [self addSubview:self.table.view];
        
        [self adjustFrameForCurrentStatusBar];
        
        // - 65 is there because there is big avatar left of table cell body text view.
        _widthForTableCellBodyTextView = self.frame.size.width - kWidthForTableCellBodyTextViewSubstract;
        
//        self.nController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
//                                                                                                                             target:self
//                                                                                                                             action:@selector(refreshDataForMainContent)];
        
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
    NSString *apiRequest = [ApiBuilder apiPeopleFriends];
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
    
    NSMutableArray *postDictionaries = [[NSMutableArray alloc] init];
    [postDictionaries addObjectsFromArray:[nyxDictionary objectForKey:@"data"]];

    if ([postDictionaries count] > 0)
    {
        // Add FEED post as first cell here also.
        [self.table.nyxSections removeAllObjects];
        [self.table.nyxSections addObjectsFromArray:@[kDisableTableSections]];

        NSMutableArray *tempArrayForRowSections = [[NSMutableArray alloc] init];
        NSMutableArray *tempArrayForRowBodyText = [[NSMutableArray alloc] init];
        
        for (NSDictionary *d in postDictionaries)
        {
            [tempArrayForRowSections addObject:d];
            
            NSDictionary *active = [d objectForKey:@"active"];
            if (active) {
                Timestamp *ts = [[Timestamp alloc] initWithTimestamp:[active objectForKey:@"time"]];
                NSString *location = [active objectForKey:@"location"];
                NSMutableString *body = [[NSMutableString alloc] initWithString:@""];
                [body appendString:[NSString stringWithFormat:@"Poslední aktivita: %@", [ts getTime]]];
                [body appendString:[NSString stringWithFormat:@"\nPoslední lokace: %@", location]];
                NSAttributedString *atStr = [[NSAttributedString alloc] initWithString:body];
                [tempArrayForRowBodyText addObject:atStr];
            } else {
                [tempArrayForRowBodyText addObject:[[NSAttributedString alloc] initWithString:@""]];
            }
        }
        [self.table.nyxRowsForSections removeAllObjects];
        [self.table.nyxRowsForSections addObjectsFromArray:@[tempArrayForRowSections]];
        [self.table.nyxPostsRowBodyTexts removeAllObjects];
        [self.table.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table reloadTableDataWithScrollToTop:YES];
        });
    }
    [self removeLoadingView];
}


#pragma mark - COMPOSE NEW MAIL MESSAGE

- (void)composeNewMessageFor:(NSNotification *)notification
{
//    //    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), notification);
//    NSDictionary *userData = [[notification userInfo] objectForKey:@"nKey"];
//    NSString *nick = [userData objectForKey:@"nick"];
//    NSString *lastActiveTimestamp = [[userData objectForKey:@"active"] objectForKey:@"time"];
//    NSString *location = [[userData objectForKey:@"active"] objectForKey:@"location"];
//
//    NSMutableString *body = [[NSMutableString alloc] initWithString:@"\nNová zpráva pro uživatele."];
//    if (lastActiveTimestamp) {
//        Timestamp *ts = [[Timestamp alloc] initWithTimestamp:lastActiveTimestamp];
//        [body appendString:[NSString stringWithFormat:@"\nPoslední aktivita: %@", [ts getTime]]];
//    }
//    if (location) {
//        [body appendString:[NSString stringWithFormat:@"\nPoslední lokace: %@", location]];
//    }
//
//    PeopleRespondVC *response = [[PeopleRespondVC alloc] init];
//    response.nick = nick;
//    response.bodyText = [[NSAttributedString alloc] initWithString:body];
//    response.bodyHeight = 80;
//    response.postId = @"";
//    response.postData = @{@"other_nick": nick};
//    response.nController = self.nController;
//    response.peopleRespondMode = kPeopleTableModeMailbox;
//    [self.nController pushViewController:response animated:YES];
}

@end
