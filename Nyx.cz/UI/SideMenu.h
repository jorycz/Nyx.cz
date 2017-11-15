//
//  SideMenu.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenu : UIView <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSArray *menuEntries;


@end
