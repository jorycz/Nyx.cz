//
//  SettingsVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "SettingsVC.h"
#import "Constants.h"
#import "Preferences.h"
#import "Colors.h"

#import "StorageManager.h"
#import "LoadingView.h"


@interface SettingsVC ()

@end

@implementation SettingsVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.menuEntries = @[@"Spočítat velikost cache",
                             @"Počáteční lokace",
                             @"Limit pro načtení nepřečtených",
                             @"Sdílet původní obrázky",
                             @"Otevřít v Safari",
                             @"Zobrazovat obrázky",
                             @"Spuštění na pozadí",
                             @"Uložená zpráva",
                             @"Reset nastavení",
                             @"Kopírovat HTML kód",
                             @"Vzhled aplikace"
                             ];
        self.menuSubtitles = @[@"Spočítá a případně umožní vymazat obsah mezipaměti.",
                               @"",
                               @"",
                               @"Zobrazovat v postech originál obrázky.",
                               @"Otevře URL linky v Safari místo v aplikaci.",
                               @"Před sdílením stáhne originální obrázky.",
                               @"",
                               @"Zobrazí uloženou zprávu, pokud existuje.",
                               @"Smaže veškeré nastavení kromě autorizace.",
                               @"Zobrazí možnost zkopírovat HTML kód.",
                               @""
                               ];
    }
    return self;
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
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                   target:self
                                                                                   action:@selector(dismissSettings)];
    self.navigationItem.rightBarButtonItem = dismissButton;
    
    self.title = [NSString stringWithFormat:@"%@ (%@)", @"Nastavení", [self appVersion]];
    
    self.table = [[UITableView alloc] init];
    [self.table setDelegate:self];
    [self.table setDataSource:self];
    [self.table setBackgroundColor:[UIColor themeColorMainBackgroundDefault]];
    [self.table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.table setRowHeight:80];
    [self.view addSubview:self.table];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect f = self.view.bounds;
    CGFloat _maxHeight = f.size.height;
    CGFloat _currentHeight = 92 + ([self.menuEntries count] * 80);
    self.table.frame = CGRectMake(0, 0, self.view.frame.size.width, MIN(_maxHeight, _currentHeight));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - DISMISS

- (void)dismissSettings
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - TABLE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdForReuse = @"uniqCell";
    SettingsVCCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdForReuse];
    if (cell == nil)
    {
        cell = [[SettingsVCCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdForReuse];
        cell.backgroundColor = [UIColor themeColorMainBackgroundDefault];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:22];
    }
    
    cell.tag = (int)indexPath.row;
    cell.textLabel.text = [self.menuEntries objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.menuSubtitles objectAtIndex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.textColor = [UIColor themeColorStandardText];
    cell.detailTextLabel.textColor = [UIColor themeColorStandardText];
    
    [cell.settingsSwitch removeFromSuperview];
    cell.settingsSwitch = nil;
    
    if (indexPath.row == 1) {
        NSString *startingLocation = [Preferences preferredStartingLocation:nil];
        NSString *last = [Preferences lastUserPosition:nil] ? [Preferences lastUserPosition:nil] : @"Neznámá!" ;
        NSString *missingLocation = [NSString stringWithFormat:@"Neurčena. Poslední navštívená: %@", last];
        (startingLocation && [startingLocation length] > 0) ? [cell.detailTextLabel setText:startingLocation] : [cell.detailTextLabel setText:missingLocation];
    }
    if (indexPath.row == 2) {
        if ([Preferences maximumUnreadPostsLoad:nil]) {
            [cell.detailTextLabel setText:[Preferences maximumUnreadPostsLoad:nil]];
        }
    }
    if (indexPath.row == 3) {
        cell.settingsSwitch = [self placeSwitchWithTag:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == 4) {
        cell.settingsSwitch = [self placeSwitchWithTag:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == 5) {
        cell.settingsSwitch = [self placeSwitchWithTag:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == 6) {
        NSString *lastBackgroundRefresh = [Preferences actualDateOfBackgroundRefresh:nil];
        (lastBackgroundRefresh && [lastBackgroundRefresh length] > 0) ? [cell.detailTextLabel setText:lastBackgroundRefresh] : [cell.detailTextLabel setText:@"Natím nenačtena žádná data na pozadí."];
    }
    if (indexPath.row == 7) {
        if ([[[[Preferences messagesForDiscussion:nil] firstObject] objectForKey:@"text"] length] > 0) {
            [cell.detailTextLabel setText:@"Existuje uložená zpráva. Tapni pro detail."];
        } else {
            [cell.detailTextLabel setText:@"Žádná uložená zpráva."];
        }
    }
    // 8 ...
    if (indexPath.row == 9) {
        cell.settingsSwitch = [self placeSwitchWithTag:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 10) {
        if ([Preferences theme:nil]) {
            [cell.detailTextLabel setText:[Preferences theme:nil]];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self countCache];
            break;
        case 1:
            [self chooseStartingLocation];
            break;
        case 2:
            [self chooseMaximumUnreadLoad];
            break;
            
        // NO ACTION FOR CELL TAP FOR SWITCH BASED CELLS ...
            
        case 6:
        {
            NSString *lastBackgroundRefresh;
            if ([[Preferences actualDateOfBackgroundRefresh:nil] length] > 0) {
                lastBackgroundRefresh = [Preferences actualDateOfBackgroundRefresh:nil];
            } else {
                lastBackgroundRefresh = @"Zatím neproběhla žádná aktualizace dat na pozadí.";
            }
            UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Poslední obnova dat na pozadí"
                                                                       message:lastBackgroundRefresh
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {}];
            [a addAction:ok];
            [self presentViewController:a animated:YES completion:^{}];
        }
            break;
        case 7:
        {
            NSString *storedMessage;
            if ([[[[Preferences messagesForDiscussion:nil] firstObject] objectForKey:@"text"] length] > 0) {
                storedMessage = [[[Preferences messagesForDiscussion:nil] firstObject] objectForKey:@"text"];
            } else {
                storedMessage = @"Žádná uložená zpráva.";
            }
            
            UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Uložená zpráva"
                                                                       message:storedMessage
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {}];
            UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Smazat" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
                [Preferences messagesForDiscussion:(NSMutableArray *)@[]];
                [self.table reloadData];
            }];
            if ([[[[Preferences messagesForDiscussion:nil] firstObject] objectForKey:@"text"] length] > 0)
                [a addAction:delete];
            [a addAction:ok];
            [self presentViewController:a animated:YES completion:^{}];
        }
            break;
        case 8:
            [self deleteSettings];
            break;
        case 10:
        {
            UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Vyber vzhled aplikace"
                                                                       message:@"Po zvolení se aplikace ukončí a bude nutné ji znovu spustit."
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *light = [UIAlertAction actionWithTitle:kThemeLight style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                [Preferences theme:kThemeLight];
                [self applicationWillBeClosedWarning];
            }];
            [a addAction:light];
            UIAlertAction *dark = [UIAlertAction actionWithTitle:kThemeDark style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                [Preferences theme:kThemeDark];
                [self applicationWillBeClosedWarning];
            }];
            [a addAction:dark];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {}];
            [a addAction:cancel];
            [self presentViewController:a animated:YES completion:^{}];
        }
            break;
        default:
            break;
    }
}

