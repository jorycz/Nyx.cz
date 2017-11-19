//
//  MainContentVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "MainContentVC.h"


@interface MainContentVC ()

@end

@implementation MainContentVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.menuKey = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _info = [[UITextField alloc] init];
    _info.text = @"Není vybrána\nžádná sekce.";
    _info.userInteractionEnabled = NO;
    _info.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_info];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _info.frame = self.view.bounds;
}

- (void)loadContent
{
    NSLog(@"%@ - %@ : selected [%@]", self, NSStringFromSelector(_cmd), self.menuKey);
}

@end

