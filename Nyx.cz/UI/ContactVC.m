//
//  ContactVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ContactVC.h"

@interface ContactVC ()

@end

@implementation ContactVC

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                   target:self
                                                                                   action:@selector(dismissContact)];
    self.navigationItem.rightBarButtonItem = dismissButton;
    
    self.title = @"Napsat zprávu";
    
    _info = [[UITextView alloc] init];
    _info.userInteractionEnabled = NO;
    _info.font = [UIFont systemFontOfSize:18];
    _info.text = @"Zde bude časem možno nahlásit chybu v aplikaci nebo navrhnout zlepšení.";
    [self.view addSubview:_info];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _info.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - DISMISS

- (void)dismissContact
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