- (void)applicationWillBeClosedWarning
{
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Ukončení aplikace"
                                                               message:@"Po kliknutí na OK se aplikace ukončí."
                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }];
    [a addAction:ok];
    [self presentViewController:a animated:YES completion:^{}];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Smazané věci nelze obnovit!";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor themeColorBackgroundAlert];
}


#pragma mark - SWITCH

- (UISwitch *)placeSwitchWithTag:(NSInteger)tag
{
    UISwitch *s = [[UISwitch alloc] init];
    [s addTarget:self action:@selector(switchChanged:) forControlEvents:(UIControlEventValueChanged)];
    s.tag = tag;
    
    // INITIAL STATE
    if (tag == 3)
        [[Preferences shareFullSizeImages:nil] length] > 0 ? [s setOn:YES] : [s setOn:NO] ;
    if (tag == 4)
        [[Preferences openUrlsInSafari:nil] length] > 0 ? [s setOn:YES] : [s setOn:NO] ;
    if (tag == 5)
        [[Preferences showImagesInlineInPost:nil] length] > 0 ? [s setOn:YES] : [s setOn:NO] ;
    if (tag == 9)
        [[Preferences allowCopyOfHTMLSourceCode:nil] length] > 0 ? [s setOn:YES] : [s setOn:NO] ;
    
    return s;
}

- (void)switchChanged:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    
    if (s.tag == 3)
        s.isOn ? [Preferences shareFullSizeImages:@"yes"] : [Preferences shareFullSizeImages:@""] ;
    if (s.tag == 4)
        s.isOn ? [Preferences openUrlsInSafari:@"yes"] : [Preferences openUrlsInSafari:@""] ;
    if (s.tag == 5)
        s.isOn ? [Preferences showImagesInlineInPost:@"yes"] : [Preferences showImagesInlineInPost:@""] ;
    if (s.tag == 9)
        s.isOn ? [Preferences allowCopyOfHTMLSourceCode:@"yes"] : [Preferences allowCopyOfHTMLSourceCode:@""] ;
}


#pragma mark - ACTIONS

