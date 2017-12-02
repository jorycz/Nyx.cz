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

#import "StorageManager.h"


@interface SettingsVC ()

@end

@implementation SettingsVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.menuEntries = @[@"Spočítat velikost cache",
                             @"Počáteční lokace",
                             @"Smazat nastavení",
                             @"Zobrazovat obrázky",
                             @"Otevřít v Safari",
                             @"Obnova dat na pozadí",
                             @"Uložená zpráva"
                             ];
        self.menuSubtitles = @[@"Spočítá a případně umožní vymazat obsah mezipaměti.",
                               @"",
                               @"Smaže veškeré nastavení kromě autorizace.",
                               @"Zobrazovat v postech obrázky nebo URL.",
                               @"Otevře URL linky v Safari místo v aplikaci.",
                               @"",
                               @"Zobrazí uloženou zprávu, pokud existuje."
                               ];
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
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                   target:self
                                                                                   action:@selector(dismissSettings)];
    self.navigationItem.rightBarButtonItem = dismissButton;
    
    self.title = @"Nastavení";
    
    self.table = [[UITableView alloc] init];
    [self.table setDelegate:self];
    [self.table setDataSource:self];
    [self.table setBackgroundColor:[UIColor clearColor]];
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
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:22];
    }
    
    cell.tag = (int)indexPath.row;
    cell.textLabel.text = [self.menuEntries objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    [cell.settingsSwitch removeFromSuperview];
    cell.settingsSwitch = nil;
    
    NSString *subtitle = [self.menuSubtitles objectAtIndex:indexPath.row];
    [subtitle length] > 0 ? cell.detailTextLabel.text = subtitle : NULL ;
    
    if (indexPath.row == 1) {
        NSString *startingLocation = [Preferences preferredStartingLocation:nil];
        NSString *missingLocation = [NSString stringWithFormat:@"Neurčena. Poslední navštívená: %@", [Preferences lastUserPosition:nil]];
        (startingLocation && [startingLocation length] > 0) ? [cell.detailTextLabel setText:startingLocation] : [cell.detailTextLabel setText:missingLocation];
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
        NSString *lastBackgroundRefresh = [Preferences actualDateOfBackgroundRefresh:nil];
        (lastBackgroundRefresh && [lastBackgroundRefresh length] > 0) ? [cell.detailTextLabel setText:lastBackgroundRefresh] : [cell.detailTextLabel setText:@"Natím nenačtena žádná data na pozadí."];
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
            [self deleteSettings];
            break;
        case 5:
        {
            NSString *lastBackgroundRefresh = [Preferences actualDateOfBackgroundRefresh:nil];
            UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Poslední obnova dat na pozadí"
                                                                       message:lastBackgroundRefresh
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {}];
            [a addAction:ok];
            [self presentViewController:a animated:YES completion:^{}];
        }
            break;
        case 6:
        {
            NSString *storedMessage;
            if ([[[[Preferences messagesForDiscussion:nil] firstObject] objectForKey:@"text"] length] > 0) {
                storedMessage = [[[Preferences messagesForDiscussion:nil] firstObject] objectForKey:@"text"];
            } else {
                storedMessage = @"Žádná uložená zpráva neexistuje.";
            }
            
            UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Uložená zpráva"
                                                                       message:storedMessage
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {}];
            UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Smazat" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
                [Preferences messagesForDiscussion:(NSMutableArray *)@[]];
            }];
            [a addAction:delete];
            [a addAction:ok];
            [self presentViewController:a animated:YES completion:^{}];
        }
            break;
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Smazané věci nelze obnovit!";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.9];
}


#pragma mark - SWITCH

- (UISwitch *)placeSwitchWithTag:(NSInteger)tag
{
    UISwitch *s = [[UISwitch alloc] init];
    [s addTarget:self action:@selector(switchChanged:) forControlEvents:(UIControlEventValueChanged)];
    s.tag = tag;
    
    // INITIAL STATE
    if (tag == 3)
        [[Preferences showImagesInlineInPost:nil] length] > 0 ? [s setOn:YES] : [s setOn:NO] ;
    if (tag == 4)
        [[Preferences openUrlsInSafari:nil] length] > 0 ? [s setOn:YES] : [s setOn:NO] ;
    
    return s;
}

- (void)switchChanged:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    
    if (s.tag == 3)
        s.isOn ? [Preferences showImagesInlineInPost:@"yes"] : [Preferences showImagesInlineInPost:@""] ;
    if (s.tag == 4)
        s.isOn ? [Preferences openUrlsInSafari:@"yes"] : [Preferences openUrlsInSafari:@""] ;
}


#pragma mark - ACTIONS

- (void)countCache
{
    StorageManager *sm = [[StorageManager alloc] init];
    NSDictionary *d = [sm countCache];
    NSUInteger files = [[d objectForKey:@"files"] integerValue];
    NSUInteger size = [[d objectForKey:@"size"] integerValue];
    NSString *m = [NSString stringWithFormat:@"Využito %li MB (Počet souborů %li).", (long)size, (long)files];
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
    [self presentViewController:alert animated:YES completion:^{}];
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
    UIAlertAction *kMenuPeopleLoc = [UIAlertAction actionWithTitle:kMenuPeople style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [Preferences preferredStartingLocation:kMenuPeople];
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
    [self presentViewController:alert animated:YES completion:^{
    }];
}

- (void)deleteSettings
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Smazat veškeré nastavení?"
                                                                   message:@"Opravdu chceš smazat veškeré nastavení?\nTuto operaci nelze vzít zpět!"
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Smazat!" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:delete];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:^{}];
}


@end


