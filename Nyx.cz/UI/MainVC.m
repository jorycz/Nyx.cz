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
        _gettingNewNotifications = NO;
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
    
    if ([Preferences preferredStartingLocation:nil] && [[Preferences preferredStartingLocation:nil] length] > 0)
        [Preferences lastUserPosition:[Preferences preferredStartingLocation:nil]];
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
            if (preferredMenyKey && [preferredMenyKey length] > 0)
            {
                [Preferences lastUserPosition:preferredMenyKey];
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
        [self getNewNyxNotifications];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        [UIView animateWithDuration:.3 animations:^{
            self.contentVc.view.center = CGPointMake(_viewCenter.x + _sideMenuMaxShift, _viewCenter.y);
            self.sideMenu.alpha = 1;
        } completion:^(BOOL finished) {
            self.closeCoverView = [[CloseCoverView alloc] init];
            self.closeCoverView.delegate = self;
            self.closeCoverView.frame = self.view.bounds;
            [self.contentVc.view addSubview:self.closeCoverView];
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
        self.navigationItem.rightBarButtonItem.enabled = YES;
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

#pragma mark - NYX NOTIFICATIONS CHECK

- (void)getNewNyxNotifications
{
    if (!_gettingNewNotifications) {
        _gettingNewNotifications = YES;
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive ||
            [[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *apiRequest = [ApiBuilder apiFeedNoticesAndKeepNew:YES];
        ServerConnector *sc = [[ServerConnector alloc] init];
        sc.delegate = self;
        [sc downloadDataForApiRequest:apiRequest];
    }
}

- (void)downloadFinishedWithData:(NSData *)data withIdentification:(NSString *)identification
{
    if (!data)
    {
//        [self presentErrorWithTitle:@"Žádná data" andMessage:@"Nelze se připojit na server."];
    }
    else
    {
        JSONParser *jp = [[JSONParser alloc] initWithData:data];
        if (!jp.jsonDictionary)
        {
            NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), jp.jsonErrorString);
            NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), jp.jsonErrorDataString);
//            [self presentErrorWithTitle:@"Chyba při parsování" andMessage:jp.jsonErrorString];
        }
        else
        {
            if ([[jp.jsonDictionary objectForKey:@"result"] isEqualToString:@"error"])
            {
//                [self presentErrorWithTitle:@"Chyba ze serveru:" andMessage:[jp.jsonDictionary objectForKey:@"error"]];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self notifcationData:jp.jsonDictionary];
                });
            }
        }
    }
}

- (void)notifcationData:(NSDictionary *)data
{
    BOOL mail = NO;
    BOOL notification = NO;
    
    NSString *mailData = [[[data objectForKey:@"data"] objectForKey:@"system"] objectForKey:@"unread_post"];
    if (mailData && [mailData length] > 0) {
        mail = YES;
    }
    
    NSInteger lastVisit = [[[data objectForKey:@"data"] objectForKey:@"notice_last_visit"] integerValue];
    NSArray *notices = [[data objectForKey:@"data"] objectForKey:@"items"];
    for (NSDictionary *n in notices) {
        NSInteger nTime = [[n objectForKey:@"time"] integerValue];
        if (nTime > lastVisit) {
            notification = YES;
            break;
        }
    }
    
    switch ([[UIApplication sharedApplication] applicationState]) {
        case UIApplicationStateActive:
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.sideMenu showNewMailAlert:mail andNyxNotificationAlert:notification];
        }
            break;
        case UIApplicationStateInactive:
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.sideMenu showNewMailAlert:mail andNyxNotificationAlert:notification];
        }
            break;
        case UIApplicationStateBackground:
        {
            if (mail || notification)
            {
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
            } else {
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            }
        }
            break;
        default:
            break;
    }
    
    _gettingNewNotifications = NO;
}



@end
