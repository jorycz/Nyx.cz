//
//  NewFeedPostVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 21/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "NewFeedPostVC.h"
#import "JSONParser.h"


@interface NewFeedPostVC ()

@end

@implementation NewFeedPostVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.title = @"Nový status";
    }
    return self;
}

- (void)dealloc
{
}

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tv = [[UITextView alloc] init];
    //    [self.responseView setTextContainerInset:(UIEdgeInsetsZero)];
    _tv.backgroundColor = [UIColor whiteColor];
    _tv.clipsToBounds = YES;
    _tv.layer.cornerRadius = 8.0f;
    [self.view addSubview:_tv];
    
    _button = [[UIButton alloc] init];
    _button.backgroundColor = [UIColor whiteColor];
    [_button setImage:[UIImage imageNamed:@"send"] forState:(UIControlStateNormal)];
    [_button addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                   target:self
                                                                                   action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = dismissButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect f = self.view.frame;
    _tv.frame = CGRectMake(10, 64 + 10, f.size.width - 20, f.size.height / 3.3);
    _button.frame = CGRectMake(f.size.width - 80, _tv.frame.size.height + _tv.frame.origin.y + 10, 60, 60);
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)post
{
    if ([_tv.text length] > 0) {
        [_button setEnabled:NO];
        [_button setUserInteractionEnabled:NO];
        self.title = @"Ukládám ...";
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *apiRequest = [ApiBuilder apiFeedOfFriendsPostMessage:_tv.text];
        ServerConnector *sc = [[ServerConnector alloc] init];
        sc.delegate = self;
        sc.identifitaion = nil;
        [sc downloadDataForApiRequest:apiRequest];
    }
}

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
                [self presentErrorWithTitle:@"Chyba ze serveru:" andMessage:[jp.jsonDictionary objectForKey:@"error"]];
            }
            else
            {
                // NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), jp.jsonDictionary);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismiss];
                    POST_NOTIFICATION_FRIENDS_FEED_CHANGED
                });
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

