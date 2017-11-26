//
//  MainVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "MainVC.h"
#import "Preferences.h"

#import "SettingsVC.h"
#import "ContactVC.h"


@interface MainVC ()

@end

@implementation MainVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Nyx";
        _firstShow = YES;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    _alphaMenuIncrement = _sideMenuMaxShift / 100;
    _sideMenuBreakingPoint = (long)[UIApplication sharedApplication].delegate.window.frame.size.width * 0.2;
    
    self.contentVc = [[MainContentVC alloc] init];
    [self addChildViewController:self.contentVc];
    [self.view addSubview:self.contentVc.view];
    [self.contentVc didMoveToParentViewController:self];
    
    self.sideMenu = [[SideMenu alloc] init];
    self.sideMenu.delegate = self;
    self.sideMenu.sideMenuMaxShift = _sideMenuMaxShift;
    self.sideMenu.alpha = 0.1;
    [self.view addSubview:self.sideMenu];
    [self.view sendSubviewToBack:self.sideMenu];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainButtonPressed:) name:kMainButtonNotification object:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemReply) target:self action:@selector(sideMenuOpen)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.loginScreen.userIsLoggedIn)
    {
        // Always on first start.
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
    
    if (self.loginScreen.userIsLoggedIn && _firstShow) {
        _firstShow = NO;
        NSString *preferredMenyKey = [Preferences preferredStartingLocation:nil];
        NSString *lastMenuKey = [Preferences lastUserPosition:nil];
        if (!preferredMenyKey && !lastMenuKey) {
            [self sideMenuOpen];
        } else {
            if (preferredMenyKey && [preferredMenyKey length] > 0) {
                [self loadContentForMenuKey:preferredMenyKey];
            } else {
                [self loadContentForMenuKey:lastMenuKey];
            }
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
    if (!self.closeCoverView)
    {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [UIView animateWithDuration:.3 animations:^{
            self.contentVc.view.center = CGPointMake(_viewCenter.x + _sideMenuMaxShift, _viewCenter.y);
            self.sideMenu.alpha = 1;
        } completion:^(BOOL finished) {
            self.closeCoverView = [[CloseCoverView alloc] init];
            self.closeCoverView.delegate = self;
            self.closeCoverView.frame = self.view.bounds;
            [self.contentVc.view addSubview:self.closeCoverView];
            self.navigationItem.leftBarButtonItem.enabled = NO;
        }];
    }
}

- (void)sideMenuClose
{
    [UIView animateWithDuration:.3 animations:^{
        self.contentVc.view.center = CGPointMake(_viewCenter.x, _viewCenter.y);
        self.sideMenu.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self.closeCoverView removeFromSuperview];
        self.closeCoverView = nil;
        self.navigationItem.leftBarButtonItem.enabled = YES;
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
            self.sideMenu.alpha = (translation.x / _alphaMenuIncrement) / 100;
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
    [self.contentVc loadContentWithNavigationController:self.navigationController];
}

#pragma mark - MAIN BUTTON PRESSED

- (void)mainButtonPressed:(id)sender
{
    NSString *button = [[sender userInfo] objectForKey:@"button"];
    if ([button isEqualToString:kMainButtonLogout]) {
        [self mainButtonPressedLogout];
    }
    if ([button isEqualToString:kMainButtonContact]) {
        [self mainButtonPressedContact];
    }
    if ([button isEqualToString:kMainButtonSettings]) {
        [self mainButtonPressedSettings];
    }
}

- (void)mainButtonPressedLogout
{
    NSString *m = @"Opravdu chceš zrušit autorizaci?\nPro novou autorizaci bude nutné smazat součastný kód z účtu na nyxu přes web a zadat nový jako při prvním spuštění aplikace.";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Zrušit autorizaci"
                                                                   message:m
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [Preferences auth_nick:@""];
        [Preferences auth_token:@""];
        [self.closeCoverView viewTapped];
        self.loginScreen.userIsLoggedIn = NO;
        [self presentViewController:self.loginScreen animated:YES completion:^{}];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:^{}];
}

- (void)mainButtonPressedContact
{
    ContactVC *contact = [[ContactVC alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:contact];
    [self presentViewController:nc animated:YES completion:^{}];
}

- (void)mainButtonPressedSettings
{
    SettingsVC *settings = [[SettingsVC alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:settings];
    [self presentViewController:nc animated:YES completion:^{}];
}


@end
