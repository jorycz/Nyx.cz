//
//  ContentTableWithPeople.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 20/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timestamp.h"
#import "ContentTableWithPeopleCell.h"


@interface ContentTableWithPeople : UITableViewController <UIGestureRecognizerDelegate, ServerConnectorDelegate>
{
    UITableView *_table;
    CGFloat _rh;
    NSIndexPath *_indexPathToDelete;
}


- (id)initWithRowHeight:(CGFloat)rowHeight;
- (void)reloadTableData;


@property (nonatomic, weak) UINavigationController *nController;

@property (nonatomic, strong) NSMutableArray *nyxSections;
@property (nonatomic, strong) NSMutableArray *nyxRowsForSections;
@property (nonatomic, strong) NSMutableArray *nyxPostsRowHeights;
@property (nonatomic, strong) NSMutableArray *nyxPostsRowBodyTexts;

@property (nonatomic, assign) BOOL allowsSelection;
@property (nonatomic, assign) BOOL canEditFirstRow;

@property (nonatomic, strong) NSString *peopleTableMode;


@end
