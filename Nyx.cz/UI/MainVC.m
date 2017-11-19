//
//  MainVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "MainVC.h"
#import "Preferences.h"

@interface MainVC ()

@end

@implementation MainVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Nyx";
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
    
    self.loginScreen = [[LoginScreenVC alloc] init];
    
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgeGesture:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;
    leftEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:leftEdgeGesture];
    
    _sideMenuMaxShift = (long)[UIApplication sharedApplication].delegate.window.frame.size.width * 0.8;
    _sideMenuBreakingPoint = (long)[UIApplication sharedApplication].delegate.window.frame.size.width * 0.2;
    
    self.contentVc = [[MainContentVC alloc] init];
    [self addChildViewController:self.contentVc];
    [self.view addSubview:self.contentVc.view];
    [self.contentVc didMoveToParentViewController:self];
    
    self.sideMenu = [[SideMenu alloc] init];
    self.sideMenu.delegate = self;
    self.sideMenu.sideMenuMaxShift = _sideMenuMaxShift;
    [self.view addSubview:self.sideMenu];
    [self.view sendSubviewToBack:self.sideMenu];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.loginScreen.userIsLoggedIn)
    {
        [self presentViewController:self.loginScreen animated:NO completion:^{}];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.sideMenu.frame = self.view.bounds;
    self.contentVc.view.frame = self.view.bounds;
    _viewCenter = self.view.center;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.loginScreen.userIsLoggedIn) {
        NSString *lastMenuKey = [Preferences lastUserPosition:nil];
        if (!lastMenuKey) {
            [self sideMenuOpen];
        } else {
            [self loadContentForMenuKey:lastMenuKey];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - SIDE MENU

- (void)coverViewWouldLikeToCloseMenu
{
    [self sideMenuClose];
}

- (void)sideMenuOpen
{
    [UIView animateWithDuration:.3 animations:^{
        self.contentVc.view.center = CGPointMake(_viewCenter.x + _sideMenuMaxShift, _viewCenter.y);
    } completion:^(BOOL finished) {
        self.closeCoverView = [[CloseCoverView alloc] init];
        self.closeCoverView.delegate = self;
        self.closeCoverView.frame = self.view.bounds;
        [self.contentVc.view addSubview:self.closeCoverView];
    }];
}

- (void)sideMenuClose
{
    [UIView animateWithDuration:.3 animations:^{
        self.contentVc.view.center = CGPointMake(_viewCenter.x, _viewCenter.y);
    } completion:^(BOOL finished) {
        [self.closeCoverView removeFromSuperview];
        self.closeCoverView = nil;
    }];
}

- (void)handleLeftEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture
{
    if (self.contentVc.view.center.x != (_viewCenter.x + _sideMenuMaxShift))
    {
        //    UIView *view = [self.view hitTest:[gesture locationInView:gesture.view] withEvent:nil];
        CGPoint translation = [gesture translationInView:gesture.view];
        if(UIGestureRecognizerStateBegan == gesture.state || UIGestureRecognizerStateChanged == gesture.state)
        {
            self.contentVc.view.center = CGPointMake(_viewCenter.x + translation.x, _viewCenter.y);
        }
        else
        {   // cancel, fail, or ended
            if (self.contentVc.view.center.x < (_viewCenter.x + _sideMenuBreakingPoint)) {
                [self sideMenuClose];
            } else {
                [self sideMenuOpen];
            }
        }
    }
}

#pragma mark - SIDE MENU DELEGATE

- (void)sideMenuSelectedItem:(NSString *)kMenuKey
{
    [Preferences lastUserPosition:kMenuKey];
    [self loadContentForMenuKey:kMenuKey];
    // Fake cover view tapped - to have closing animation.
    [self.closeCoverView viewTapped];
}

#pragma mark - MAIN CONTENT

- (void)loadContentForMenuKey:(NSString *)menuKey
{
    self.title = menuKey;
    [self.contentVc.menuKey setString:menuKey];
    [self.contentVc loadContent];
}


@end
