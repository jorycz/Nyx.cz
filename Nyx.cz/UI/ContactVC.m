//
//  ContactVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ContactVC.h"
#import "Colors.h"
#import "Preferences.h"
#import "ServerConnector.h"
#import "JSONParser.h"
#import "ApiBuilder.h"


@interface ContactVC ()

@end

@implementation ContactVC

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = COLOR_BACKGROUND_RESPOND_VIEW;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                   target:self
                                                                                   action:@selector(dismissContact)];
    self.navigationItem.rightBarButtonItem = dismissButton;
    
    self.title = @"Napsat zprávu autorovi";
    
    _tv = [[UITextView alloc] init];
    _tv.backgroundColor = COLOR_BACKGROUND_WHITE;
    _tv.clipsToBounds = YES;
    _tv.layer.cornerRadius = 8.0f;
    [self.view addSubview:_tv];
    
    _button = [[UIButton alloc] init];
    _button.backgroundColor = COLOR_CLEAR;
    [_button setImage:[UIImage imageNamed:@"send"] forState:(UIControlStateNormal)];
    [_button addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    _info = [[UITextView alloc] init];
    _info.backgroundColor = COLOR_CLEAR;
    _info.userInteractionEnabled = NO;
    _info.textColor = COLOR_TIMELABEL;
    _info.textAlignment = NSTextAlignmentCenter;
    _info.font = [UIFont systemFontOfSize:16];
    _info.text = @"Zde je možné nahlásit chybu, nebo navrhnout vylepšení. Pokud posíláte zprávu o chybě, napište co nejvíce detailů.";
    [self.view addSubview:_info];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect f = self.view.frame;
    _tv.frame = CGRectMake(10, 64 + 10, f.size.width - 20, f.size.height / 3.3);
    _button.frame = CGRectMake(f.size.width - 80, _tv.frame.size.height + _tv.frame.origin.y + 10, 60, 60);
    _info.frame = CGRectMake(10, (f.size.height / 2) + 20, f.size.width - 20, f.size.height / 3.3);
}

#pragma mark - POST

- (void)post
{
    if ([_tv.text length] > 0)
    {
        [_button setEnabled:NO];
        [_button setUserInteractionEnabled:NO];
        self.title = @"Pracuji ...";
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSString *body = [NSString stringWithFormat:@"Nyx.cz iOS App Message:\n\n%@", _tv.text];
        NSString *apiRequest = [ApiBuilder apiMailboxSendTo:@"AILAS" message:body];
        
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
                    [self dismissContact];
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

#pragma mark - DISMISS

- (void)dismissContact
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
