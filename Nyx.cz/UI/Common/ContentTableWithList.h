//
//  ContentTableWithList.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 25/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerConnector.h"
#import "ContentTableWithListCell.h"


@interface ContentTableWithList : UITableViewController <ServerConnectorDelegate>
{
    UITableView *_table;
    CGFloat _rh;
}


@property (nonatomic, weak) UINavigationController *nController;

@property (nonatomic, strong) NSMutableArray *nyxSections;
@property (nonatomic, strong) NSMutableArray *nyxRowsForSections;


- (id)initWithRowHeight:(CGFloat)rowHeight;
- (void)reloadTableData;


@end
