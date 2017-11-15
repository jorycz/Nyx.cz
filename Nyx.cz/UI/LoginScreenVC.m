//
//  LoginScreenVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "LoginScreenVC.h"
#import "ApiBuilder.h"
#import "JSONParser.h"
#import "Constants.h"
#import "Preferences.h"

@interface LoginScreenVC ()

@end

@implementation LoginScreenVC

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    _logoView.userInteractionEnabled = NO;
    [_logoView setContentMode:(UIViewContentModeCenter)];
    [self.view addSubview:_logoView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect _mainFrame = self.view.frame;
    _baseX = _mainFrame.size.width / 4;
    _baseY = _mainFrame.size.height / 14;
    _fWidth = _mainFrame.size.width / 2;
    _fHeight = 190;
    _logoView.frame = CGRectMake(_baseX, 258, _fWidth, _fHeight);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.6 animations:^{
        _logoView.frame = CGRectMake(_baseX, _baseY, _fWidth, _fHeight);
    } completion:^(BOOL finished) {
        [self tryToLogIn];
    }];
}

- (void)tryToLogIn
{
    NSString *username = [Preferences username:nil];
    NSString *password = [Preferences password:nil];
    if ([username length] > 0 && [password length] > 0) {
        [self showHideSpinner];
        [self loginWithUsername:username andPassword:password];
    } else {
        [self showLoginAlert];
    }
}

- (void)showLoginAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login"
                                                                   message:@"Zadej uživatelské jméno a heslo."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *login = [UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   NSString *u = [[alert.textFields objectAtIndex:0] text];
                                                   NSString *p = [[alert.textFields objectAtIndex:1] text];
                                                   [self loginWithUsername:u andPassword:p];
                                               }];
    [alert addAction:login];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Jméno";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Heslo";
        textField.secureTextEntry = YES;
    }];
    
    [self presentViewController:alert animated:YES completion:^{
        [self showHideSpinner];
    }];
}

- (void)loginWithUsername:(NSString *)u andPassword:(NSString *)p
{
    if ([u length] < 1 || [p length] < 1) {
        [self presentErrorWithTitle:@"Špatné přihlašovací údaje" andMessage:@"Uživatelské jméno ani heslo nesmí být prázdné."];
        return;
    }
    NSString *apiRequest = [ApiBuilder apiLoginTestForUser:u andPassword:p];
    [Preferences username:u];
    [Preferences password:p];
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), apiRequest);
    self.sc = [[ServerConnector alloc] init];
    self.sc.delegate = self;
    [self.sc downloadDataForApiRequest:apiRequest];
}

- (void)downloadFinishedWithData:(NSData *)data
{
    if (!data)
    {
        [self presentErrorWithTitle:@"Žádná data" andMessage:@"Nelze se připojit na server."];
        NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"data is nil!");
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
//            NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), jp.jsonDictionary);
            if ([[jp.jsonDictionary objectForKey:@"result"] isEqualToString:@"error"])
            {
                [self presentErrorWithTitle:@"Špatné přihlašovací údaje" andMessage:[jp.jsonDictionary objectForKey:@"error"]];
            }
            else
            {
                [self presentNyxScreen];
            }
        }
    }
}

#pragma mark - RESULT

- (void)presentErrorWithTitle:(NSString *)title andMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showHideSpinner];
        PRESENT_ERROR(title, message)
        [self showLoginAlert];
    });
}

- (void)presentNyxScreen
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showHideSpinner];

        self.mainScreen = [[MainVC alloc] init];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.mainScreen];
        [self presentViewController:nc animated:YES completion:^{
            SideMenu *menu = [[SideMenu alloc] initWithFrame:self.view.bounds];
            [self.view insertSubview:menu belowSubview:self.mainScreen.view];
        }];
    });
}

#pragma mark - SPINNER

- (void)showHideSpinner
{
    if (!self.spinner) {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        [self.view addSubview:self.spinner];
        [self.spinner startAnimating];
        self.spinner.center = self.view.center;
    } else {
        [self.spinner stopAnimating];
        self.spinner = nil;
    }
}

@end



