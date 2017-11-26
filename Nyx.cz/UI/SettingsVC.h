//
//  SettingsVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsVCCell.h"


@interface SettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSArray *menuEntries;
@property (nonatomic, strong) NSArray *menuSubtitles;


@end
