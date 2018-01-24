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
    NSIndexPath *_indexPathToDelete, *_indexPathToRating;
    BOOL _tableEditShowDelete, _tableEditShowThumbs, _showingSearchResult, _noMoreSearchResult;
    
    NSIndexPath *_preserveIndexPathAfterLoadFromId;
    
    NSMutableString *_lastVisitWuId;
    NSMutableDictionary *_temporaryDataStorageBeforeLastReadIsFound;
    
    NSMutableString __block *_searchNick, __block *_searchText;
    
    NSInteger _globalSearchPage;
}


@property (nonatomic, weak) UINavigationController *nController;

@property (nonatomic, strong) NSMutableArray *nyxSections;
@property (nonatomic, strong) NSMutableArray *nyxRowsForSections;

@property (nonatomic, strong) NSMutableArray *nyxPostsRowHeights;
@property (nonatomic, strong) NSMutableArray *nyxPostsRowBodyTexts;

@property (nonatomic, assign) BOOL allowsSelection;
@property (nonatomic, assign) BOOL canEditFirstRow;

@property (nonatomic, strong) NSString *peopleTableMode;

@property (nonatomic, strong) NSDictionary *disscussionClubData;

@property (nonatomic, strong) NSString *noticesLastVisitTimestamp;

@property (nonatomic, assign) CGFloat widthForTableCellBodyTextView;

@property (nonatomic, assign) BOOL scrollToTopAfterReloadUntilUserScrolls;


// Load Discussion (people table) from Notices (into this people table)
@property (nonatomic, strong) ContentTableWithPeople *nestedPeopleTable;


- (id)initWithRowHeight:(CGFloat)rowHeight;
- (void)reloadTableDataWithScrollToTop:(BOOL)goToTop;


- (void)getDataForFeedOfFriends;
- (void)getDataForMailbox;
- (void)getDataForMailboxFromId:(NSString *)fromId;
- (void)getDataForFriendList;
- (void)getDataForNotices;
- (void)getDataForSearchNick:(NSString *)nick andText:(NSString *)text;

- (void)getDataForDiscussion:(NSString *)disId loadMoreToShowAllUnreadFromId:(NSString *)postId;

- (void)showSearchAlert:(id)sender;


@end