- (void)countCache
{
    [self placeLoadingView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        StorageManager *sm = [[StorageManager alloc] init];
        NSDictionary *d = [sm countCache];
        NSUInteger files = [[d objectForKey:@"files"] integerValue];
        NSUInteger size = [[d objectForKey:@"size"] integerValue];
        NSString *m = [NSString stringWithFormat:@"Využito %li MB (Počet souborů %li).", (long)size, (long)files];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Velikost cache"
                                                                           message:m
                                                                    preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                         style:(UIAlertActionStyleDefault)
                                                       handler:^(UIAlertAction * _Nonnull action) {}];
            UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Empty Cache"
                                                             style:(UIAlertActionStyleDestructive)
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               [sm emptyCache];
                                                           }];
            [alert addAction:delete];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:^{
                [self removeLoadingView];
            }];
        });
    });
}

- (void)chooseStartingLocation
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Vyber oblíbenou startovní lokaci"
                                                                   message:@"Pokud aplikaci déle nepoužiješ a systém ji ukončí, tato lokace se při příštím spuštění načte jako první."
                                                            preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *kMenuOverviewLoc = [UIAlertAction actionWithTitle:kMenuOverview style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [Preferences preferredStartingLocation:kMenuOverview];
        [self.table reloadData];
    }];
    UIAlertAction *kMenuMailLoc = [UIAlertAction actionWithTitle:kMenuMail style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [Preferences preferredStartingLocation:kMenuMail];
        [self.table reloadData];
    }];
    UIAlertAction *kMenuBookmarksLoc = [UIAlertAction actionWithTitle:kMenuBookmarks style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [Preferences preferredStartingLocation:kMenuBookmarks];
        [self.table reloadData];
    }];
    UIAlertAction *kMenuHistoryLoc = [UIAlertAction actionWithTitle:kMenuHistory style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [Preferences preferredStartingLocation:kMenuHistory];
        [self.table reloadData];
    }];
    UIAlertAction *kMenuPeopleLoc = [UIAlertAction actionWithTitle:kMenuFriendList style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [Preferences preferredStartingLocation:kMenuFriendList];
        [self.table reloadData];
    }];
    UIAlertAction *kMenuNotificationsLoc = [UIAlertAction actionWithTitle:kMenuNotifications style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [Preferences preferredStartingLocation:kMenuNotifications];
        [self.table reloadData];
    }];
    UIAlertAction *kMenuSearchPostsLoc = [UIAlertAction actionWithTitle:kMenuSearchPosts style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [Preferences preferredStartingLocation:kMenuSearchPosts];
        [self.table reloadData];
    }];
    UIAlertAction *deletePreferredLocation = [UIAlertAction actionWithTitle:@"Smazat preferovanou lokaci" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [Preferences preferredStartingLocation:@""];
        [self.table reloadData];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:kMenuOverviewLoc];
    [alert addAction:kMenuMailLoc];
    [alert addAction:kMenuBookmarksLoc];
    [alert addAction:kMenuHistoryLoc];
    [alert addAction:kMenuPeopleLoc];
    [alert addAction:kMenuNotificationsLoc];
    [alert addAction:kMenuSearchPostsLoc];
    [alert addAction:deletePreferredLocation];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:^{}];
}

- (void)chooseMaximumUnreadLoad
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Maximální počet nepřečtených příspěvků"
                                                                   message:@"Pokud počet nepřečtených příspěvků překročí tento limit, načítání se ukončí."
                                                            preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *limit200 = [UIAlertAction actionWithTitle:@"200" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [Preferences maximumUnreadPostsLoad:@"200"];
        [self.table reloadData];
    }];
    UIAlertAction *limit500 = [UIAlertAction actionWithTitle:@"500" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [Preferences maximumUnreadPostsLoad:@"500"];
        [self.table reloadData];
    }];
    UIAlertAction *limit1000 = [UIAlertAction actionWithTitle:@"1000" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [Preferences maximumUnreadPostsLoad:@"1000"];
        [self.table reloadData];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:limit200];
    [alert addAction:limit500];
    [alert addAction:limit1000];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:^{}];
}

- (void)deleteSettings
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset nastavení?"
                                                                   message:@"Opravdu chceš nastavit standardní hodnoty?\nTuto operaci nelze vzít zpět. Po resetu se aplikace ukončí a je potřeba ji znovu spustit."
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Reset!" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
        
        [Preferences setupPreferencesUsingForce:YES];
        [self applicationWillBeClosedWarning];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:delete];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:^{}];
}

#pragma mark - LOADING VIEW

- (void)placeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        LoadingView *lv = [[LoadingView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:lv];
    });
}

- (void)removeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self.view viewWithTag:kLoadingCoverViewTag] removeFromSuperview];
    });
}


#pragma mark - APP VERSION

- (NSString *)appVersion
{
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
//    NSString * appBuild = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    
    NSString * versionBuild = [NSString stringWithFormat: @"verze %@", version];
    
    // Add build to version.
//    if (![version isEqualToString: appBuild]) {
//        versionBuild = [NSString stringWithFormat: @"%@.%@", versionBuild, appBuild];
//    }
    
    return versionBuild;
}


@end


