//
//  MainVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "MainVC.h"
#import "Preferences.h"
#import "Colors.h"

#import "SettingsVC.h"
#import "ContactVC.h"
#import "NewNoticesForPost.h"


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
        
        _identificationDataRefresh = @"dataRefresh";
        _identificationRemoveAuth = @"removeAuth";
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
    self.view.backgroundColor = [UIColor themeColorMainBackgroundDefault];
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
    
    if (!self.loginScreen.userIsLoggedIn)
    {
        // Always on first start.
        [self presentViewController:self.loginScreen animated:NO completion:^{}];
    }
    
    if (self.loginScreen.userIsLoggedIn && _firstShow) {
        _firstShow = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cancelCurrentNyxSession)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [self.sideMenu setNeedsLayout];
        
        // Store initial Status and Navigation Bar Heights.
        CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        NSLog(@"%@ - %@ : Navigation Bar >> [%li]", self, NSStringFromSelector(_cmd), (long)navigationBarHeight);
        NSLog(@"%@ - %@ : Status Bar >> [%li]", self, NSStringFromSelector(_cmd), (long)statusBarHeight);
        [Preferences statusNavigationBarsHeights:(navigationBarHeight + statusBarHeight)];
        
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

#pragma mark - CANCEL / INACTIVATE CURRENT SESSION

- (void)cancelCurrentNyxSession
{
    NSString *api = [ApiBuilder apiUtilMakeInactive];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.identifitaion = @"";
    sc.delegate = nil;
    [sc downloadDataForApiRequest:api];
}

#pragma mark - NAVIGATION BUTTONS

- (void)enableNavigationButtons:(BOOL)b
{
    for (UIBarButtonItem *item in self.navigationItem.rightBarButtonItems)
        [item setEnabled:b];
    for (UIBarButtonItem *item in self.navigationItem.leftBarButtonItems)
        [item setEnabled:b];
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
        [self enableNavigationButtons:NO];
        [UIView animateWithDuration:.15 animations:^{
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
    [UIView animateWithDuration:.2 animations:^{
        self.contentVc.view.center = CGPointMake(_viewCenter.x, _viewCenter.y);
        self.sideMenu.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self.closeCoverView removeFromSuperview];
        self.closeCoverView = nil;
        [self enableNavigationButtons:YES];
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
    NSString *m = @"Zrušení autorizace odstraní z nyxu autorizační token a bude nutné zadat nový a aplikaci znovu autorizovat jako při prvním spuštění aplikace!";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Zrušit autorizaci?"
                                                                   message:m
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *remove = [UIAlertAction actionWithTitle:@"Zrušit autorizaci"
                                                 style:UIAlertActionStyleDestructive
                                               handler:^(UIAlertAction * action) {
        NSString *api = [ApiBuilder apiUtilRemoveAuthorization];
        ServerConnector *sc = [[ServerConnector alloc] init];
        sc.identifitaion = _identificationRemoveAuth;
        sc.delegate = self;
        [sc downloadDataForApiRequest:api];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:remove];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:^{}];
}

- (void)mainButtonPressedContact
{
    ContactVC *contactScreen = [[ContactVC alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:contactScreen];
    [self presentViewController:nc animated:YES completion:^{}];
}

- (void)mainButtonPressedSettings
{
    SettingsVC *settingsSceen = [[SettingsVC alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:settingsSceen];
    [self presentViewController:nc animated:YES completion:^{}];
}

#pragma mark - REMOVE AUTH

- (void)authorizationRemoved
{
    [Preferences auth_nick:@""];
    [Preferences auth_token:@""];
    [self.closeCoverView viewTapped];
    self.loginScreen.userIsLoggedIn = NO;
    [self presentViewController:self.loginScreen animated:YES completion:^{}];
}


#pragma mark - NYX NOTIFICATIONS CHECK

- (void)getNewNyxNotifications
{
    if (!_gettingNewNotifications) {
        _gettingNewNotifications = YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *apiRequest = [ApiBuilder apiFeedNoticesAndKeepNew:YES];
        ServerConnector *sc = [[ServerConnector alloc] init];
        sc.identifitaion = _identificationDataRefresh;
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
                if ([identification isEqualToString:_identificationRemoveAuth]) {
                    [self presentErrorWithTitle:@"Chyba ze serveru:" andMessage:[jp.jsonDictionary objectForKey:@"error"]];
                }
            }
            else
            {
                if ([identification isEqualToString:_identificationDataRefresh]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self notifcationData:jp.jsonDictionary];
                    });
                }
                if ([identification isEqualToString:_identificationRemoveAuth]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self authorizationRemoved];
                    });
                }
            }
        }
    }
    _gettingNewNotifications = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
}

- (void)presentErrorWithTitle:(NSString *)title andMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        PRESENT_ERROR(title, message)
    });
}

- (void)notifcationData:(NSDictionary *)data
{
    NSInteger mail = 0;
    NSInteger notification = 0;
    
    NSString *mailData = [[data objectForKey:@"system"] objectForKey:@"unread_post"];
    if (mailData && [mailData length] > 0) {
        mail = [mailData integerValue];
    }
    
    NSString *lastVisit = [[data objectForKey:@"data"] objectForKey:@"notice_last_visit"];
    NSInteger last = [lastVisit integerValue];
    
    NSArray *notices = [[data objectForKey:@"data"] objectForKey:@"items"];
    
    for (NSDictionary *n in notices)
    {
        NSInteger nTime = [[n objectForKey:@"time"] integerValue];
        if (nTime > last) {
            notification++;
        }
        NewNoticesForPost *np = [[NewNoticesForPost alloc] initWithPost:n forLastVisit:lastVisit];
        if (np.nPosts && [np.nPosts count] > 0) {
            notification += [np.nPosts count];
        }
        if (np.nThumbup && [np.nThumbup count] > 0) {
            notification += [np.nThumbup count];
        }
        if (np.nThumbsdown && [np.nThumbsdown count] > 0) {
            notification += [np.nThumbsdown count];
        }
    }
    
    switch ([[UIApplication sharedApplication] applicationState]) {
        case UIApplicationStateActive:
        {
            [self.sideMenu showNewMailAlert:mail andNyxNotificationAlert:notification];
        }
            break;
        case UIApplicationStateInactive:
        {
            [self.sideMenu showNewMailAlert:mail andNyxNotificationAlert:notification];
        }
            break;
        default:
            break;
    }
}


@end



