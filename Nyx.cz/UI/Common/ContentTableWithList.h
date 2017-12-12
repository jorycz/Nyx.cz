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

#import "ContentTableWithPeople.h"


@interface ContentTableWithList : UITableViewController <ServerConnectorDelegate>
{
    UITableView *_table;
    CGFloat _rh;
    
    // For next controller - discussion table
    CGFloat _widthForTableCellBodyTextView;
    
    NSMutableString *_currentDiscussionId;
    
    NSString *_serverIdentificationDiscussion, *_serverIdentificationDiscussionFromId, *_serverIdentificationDiscussionRefreshAfterNewPost;
}


@property (nonatomic, weak) UINavigationController *nController;

@property (nonatomic, strong) NSMutableArray *nyxSections;
@property (nonatomic, strong) NSMutableArray *nyxRowsForSections;

@property (nonatomic, strong) ContentTableWithPeople *discussionTable;


- (id)initWithRowHeight:(CGFloat)rowHeight;
- (void)reloadTableData;


@end
