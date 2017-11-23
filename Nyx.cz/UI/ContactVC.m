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
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                   target:self
                                                                                   action:@selector(dismissContact)];
    self.navigationItem.rightBarButtonItem = dismissButton;
    
    self.title = @"Napsat zprávu - NOT YET";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - DISMISS

- (void)dismissContact
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
