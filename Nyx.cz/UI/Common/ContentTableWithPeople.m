//
//  ContentTableWithPeople.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 20/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ContentTableWithPeople.h"
#import "PeopleRespondVC.h"
#import "ApiBuilder.h"
#import "LoadingView.h"
#import "Colors.h"
#import "RichTextProcessor.h"
#import "NewFeedPostVC.h"
#import "PeopleAutocompleteVC.h"
// Post content
#import "WebVC.h"
#import "ImagePreviewVC.h"
// Pasteboard
#import <MobileCoreServices/MobileCoreServices.h>
// SHARING
//#import "ComputeRowHeight.h"
#import "ShareItemProviderText.h"
#import "ShareItemProviderImage.h"

#import "TableConfigurator.h"


@interface ContentTableWithPeople ()

@end

@implementation ContentTableWithPeople

- (id)initWithRowHeight:(CGFloat)rowHeight
{
    self = [super init];
    if (self)
    {
        _rh = rowHeight;
        self.nyxSections = [[NSMutableArray alloc] init];
        self.nyxRowsForSections = [[NSMutableArray alloc] init];
        self.nyxPostsRowHeights = [[NSMutableArray alloc] init];
        self.nyxPostsRowBodyTexts = [[NSMutableArray alloc] init];
        self.canEditFirstRow = YES;
        _lastVisitWuId = [[NSMutableString alloc] init];
        _temporaryDataStorageBeforeLastReadIsFound = [[NSMutableDictionary alloc] init];
        _showingSearchResult = NO;
        _searchNick = [[NSMutableString alloc] init];
        _searchText = [[NSMutableString alloc] init];
        _globalSearchPage = 0;
        // Regular Table set this to NO. In case comming from Notices with Big display, set it to YES.
        self.scrollToTopAfterReloadUntilUserScrolls = NO;
        _ownTitle = [[NSMutableString alloc] init];
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
    
    // Refresh after new FEED POST.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataForFeedOfFriends) name:kNotificationFriendsFeedChanged object:nil];
    // When MAIL RECIPIENT is choosen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(composeNewMessageFor:) name:kNotificationMailboxNewMessageFor object:nil];
    // Refresh after new mail message is sent.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataForMailbox) name:kNotificationMailboxChanged object:nil];
    // Refresh and load newer posts after new POST is send to discussion.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataForDiscussionBeforeIdNotificationFromRespondVC:) name:kNotificationDiscussionLoadNewerFrom object:nil];
    // Tap on Avatar in Discussion Table
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avatarTapped:) name:kNotificationAvatarTapped object:nil];
    
    _table = [[UITableView alloc] init];
    [self.view addSubview:_table];

    [_table setBackgroundColor:[UIColor themeColorMainBackgroundDefault]];
    [_table setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
    [_table setDataSource:self];
    [_table setDelegate:self];
    [_table setRowHeight:_rh];
    _table.allowsSelection = self.allowsSelection;
        
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed]) {
        UIBarButtonItem *composeNewPost = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                        target:self
                                                                                        action:@selector(composeNewPost:)];
        self.nController.topViewController.navigationItem.rightBarButtonItems = @[composeNewPost];
    }
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox]) {
        UIBarButtonItem *composeMessage = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                        target:self
                                                                                        action:@selector(chooseNickname:)];
        UIBarButtonItem *searchMessage = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                       target:self
                                                                                       action:@selector(showSearchAlert:)];
        self.nController.topViewController.navigationItem.rightBarButtonItems = @[searchMessage, composeMessage];
    }
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion]) {
        UIBarButtonItem *searchMessage = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                       target:self
                                                                                       action:@selector(showSearchAlert:)];
        UIBarButtonItem *newPost = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                 target:self
                                                                                 action:@selector(createNewPostToDiscussion)];
        self.nController.topViewController.navigationItem.rightBarButtonItems = @[searchMessage, newPost];
    }
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeSearch]) {
        UIBarButtonItem *searchMessage = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                       target:self
                                                                                       action:@selector(showSearchAlert:)];
        self.nController.topViewController.navigationItem.rightBarButtonItems = @[searchMessage];
    }
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeRatingInfo]) {
        UIBarButtonItem *dismiss = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                        target:self
                                                                                        action:@selector(dismiss:)];
        self.navigationItem.rightBarButtonItems = @[dismiss];
    }
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeFeed] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeFriends] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeNotices])
    {
        UIRefreshControl *refreshControll = [[UIRefreshControl alloc] init];
        [refreshControll addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
        [self setRefreshControl:refreshControll];
        [_table insertSubview:refreshControll atIndex:0];
        refreshControll.layer.zPosition = -1;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (!self.peopleTableMode)
    {
        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @" !!! PEOPLE TABLE MODE NOT SET (set something like kPeopleTableModeFeed ... etc) !!!");
        return;
    }
    [_table setFrame:self.view.bounds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // TODO TOFIX Need to delete title later for smooth animation when pushing (respond) view. Restore it here when back.
    if ([_ownTitle length] > 0)
        self.title = _ownTitle;
    if (self.title)
        [_ownTitle setString:self.title];
}

#pragma mark - NAVIGATION BAR BUTTONS ENABLE

- (void)enableNavigationButtons:(BOOL)b
{
    for (UIBarButtonItem *item in self.nController.topViewController.navigationItem.rightBarButtonItems) {
        [item setEnabled:b];
    }
}

#pragma mark - Table view data source

- (void)reloadTableDataWithScrollToTop:(BOOL)goToTop
{
    [_table reloadData];
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
        [self removeLoadingView];
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeRatingInfo])
        return;
    // Neposouvat kdyz scrollujeme dolu a nacitaji se dalsi posty.
    if (goToTop)
    {
        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
    } else {
        [_table scrollToRowAtIndexPath:_preserveIndexPathAfterLoadFromId atScrollPosition:(UITableViewScrollPositionBottom) animated:NO];
    }
}

- (void)reloadTableDataWithScrollToRow:(NSInteger)row
{
    [_table reloadData];
    [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.nyxSections)
        return [self.nyxSections count];
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.nyxRowsForSections && [self.nyxRowsForSections count] > 0)
        return [[self.nyxRowsForSections objectAtIndex:section] count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdForReuse = @"uniqCell";
    ContentTableWithPeopleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdForReuse];
    
    if (cell == nil)
    {
        cell = [[ContentTableWithPeopleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdForReuse];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnCell:)];
        longPress.minimumPressDuration = kLongPressMinimumDuration;
        [cell addGestureRecognizer:longPress];
    }
    
    NSDictionary *cellData = [[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), cellData);
    
    // Remove all custom params.
    cell.activeFriendStatus = nil;
    cell.commentsCount = nil;
    cell.mailboxDirection = nil;
    cell.mailboxMailStatus = nil;
    [cell.rating setString:@""];
    
    NSString *rating = [cellData objectForKey:@"wu_rating"];
    if (rating && [rating length] > 0) {
        [cell.rating setString:rating];
    }
    
    if (cellData)
    {
        cell.peopleCellMode = self.peopleTableMode;
        
        NSString *nick;
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeFriends] || [self.peopleTableMode isEqualToString:kPeopleTableModeFriendsDetail])
        {
            nick = [cellData objectForKey:@"nick"];
            [cellData objectForKey:@"active"] ? cell.activeFriendStatus = @"yes" : NULL ;
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed] || [self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail])
        {
            nick = [cellData objectForKey:@"nick"];
            cell.commentsCount = [cellData objectForKey:@"comments_count"];
            cell.bodyTextSource = [cellData objectForKey:@"text"];
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox] || [self.peopleTableMode isEqualToString:kPeopleTableModeMailboxDetail])
        {
            nick = [cellData objectForKey:@"other_nick"];
            cell.mailboxDirection = [cellData objectForKey:@"direction"];
            cell.mailboxMailStatus = [cellData objectForKey:@"message_status"];
            cell.discussionNewPost = [cellData objectForKey:@"new"];
            cell.bodyTextSource = [cellData objectForKey:@"content"];
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion] || [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail])
        {
            nick = [cellData objectForKey:@"nick"];
            cell.discussionNewPost = [cellData objectForKey:@"new"];
            cell.bodyTextSource = [cellData objectForKey:@"content"];
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeNotices] || [self.peopleTableMode isEqualToString:kPeopleTableModeNoticesDetail])
        {
            nick = [cellData objectForKey:@"nick"];
            cell.bodyTextSource = [cellData objectForKey:@"content"];
            cell.noticesLastVisit = self.noticesLastVisitTimestamp;
            cell.notice = cellData;
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeSearch])
        {
            nick = [cellData objectForKey:@"nick"];
            cell.bodyTextSource = [cellData objectForKey:@"content"];
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeRatingInfo])
        {
            nick = [cellData objectForKey:@"nick"];
        }
        
        cell.nick = nick;
        
        Timestamp *ts = [[Timestamp alloc] initWithTimestamp:[cellData objectForKey:@"time"]];
        cell.time = [ts getTimeWithDate];
        
        // Must exist!
        cell.bodyText = [[self.nyxPostsRowBodyTexts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        [cell configureCellForIndexPath:indexPath];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFriends] || [self.peopleTableMode isEqualToString:kPeopleTableModeFriendsDetail])
    {
        return 70;
    }
    else
    {
        CGFloat f = [[[self.nyxPostsRowHeights objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] floatValue];
        return f + 30; // + 30 = Nick name at the top of the Cell.
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[self.nyxSections firstObject] isEqualToString:kDisableTableSections])
        return nil;
    return [self.nyxSections objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeRatingInfo]) {
        if (section == 0) {
            view.tintColor = [UIColor themeColorRatingPositive];
        } else {
            view.tintColor = [UIColor themeColorRatingNegative];
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // DENY SELECT FIRST ROW IN DETAIL VIEW - load same content doesn't make sense
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail] && indexPath.section == 0 && indexPath.row == 0)
        return;
    // DENY SELECT ON RATING INFO TABLE
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeRatingInfo])
        return;
    
    NSDictionary *userPostData = [[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), userPostData);
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), self.disscussionClubData);
    
    // -------- SETTINGS FOR RESPOND VIEW --------
    NSString *nick;
    NSString *postId;
    CGFloat f = 2.0f;
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed]) {
        nick = [userPostData objectForKey:@"nick"];
        postId = [userPostData objectForKey:@"id_update"];
        f = [[[self.nyxPostsRowHeights objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] floatValue];
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox]) {
        nick = [userPostData objectForKey:@"other_nick"];
        postId = [userPostData objectForKey:@"id_mail"];
        f = [[[self.nyxPostsRowHeights objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] floatValue];
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFriends]) {
        nick = [userPostData objectForKey:@"nick"];
        postId = @"666";
        f = 70;
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion] || [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail]) {
        nick = [userPostData objectForKey:@"nick"];
        postId = [userPostData objectForKey:@"id_wu"];
        f = [[[self.nyxPostsRowHeights objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] floatValue];
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeNotices]) {
        nick = [userPostData objectForKey:@"nick"];
        postId = [userPostData objectForKey:@"id_wu"];
        f = [[[self.nyxPostsRowHeights objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] floatValue];
    }
    
    NSString *firstPostId = [[[self.nyxRowsForSections objectAtIndex:0] objectAtIndex:0] objectForKey:@"id_wu"];
    NSAttributedString *str = [[self.nyxPostsRowBodyTexts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    // -------- RESPOND VIEW --------
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeMailbox] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeFriends] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeNotices])
    {
        NSMutableArray *previousResponses = [[NSMutableArray alloc] init];
        
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion] ||
            [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail])
        {
            // Previous reactions ID (wu) to this POST in **** DISCUSSION. ****
            ContentTableWithPeopleCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            RichTextProcessor *rtp = [[RichTextProcessor alloc] init];
            NSArray *recipientLinks = [rtp getRelativeOnlyUrls:[rtp getAllURLsFromAttributedAndSourceText:cell.bodyText withHtmlSource:nil]];
            NSArray *wuOnlyRecipients = [recipientLinks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains %@", @"wu="]];
            if ([wuOnlyRecipients count] > 0) {
                for (NSInteger index = 0; index < [wuOnlyRecipients count] ; index++)
                {
                    NSString *reactionId = [[[wuOnlyRecipients objectAtIndex:index] componentsSeparatedByString:@"="] lastObject];
                    [previousResponses addObject:@{@"name": @"getRecipientNamesFromSourceHtml:", @"reactionId": reactionId}];
                }
            }
        }
        
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeNotices])
        {
            // Previous reactions ID (wu) to this POST in **** NOTICES. ****
            NSArray *replies = [userPostData objectForKey:@"replies"];
            if (replies && [replies count] > 0) {
                for (NSDictionary *r in replies) {
                    NSString *wu = [r objectForKey:@"id_wu"];
                    NSString *name = [r objectForKey:@"nick"];
                    if (wu && [wu length] > 0 && name && [name length] > 0) {
                        [previousResponses addObject:@{@"name": name, @"reactionId": wu}];
                    }
                }
            }
            if (!previousResponses || [previousResponses count] < 1) {
                // Show discussion for post without comments.
                NSString *discussionId = [userPostData objectForKey:@"id_klub"];
                NSString *id_wu = [userPostData objectForKey:@"id_wu"];
                // Load even currently clicked POST from NOTICES so fake starting ID here.
                NSInteger biggerId = [id_wu integerValue] + 1;
                [self createAnotherDiscussionTableForDiscussionId:discussionId andLoadFromPostId:[@(biggerId) stringValue]];
                return;
            }
        }
        
        [self showRespondViewWithNick:nick
                             bodyText:str
                           bodyHeight:f
                               postId:postId
                         userPostData:userPostData
               refreshFromFirstPostId:firstPostId
                previousReactionPosts:(NSArray *)previousResponses
         ];
    }
    // --------------- RESPOND VIEW ------------------
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeSearch]) {
        // Show discussion for post without comments.
        NSString *discussionId = [userPostData objectForKey:@"id_klub"];
        NSString *id_wu = [userPostData objectForKey:@"id_wu"];
        // Load even currently clicked POST from NOTICES so fake starting ID here.
        NSInteger biggerId = [id_wu integerValue] + 1;
        [self createAnotherDiscussionTableForDiscussionId:discussionId andLoadFromPostId:[@(biggerId) stringValue]];
    }
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeNoticesDetail])
    {
        NSString *discussionId = [[[self.nyxRowsForSections objectAtIndex:0] objectAtIndex:0] objectForKey:@"id_klub"];
        NSString *id_wu = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_wu"];
        // Load even currently clicked POST from NOTICES so fake starting ID here.
        NSInteger biggerId = [id_wu integerValue] + 1;
        [self createAnotherDiscussionTableForDiscussionId:discussionId andLoadFromPostId:[@(biggerId) stringValue]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeMailbox] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
    {
        return YES;
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail] && indexPath.row != 0)
    {
        return YES;
    }
    return NO;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _tableEditShowDelete = NO;
    _tableEditShowThumbs = NO;
    
    // SHOW VOTING THUMPS in Discussion Table Mode.
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
        _tableEditShowThumbs = YES;
    
    // SHOW DELETE BUTTON WHEN IT'S OWN POST
    NSString *nickForPost = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"nick"];
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion] &&
        [[[Preferences auth_nick:nil] uppercaseString] isEqualToString:nickForPost])
        _tableEditShowDelete = YES;
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed] &&
        [[[Preferences auth_nick:nil] uppercaseString] isEqualToString:nickForPost])
        _tableEditShowDelete = YES;
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail] &&
        [[[Preferences auth_nick:nil] uppercaseString] isEqualToString:nickForPost])
        _tableEditShowDelete = YES;
    
    // SHOW DELETE BUTTON IN MAIL
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox])
        _tableEditShowDelete = YES;
    
    UIContextualAction *thumbup = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                          title:@"Ohodnotit"
                                                                        handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
    {
        // GIVE RATING IN DISCUSSION
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
        {
            _indexPathToRating = indexPath;
            NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
            NSString *postId = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_wu"];
            [self giveRatingInDiscusstion:discussionId toPost:postId givePositiveRating:YES];
        }
        completionHandler(YES);
    }];
    thumbup.image = [UIImage imageNamed:@"thumbup"];
    thumbup.backgroundColor = [UIColor themeColorBackgroundCellThumbUp];
    
    UIContextualAction *thumbdown = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                            title:@"Ohodnotit"
                                                                          handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
    {
        // GIVE RATING IN DISCUSSION
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
        {
            _indexPathToRating = indexPath;
            NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
            NSString *postId = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_wu"];
            [self giveRatingInDiscusstion:discussionId toPost:postId givePositiveRating:NO];
        }
        completionHandler(YES);
    }];
    thumbdown.image = [UIImage imageNamed:@"thumbdown"];
    thumbdown.backgroundColor = [UIColor themeColorBackgroundCellThumbDown];
    
    UIContextualAction *delete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                         title:@"Smazat"
                                                                       handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
    {
        // Delete COMMENT for FEED RESPONSE, WHOLE FEED POST, MAILBOX or POST IN DISCUSSION.
        
        _indexPathToDelete = indexPath;
        
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail]) {
            // Get COMMENT ID under this POST.
            NSString *postId = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_comment"];
            // User MAIN POST data with MAIN POST id are stored always as first CELL - so get POST MAIN ID here.
            NSString *id_update = [[[self.nyxRowsForSections objectAtIndex:0] objectAtIndex:0] objectForKey:@"id_update"];
            // Deleting by key id_comment
            [self deleteCommentOnFriendFeedFor:[Preferences auth_nick:nil] withId:id_update commentId:postId];
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed]) {
            // Deleting MAIN POST by key id_update
            NSString *postId = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_update"];
            [self deleteFriendFeedPostFor:[Preferences auth_nick:nil] withId:postId];
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox]) {
            NSString *postId = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_mail"];
            [self deleteMailMessageWithId:postId];
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion]) {
            NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
            NSString *postId = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_wu"];
            [self deleteDiscussionPostFrom:discussionId withId:postId];
        }
        completionHandler(YES);
    }];
    delete.image = [UIImage imageNamed:@"delete"];
    
    // SETUP BUTTONS
    NSArray *buttons;
    _tableEditShowThumbs && _tableEditShowDelete ? buttons = @[thumbdown, thumbup, delete] : NULL ;
    _tableEditShowThumbs ? buttons = @[thumbdown, thumbup] : NULL ;
    _tableEditShowDelete ? buttons = @[delete] : NULL ;
    
    UISwipeActionsConfiguration *swipeActionConfig = [UISwipeActionsConfiguration configurationWithActions:buttons];
    swipeActionConfig.performsFirstActionWithFullSwipe = NO;
    
    return swipeActionConfig;
}

// NOT USED SINCE trailingSwipeActionsConfigurationForRowAtIndexPath is IN USE.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}

#pragma mark - NEW POST TO DISCUSSION

- (void)createNewPostToDiscussion
{
    NSString *firstPostId;
    if ([self.nyxRowsForSections count] > 0)
    {
        firstPostId = [[[self.nyxRowsForSections objectAtIndex:0] objectAtIndex:0] objectForKey:@"id_wu"];
    } else {
        firstPostId = @"0";
    }
    NSString *clubDescription = [NSString stringWithFormat:@"%@\n%@",
                                 [self.disscussionClubData objectForKey:@"name_main"],
                                 [self.disscussionClubData objectForKey:@"name_sub"]];
    NSAttributedString *club = [[NSAttributedString alloc] initWithString:clubDescription attributes:@{NSForegroundColorAttributeName : [UIColor themeColorStandardText]}];
    
    [self showRespondViewWithNick:@""
                         bodyText:club
                       bodyHeight:45
                           postId:firstPostId
                     userPostData:@{@"content": clubDescription}
           refreshFromFirstPostId:(NSString *)firstPostId
            previousReactionPosts:nil
     ];
}

#pragma mark - REPLY VIEW

- (void)showRespondViewWithNick:(NSString *)nick
                       bodyText:(NSAttributedString *)bodyText
                     bodyHeight:(CGFloat)f
                         postId:(NSString *)postId
                   userPostData:(NSDictionary *)userPostData
         refreshFromFirstPostId:(NSString *)firstPostId
          previousReactionPosts:(NSArray *)previousReactionPostIds
{
    PeopleRespondVC *respondVC = [[PeopleRespondVC alloc] init];
    respondVC.nick = nick;
    respondVC.bodyText = bodyText;
    respondVC.bodyHeight = f;
    respondVC.postId = postId;
    // --- Needed for discussion club or notices table mode -------
    respondVC.firstDiscussionPostId = firstPostId;
    respondVC.previousReactions = previousReactionPostIds;
    if (self.noticesLastVisitTimestamp && [self.noticesLastVisitTimestamp length] > 0)
        respondVC.table.noticesLastVisitTimestamp = self.noticesLastVisitTimestamp;
    if (self.disscussionClubData && [[self.disscussionClubData allKeys] count] > 0)
    {
        // DISCUSSION
        respondVC.disscussionClubData = self.disscussionClubData;
    } else {
        // FEED
        respondVC.disscussionClubData = userPostData;
    }
    // -------------------------------------------
    respondVC.postData = userPostData;
    respondVC.nController = self.nController;
    respondVC.peopleRespondMode = self.peopleTableMode;
    self.title = @"";
    [self.nController pushViewController:respondVC animated:YES];
}

#pragma mark - AFTER USER SCROLS - ENABLE keep scroll at current position of last cell when loading LAST CELL

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.scrollToTopAfterReloadUntilUserScrolls = NO;
}

#pragma mark - SCROLL REACH END (mailbox, discussion) - LOAD MORE CELL INTO TABLE

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showingSearchResult && _noMoreSearchResult) {
        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"No more search result.");
        return;
    }
    
    // Are we on the LAST CELL ?
    if (indexPath.row + 1 == [[self.nyxRowsForSections objectAtIndex:0] count])
    {
        // Is this LAST CELL for REGULAR TABLE or SEARCH ?
        if (!_showingSearchResult) // Regular Table.
        {
            if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox])
            {
                _preserveIndexPathAfterLoadFromId = indexPath;
                NSString *fromID = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_mail"];
                [self getDataForMailboxFromId:fromID];
            }
            
            if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
            {
                _preserveIndexPathAfterLoadFromId = indexPath;
                NSString *fromID = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_wu"];
                NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
                [self getDataForDiscussion:discussionId fromId:fromID];
            }
        }
        else // Search Table.
        {
            if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox])
            {
                _preserveIndexPathAfterLoadFromId = indexPath;
                NSString *fromID = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_mail"];
                [self getDataForSearchMailboxNick:_searchNick andText:_searchText fromId:fromID];
            }
            
            if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
            {
                _preserveIndexPathAfterLoadFromId = indexPath;
                NSString *fromID = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_wu"];
                [self getDataForSearchDiscussionNick:_searchNick andText:_searchText fromWuId:fromID];
            }
            
            // Only in Search Table.
            if ([self.peopleTableMode isEqualToString:kPeopleTableModeSearch])
            {
                _preserveIndexPathAfterLoadFromId = indexPath;
                _globalSearchPage += 20;
                [self getDataForSearchNick:_searchNick andText:_searchText page:_globalSearchPage];
            }
        }
    }
}

#pragma mark - SHOW ANOTHER DISCUSSION PEOPLE TABLE - from notices section

- (void)createAnotherDiscussionTableForDiscussionId:(NSString *)dId andLoadFromPostId:(NSString *)postId
{
    // DISCUSSION TABLE INIT !
    self.nestedPeopleTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
    self.nestedPeopleTable.nController = self.nController;
    self.nestedPeopleTable.allowsSelection = YES;
    self.nestedPeopleTable.canEditFirstRow = YES;
    self.nestedPeopleTable.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
    self.nestedPeopleTable.peopleTableMode = kPeopleTableModeDiscussion;
    self.nestedPeopleTable.scrollToTopAfterReloadUntilUserScrolls = YES;
    [self.nController pushViewController:self.nestedPeopleTable animated:YES];
    [self.nestedPeopleTable getDataForDiscussion:dId fromId:postId];
}

#pragma mark - DELETING

- (void)deleteCommentOnFriendFeedFor:(NSString *)nick withId:(NSString *)postId commentId:(NSString *)commentId
{
    NSString *api = [ApiBuilder apiFeedOfFriendsDeleteCommentAs:nick withId:postId commentId:commentId];
    [self serverApiCall:api andIdentification:kApiIdentificationPostDelete];
}

- (void)deleteFriendFeedPostFor:(NSString *)nick withId:(NSString *)postId
{
    NSString *api = [ApiBuilder apiFeedOfFriendsDeletePostAs:nick withId:postId];
    [self serverApiCall:api andIdentification:kApiIdentificationPostDelete];
}

- (void)deleteMailMessageWithId:(NSString *)messageId
{
    NSString *api = [ApiBuilder apiMailboxDeleteMessage:messageId];
    [self serverApiCall:api andIdentification:kApiIdentificationPostDelete];
}

- (void)deleteDiscussionPostFrom:(NSString *)discussionId withId:(NSString *)postId
{
    NSString *api = [ApiBuilder apiDiscussionDeleteMessage:discussionId postId:postId];
    [self serverApiCall:api andIdentification:kApiIdentificationPostDelete];
}

#pragma mark - THUMBS

- (void)giveRatingInDiscusstion:(NSString *)dId toPost:(NSString *)postId givePositiveRating:(BOOL)positiveRating
{
    NSString *api = [ApiBuilder apiDiscussionGiveRatingInDiscussion:dId toPost:postId positiveRating:positiveRating];
    if (!positiveRating) {
        UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Negativní hodnocení?"
                                                                   message:@"Opravdu udělit/zrušit negativní hodnocení?"
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Udělit" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
            [self serverApiCall:api andIdentification:kApiIdentificationPostThumbs];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {}];
        [a addAction:delete];
        [a addAction:cancel];
        [self presentViewController:a animated:YES completion:^{}];
    } else {
        [self serverApiCall:api andIdentification:kApiIdentificationPostThumbs];
    }
}

- (void)getCurrentRating:(NSString *)dId forPost:(NSString *)postId
{
    NSString *api = [ApiBuilder apiDiscussionGetRatingInDiscussion:dId forPost:postId];
    [self serverApiCall:api andIdentification:kApiIdentificationPostRefreshThumbs];
}

- (void)getCurrentRatingForPresentation:(NSString *)dId forPost:(NSString *)postId
{
    NSString *api = [ApiBuilder apiDiscussionGetRatingInDiscussion:dId forPost:postId];
    [self serverApiCall:api andIdentification:kApiIdentificationPostGetRatingInfo];
}


#pragma mark - PULL TO REFRESH

- (void)pullToRefresh:(id)sender
{
    _showingSearchResult = NO;
    _noMoreSearchResult = NO;
    [_table setScrollEnabled:NO];
    [_table setScrollEnabled:YES];
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox])
    {
        [self getDataForMailbox];
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
    {
        NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
        [self getDataForDiscussion:discussionId loadMoreToShowAllUnreadFromId:@""];
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed])
    {
        [self getDataForFeedOfFriends];
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFriends])
    {
        [self getDataForFriendList];
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeNotices])
    {
        [self getDataForNotices];
    }
    [(UIRefreshControl *)sender endRefreshing];
}

#pragma mark - DATA / API CALL

- (void)serverApiCall:(NSString *)api andIdentification:(NSString *)identification
{
    [self placeLoadingView];
    
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.identifitaion = identification;
    sc.delegate = self;
    [sc downloadDataForApiRequest:api];
}

- (void)getDataForFeedOfFriends
{
    NSString *apiRequest = [ApiBuilder apiFeedOfFriends];
    [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForFeedOfFriends];
}

- (void)getDataForMailbox
{
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox]) {
        NSString *apiRequest = [ApiBuilder apiMailbox];
        [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForMailbox];
    }
}

- (void)getDataForMailboxFromId:(NSString *)fromId
{
    NSString *apiRequest = [ApiBuilder apiMailboxLoadOlderMessagesFromId:fromId];
    [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForMailboxOlderMessages];
}

- (void)getDataForFriendList
{
    NSString *apiRequest = [ApiBuilder apiPeopleFriends];
    [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForFriendList];
}

- (void)getDataForNotices
{
    NSString *apiRequest = [ApiBuilder apiFeedNoticesAndKeepNew:NO];
    [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForNotices];
}

- (void)getDataForSearchNick:(NSString *)nick andText:(NSString *)text
{
    NSString *apiRequest = [ApiBuilder apiSearchFor:nick andText:text];
    [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForSearch];
}

- (void)getDataForSearchNick:(NSString *)nick andText:(NSString *)text page:(NSInteger)page
{
    NSString *apiRequest = [ApiBuilder apiSearchFor:nick andText:text page:page];
    [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForSearchOlder];
}

- (void)getDataForSearchMailboxNick:(NSString *)nick andText:(NSString *)text
{
    NSString *apiRequest = [ApiBuilder apiSearchMailboxFor:nick andText:text];
    [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForSearchMailbox];
}

- (void)getDataForSearchMailboxNick:(NSString *)nick andText:(NSString *)text fromId:(NSString *)fromId
{
    NSString *apiRequest = [ApiBuilder apiSearchMailboxFor:nick andText:text fromId:fromId];
    [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForSearchMailboxOlder];
}

- (void)getDataForSearchDiscussionNick:(NSString *)nick andText:(NSString *)text
{
    NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
    NSString *apiRequest = [ApiBuilder apiSearchDiscussionFor:nick andText:text discussionId:discussionId];
    [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForSearchDiscussion];
}

- (void)getDataForSearchDiscussionNick:(NSString *)nick andText:(NSString *)text fromWuId:(NSString *)fromWuId
{
    NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
    NSString *apiRequest = [ApiBuilder apiSearchDiscussionFor:nick andText:text discussionId:discussionId fromWuId:fromWuId];
    [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForSearchDiscussionOlder];
}

// Direct enter to discussion from TABLE LIST
// This method is called with empty postId when entering from list table.
// If there are ALL unread posts in returned data, it's called repeatedly with postId filled by last post id
// until unread limit for post is reached or last unread post is found.
- (void)getDataForDiscussion:(NSString *)disId loadMoreToShowAllUnreadFromId:(NSString *)postId
{
    if (postId && [postId length] > 0)
    {
        NSString *apiRequest = [ApiBuilder apiMessagesForDiscussion:disId loadMoreFromId:postId];
        [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForDiscussion];
    } else {
        [_temporaryDataStorageBeforeLastReadIsFound removeAllObjects];
        NSString *apiRequest = [ApiBuilder apiMessagesForDiscussion:disId];
        [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForDiscussion];
    }
}

// Called when table scrolled down or from search / notices.
- (void)getDataForDiscussion:(NSString *)dId fromId:(NSString *)fromId
{
    NSString *apiRequest = [ApiBuilder apiMessagesForDiscussion:dId loadMoreFromId:fromId];
    [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForDiscussionFromID];
}

- (void)getDataForDiscussionBeforeIdNotificationFromRespondVC:(NSNotification *)sender
{
    // Do not refresh all PEOPLE type tables (few tables notices -> notices detail -> discussion ...)
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
    {
        NSString *beforeId = [[sender userInfo] objectForKey:@"nKey"];
        NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
        NSString *apiRequest = [ApiBuilder apiMessagesForDiscussion:discussionId loadPreviousFromId:beforeId];
        [self serverApiCall:apiRequest andIdentification:kApiIdentificationDataForDiscussionRefreshAfterPost];
    }
}

#pragma mark - SERVER / API DELEGATE RESULT

- (void)downloadFinishedWithData:(NSData *)data withIdentification:(NSString *)identification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
    if (!data)
    {
        [self presentErrorWithTitle:@"Žádná data" andMessage:@"Nelze se připojit na server."];
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
            if ([[jp.jsonDictionary objectForKey:@"result"] isEqualToString:@"error"])
            {
                NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), jp.jsonDictionary);
                [self presentErrorWithTitle:@"Chyba ze serveru:" andMessage:[jp.jsonDictionary objectForKey:@"error"]];
            }
            else
            {
//                NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), jp.jsonDictionary);
                
                // TABLE DATA
                if ([identification isEqualToString:kApiIdentificationDataForFeedOfFriends])
                {
                    TableConfigurator *tc = [[TableConfigurator alloc] init];
                    tc.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
                    [tc configurePeopleTableFriendsFeed:self withData:jp.jsonDictionary];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self reloadTableDataWithScrollToTop:YES];
                    });
                }
                if ([identification isEqualToString:kApiIdentificationDataForMailbox])
                {
                    TableConfigurator *tc = [[TableConfigurator alloc] init];
                    tc.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
                    [tc configurePeopleTableMailbox:self withData:jp.jsonDictionary addingData:NO];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self enableNavigationButtons:YES];
                        [self reloadTableDataWithScrollToTop:YES];
                    });
                }
                if ([identification isEqualToString:kApiIdentificationDataForMailboxOlderMessages])
                {
                    TableConfigurator *tc = [[TableConfigurator alloc] init];
                    tc.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
                    [tc configurePeopleTableMailbox:self withData:jp.jsonDictionary addingData:YES];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self enableNavigationButtons:YES];
                        [self reloadTableDataWithScrollToTop:NO];
                    });
                }
                if ([identification isEqualToString:kApiIdentificationDataForFriendList])
                {
                    TableConfigurator *tc = [[TableConfigurator alloc] init];
                    tc.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
                    [tc configurePeopleTablePeople:self withData:jp.jsonDictionary];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self reloadTableDataWithScrollToTop:YES];
                    });
                }
                if ([identification isEqualToString:kApiIdentificationDataForNotices])
                {
                    TableConfigurator *tc = [[TableConfigurator alloc] init];
                    tc.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
                    [tc configurePeopleTableNotices:self withData:jp.jsonDictionary];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self reloadTableDataWithScrollToTop:YES];
                    });
                }
                if ([identification isEqualToString:kApiIdentificationDataForSearch] ||
                    [identification isEqualToString:kApiIdentificationDataForSearchMailbox] ||
                    [identification isEqualToString:kApiIdentificationDataForSearchDiscussion])
                {
                    if ([[jp.jsonDictionary objectForKey:@"data"] count] < 1)
                    {
                        PRESENT_ERROR(@"Nic nenalezeno.", @"Dle zadané kombinace se nepodařilo nic najít.")
                        _noMoreSearchResult = YES;
                        _showingSearchResult = NO;
                    } else {
                        TableConfigurator *tc = [[TableConfigurator alloc] init];
                        tc.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
                        [tc configurePeopleTableSearch:self withData:jp.jsonDictionary addingData:NO];
                        _noMoreSearchResult = NO;
                        _showingSearchResult = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self reloadTableDataWithScrollToTop:YES];
                        });
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self enableNavigationButtons:YES];
                    });
                }
                if ([identification isEqualToString:kApiIdentificationDataForSearchOlder] ||
                    [identification isEqualToString:kApiIdentificationDataForSearchMailboxOlder] ||
                    [identification isEqualToString:kApiIdentificationDataForSearchDiscussionOlder])
                {
                    if ([[jp.jsonDictionary objectForKey:@"data"] count] < 1)
                    {
                        _noMoreSearchResult = YES;
                        _showingSearchResult = YES;
                    } else {
                        TableConfigurator *tc = [[TableConfigurator alloc] init];
                        tc.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
                        [tc configurePeopleTableSearch:self withData:jp.jsonDictionary addingData:YES];
                        _noMoreSearchResult = NO;
                        _showingSearchResult = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self reloadTableDataWithScrollToTop:NO];
                        });
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self enableNavigationButtons:YES];
                    });
                }
                if ([identification isEqualToString:kApiIdentificationDataForDiscussion])
                {
                    // THIS CODE IS CALLED SO MANY TIMES UNTIL OLDER THAN LAST_VISIT POST IS FOUND or FORCE LIMIT IS REACHED.
                    // OR there is NO posts at all.
                    
                    if ([_temporaryDataStorageBeforeLastReadIsFound objectForKey:@"discussion"]) {
                        // add posts only
                        NSMutableArray *a = [[NSMutableArray alloc] initWithArray:[_temporaryDataStorageBeforeLastReadIsFound objectForKey:@"data"]];
                        [a addObjectsFromArray:[jp.jsonDictionary objectForKey:@"data"]];
                        for (NSMutableDictionary *md in a) {
                            // Set all these posts as NEW.
                            [md setValue:@"yes" forKey:@"new"];
                        }
                        [_temporaryDataStorageBeforeLastReadIsFound removeObjectForKey:@"data"];
                        [_temporaryDataStorageBeforeLastReadIsFound setObject:a forKey:@"data"];
                    } else {
                        // add all - first call
                        [_temporaryDataStorageBeforeLastReadIsFound addEntriesFromDictionary:jp.jsonDictionary];
                    }
                    
                    BOOL postsExistsInDiscussion = YES;
                    if ([[_temporaryDataStorageBeforeLastReadIsFound objectForKey:@"data"] count] < 1) {
                        // If there are no POSTS in discussion - JUMP TO END.
                        PRESENT_INFO(@"Žádný příspěvek.", @"V této diskuzi zatím není žádný příspěvěk.")
                        postsExistsInDiscussion = NO;
                    } else {
                        // Load posts until last unread in current data is found.
                        [_lastVisitWuId setString:[[_temporaryDataStorageBeforeLastReadIsFound objectForKey:@"discussion"] objectForKey:@"last_visit"]];
                        if (_lastVisitWuId && [_lastVisitWuId length] > 0)
                        {
                            BOOL lastUnreadPostReached = NO;
                            NSArray *posts = [_temporaryDataStorageBeforeLastReadIsFound objectForKey:@"data"];
                            for (NSDictionary *d in posts)
                            {
                                NSInteger id_wu = [[d objectForKey:@"id_wu"] integerValue];
                                if (id_wu <= [_lastVisitWuId integerValue]) {
                                    lastUnreadPostReached = YES;
                                }
                            }
                            
                            // is last unread or limit is reached
                            NSInteger loadLimit = [[Preferences maximumUnreadPostsLoad:nil] integerValue];
                            if (!lastUnreadPostReached && [[_temporaryDataStorageBeforeLastReadIsFound objectForKey:@"data"] count] < (loadLimit + 1))
                            {
                                // load more from id
                                NSString *lastId = [[posts lastObject] objectForKey:@"id_wu"];
                                NSString *discussionId = [[jp.jsonDictionary objectForKey:@"discussion"] objectForKey:@"id_klub"];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self removeLoadingView];
                                });
                                [self getDataForDiscussion:discussionId loadMoreToShowAllUnreadFromId:lastId];
                                return;
                            }
                        }
                    }
                    
                    // Last UNREAD/LIMIT post is found so configure table.
                    TableConfigurator *tc = [[TableConfigurator alloc] init];
                    tc.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
                    [tc reconfigurePeopleTableDiscussion:self withData:_temporaryDataStorageBeforeLastReadIsFound withActionIdentification:identification];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self enableNavigationButtons:YES];
                        NSInteger lastUnreadIndex = 0;
                        for (NSDictionary *d in [_temporaryDataStorageBeforeLastReadIsFound objectForKey:@"data"]) {
                            if ([[d objectForKey:@"new"] length] > 0) {
                                lastUnreadIndex++;
                            }
                        }
                        // Scroll to last unread post
                        if (postsExistsInDiscussion)
                            [self reloadTableDataWithScrollToRow:lastUnreadIndex > 0 ? lastUnreadIndex - 1 : 0];
                    });
                }
                if ([identification isEqualToString:kApiIdentificationDataForDiscussionFromID])
                {
                    NSString *firstArrivedIdWu = [[[jp.jsonDictionary objectForKey:@"data"] firstObject] objectForKey:@"id_wu"];
                    
                    // firstObject = section 0
                    for (NSDictionary *existingPost in [self.nyxRowsForSections firstObject])
                    {
                        NSString *existingIdWu = [existingPost objectForKey:@"id_wu"];
                        if ([firstArrivedIdWu isEqualToString:existingIdWu])
                        {
                            // SAME ID WU ARRIVED - got same data as we already have. Very small discussion - do not load more.
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self enableNavigationButtons:YES];
                                [self removeLoadingView];
                            });
                            return;
                        }
                    }
                    
                    self.title = [[jp.jsonDictionary objectForKey:@"discussion"] objectForKey:@"name_main"];
                    TableConfigurator *tc = [[TableConfigurator alloc] init];
                    tc.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
                    [tc reconfigurePeopleTableDiscussion:self withData:jp.jsonDictionary withActionIdentification:identification];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self enableNavigationButtons:YES];
                        [self reloadTableDataWithScrollToTop:self.scrollToTopAfterReloadUntilUserScrolls];
                    });
                }
                if ([identification isEqualToString:kApiIdentificationDataForDiscussionRefreshAfterPost])
                {
                    TableConfigurator *tc = [[TableConfigurator alloc] init];
                    tc.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
                    [tc reconfigurePeopleTableDiscussion:self withData:jp.jsonDictionary withActionIdentification:identification];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self enableNavigationButtons:YES];
                        [self reloadTableDataWithScrollToTop:YES];
                    });
                }
                
                
                // POST DATA
                if ([identification isEqualToString:kApiIdentificationPostDelete])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[self.nyxRowsForSections objectAtIndex:_indexPathToDelete.section] removeObjectAtIndex:_indexPathToDelete.row];
                        [[self.nyxPostsRowHeights objectAtIndex:_indexPathToDelete.section] removeObjectAtIndex:_indexPathToDelete.row];
                        [[self.nyxPostsRowBodyTexts objectAtIndex:_indexPathToDelete.section] removeObjectAtIndex:_indexPathToDelete.row];
                        if (_preserveIndexPathAfterLoadFromId) {
                            NSInteger row = [_preserveIndexPathAfterLoadFromId row];
                            row > 0 ? (row -= 1) : (row) ;
                            _preserveIndexPathAfterLoadFromId = [NSIndexPath indexPathForRow:row inSection:_preserveIndexPathAfterLoadFromId.section];
                        }
                        // !!! TODO TO DO - smazat sekci, pokud k ni jiz nepatri zadne bunky !!! ?? nebo znovy vytvorit ? ...
                        // !!! TOFIX TO FIX - pokud postnu neco na Friend feed tesne po pulnoci a pak to smazu, apka zatim asi jebne. !!!
                        [_table deleteRowsAtIndexPaths:@[_indexPathToDelete] withRowAnimation:UITableViewRowAnimationFade];
                    });
                }
                if ([identification isEqualToString:kApiIdentificationPostThumbs])
                {
                    NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
                    NSString *postId = [[[self.nyxRowsForSections objectAtIndex:_indexPathToRating.section] objectAtIndex:_indexPathToRating.row] objectForKey:@"id_wu"];
                    [self getCurrentRating:discussionId forPost:postId];
                }
                if ([identification isEqualToString:kApiIdentificationPostRefreshThumbs])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *negative = [jp.jsonDictionary objectForKey:@"negative"];
                        NSString *positive = [jp.jsonDictionary objectForKey:@"positive"];
                        NSInteger currentRating = ([positive integerValue]) - ([negative integerValue]);
                        ContentTableWithPeopleCell *c = [_table cellForRowAtIndexPath:_indexPathToRating];
                        [c.ratingGiven setString:[@(currentRating) stringValue]];
                        NSMutableDictionary *currentDS = [[self.nyxRowsForSections objectAtIndex:_indexPathToRating.section] objectAtIndex:_indexPathToRating.row];
                        [currentDS setValue:[@(currentRating) stringValue] forKey:@"wu_rating"];
                        [[self.nyxRowsForSections objectAtIndex:_indexPathToRating.section] replaceObjectAtIndex:_indexPathToRating.row withObject:currentDS];
                        [c configureCellForIndexPath:_indexPathToRating];
                    });
                }
                if ([identification isEqualToString:kApiIdentificationPostGetRatingInfo])
                {
                    self.nestedPeopleTable = [[ContentTableWithPeople alloc] initWithRowHeight:70];
                    self.nestedPeopleTable.nController = self.nController;
                    self.nestedPeopleTable.allowsSelection = YES;
                    self.nestedPeopleTable.canEditFirstRow = YES;
                    self.nestedPeopleTable.widthForTableCellBodyTextView = self.widthForTableCellBodyTextView;
                    self.nestedPeopleTable.peopleTableMode = kPeopleTableModeRatingInfo;
                    self.nestedPeopleTable.title = @"Hodnocení";
                    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.nestedPeopleTable];
                    
                    [self.nController presentViewController:nc animated:YES completion:^{}];
                    
                    TableConfigurator *tc = [[TableConfigurator alloc] init];
                    [tc configurePeopleTableRatingInfo:self.nestedPeopleTable withData:jp.jsonDictionary];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.nestedPeopleTable reloadTableDataWithScrollToTop:YES];
                    });
                }
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeLoadingView];
    });
}

- (void)presentErrorWithTitle:(NSString *)title andMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        PRESENT_ERROR(title, message)
    });
}

#pragma mark - LONG PRESS DETECTOR

- (void)longPressOnCell:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        ContentTableWithPeopleCell *cell = (ContentTableWithPeopleCell *)sender.view;
        [self cellClickedForMoreActions:cell];
    }
}

#pragma mark - CELL MORE ACTIONS - LONG TOUCH

- (void)cellClickedForMoreActions:(ContentTableWithPeopleCell *)cell
{
    if (!self.nController) {
        NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"Navigation controller -- MAIN -- doesn't exist !!!");
        return;
    }
    // DISABLE actions for first CELL in these detail tables.
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailboxDetail] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail])
    {
        if ([[_table indexPathForCell:cell] row] < 1) {
            return;
        }
    }
    // ENABLE actions only for some table modes.
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeMailbox] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeMailboxDetail] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail])
    {
        // Remove strange links and detect recipient URLs if any
        RichTextProcessor *rtp = [[RichTextProcessor alloc] init];
        NSArray *httpOnlyUrls = [rtp getHttpOnlyUrls:[rtp getAllURLsFromAttributedAndSourceText:cell.bodyText withHtmlSource:cell.bodyTextSource]];
        NSArray *deduplicated = [rtp deduplicateUrls:httpOnlyUrls];
        [self showActionSheetForURLs:deduplicated forText:cell.bodyText withSource:cell.bodyTextSource insideCell:cell];
    }
}

- (void)showActionSheetForURLs:(NSArray *)httpUrls forText:(NSAttributedString *)attrText withSource:(NSString *)sourceText insideCell:(ContentTableWithPeopleCell *)cell
{
    RichTextProcessor *rtp = [[RichTextProcessor alloc] init];
    NSArray *urlsWithoutImages = [[NSArray alloc] initWithArray:[rtp urlsWithoutImages:httpUrls] copyItems:YES];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([urlsWithoutImages count] > 0)
    {
        for (NSURL *url in urlsWithoutImages)
        {
            UIAlertAction *webLink = [UIAlertAction actionWithTitle:[url absoluteString] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
            {
                if ([Preferences openUrlsInSafari:nil] && [[Preferences openUrlsInSafari:nil] length] > 0)
                {
                    [[UIApplication sharedApplication] openURL:url
                                                       options:@{}
                                             completionHandler:^(BOOL success) {}];
                } else {
                    WebVC *web = [[WebVC alloc] init];
                    web.urlToLoad = url;
                    [self.nController pushViewController:web animated:YES];
                }
            }];
            [alert addAction:webLink];
        }
    }
    
    NSArray *urlsWithImagesOnly = [[NSArray alloc] initWithArray:[rtp urlsWithImagesOnly:httpUrls] copyItems:YES];
    if ([urlsWithImagesOnly count] > 0)
    {
        UIAlertAction *showImages = [UIAlertAction actionWithTitle:@"Zobrazit obrázky" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
        {
            ImagePreviewVC *imagePreviewScreen = [[ImagePreviewVC alloc] init];
            imagePreviewScreen.imageUrls = urlsWithImagesOnly;
            imagePreviewScreen.nController = self.nController;
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:imagePreviewScreen];
            nc.modalPresentationStyle = UIModalPresentationCustom;
            [self presentViewController:nc animated:YES completion:^{}];
        }];
        [alert addAction:showImages];
    }
    
//    NSLog(@"%@ - %@ : ALL [%@]", self, NSStringFromSelector(_cmd), httpUrls);
//    NSLog(@"%@ - %@ : NO IMAGES [%@]", self, NSStringFromSelector(_cmd), urlsWithoutImages);
//    NSLog(@"%@ - %@ : IMAGES ONLY [%@]", self, NSStringFromSelector(_cmd), urlsWithImagesOnly);
    
    // -------- POST CONTENT -----------
    NSMutableDictionary *postContent = [[NSMutableDictionary alloc] init];
    NSData *rtf = [attrText dataFromRange:NSMakeRange(0, attrText.length)
                       documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType}
                                    error:nil];
    if (rtf)
        [postContent setObject:rtf forKey:(id)kUTTypeFlatRTFD];
    // Fallback with plain string.
    [postContent setObject:attrText.string forKey:(id)kUTTypeUTF8PlainText];
    // -------- POST CONTENT -----------
    
    UIAlertAction *copy = [UIAlertAction actionWithTitle:@"Kopírovat" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.items = @[postContent];
    }];
    [alert addAction:copy];
    
    if ([[Preferences allowCopyOfHTMLSourceCode:nil] length] > 0)
    {
        UIAlertAction *copySource = [UIAlertAction actionWithTitle:@"Kopírovat HTML kód" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
                                     {
                                         UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                         pasteboard.string = sourceText;
                                     }];
        [alert addAction:copySource];
    }
    
    UIAlertAction *sharePost = [UIAlertAction actionWithTitle:@"Sdílet" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
    {
        [self createSharingDataWithTitle:cell.nick andBody:cell.bodyTextSource andBodyAttributed:cell.bodyText imageUrls:urlsWithImagesOnly];
    }];
    [alert addAction:sharePost];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:cancel];
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion] || [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail])
    {
        UIAlertAction *showRating = [UIAlertAction actionWithTitle:@"Hodnocení" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
        {
            NSIndexPath *i = [_table indexPathForCell:cell];
            NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
            NSString *postId = [[[self.nyxRowsForSections objectAtIndex:i.section] objectAtIndex:i.row] objectForKey:@"id_wu"];
            [self getCurrentRatingForPresentation:discussionId forPost:postId];
        }];
        [alert addAction:showRating];
    }
    
    // For iPad
    alert.popoverPresentationController.sourceView = cell.contentView;
    alert.popoverPresentationController.sourceRect = cell.bounds;
    // --------
    [self.nController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - LOADING VIEW

- (void)placeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self enableNavigationButtons:NO];
        LoadingView *lv = [[LoadingView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:lv];
    });
}

- (void)removeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self enableNavigationButtons:YES];
        [[self.view viewWithTag:kLoadingCoverViewTag] removeFromSuperview];
    });
}

#pragma mark - REFRESH DATA IN LIST TABLE if RETURNING TO

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion]) {
        if (!parent) {
            POST_NOTIFICATION_LIST_TABLE_CHANGED
        }
    }
}

#pragma mark - SHARING

- (void)createSharingDataWithTitle:(NSString *)title andBody:(NSString *)bodyText andBodyAttributed:(NSAttributedString *)bodyAttributed imageUrls:(NSArray *)imageUrls
{
    RichTextProcessor *rtp = [[RichTextProcessor alloc] init];
    NSAttributedString *bodyWithFullUrls = [rtp replaceRelativeNyxUrlsInsidePostWithAbsoluteUrls:bodyAttributed];
    NSArray *httpOnlyUrls = [rtp getHttpOnlyUrls:[rtp getAllURLsFromAttributedAndSourceText:bodyWithFullUrls withHtmlSource:nil]];
    
    NSMutableArray *shareProviders = [[NSMutableArray alloc] init];
    ShareItemProviderText *textItem = [[ShareItemProviderText alloc] initWithTitle:title andBody:bodyText andBodyAttributed:bodyWithFullUrls andUrls:httpOnlyUrls];
    [shareProviders addObject:textItem];
    
    for (NSURL *u in imageUrls)
    {
        ShareItemProviderImage *i = [[ShareItemProviderImage alloc] initWithFileUrl:u];
        [shareProviders addObject:i];
    }
    
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:shareProviders applicationActivities:nil];
    [self presentActivityController:controller];
}

- (void)presentActivityController:(UIActivityViewController *)controller
{
    controller.modalPresentationStyle = UIModalPresentationPopover;
    
    if (self.nController) {
        [self.nController presentViewController:controller animated:YES completion:nil];
    } else {
        [self presentViewController:controller animated:YES completion:nil];
    }
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.barButtonItem = self.navigationItem.leftBarButtonItem;
    
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        if (completed) {
            // OK
        } else {
            // CANCEL
        }
        
        if (error) {
            NSString *e = [NSString stringWithFormat:@"%@, %@", error.localizedDescription, error.localizedFailureReason];
            NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), e);
        }
    };
}


#pragma mark - SEARCH

- (void)showSearchAlert:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Vyhledávání"
                                                                   message:@"Vyhledat podle nicku a textu."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *search = [UIAlertAction actionWithTitle:@"Vyhledat" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action) {
                                                      _noMoreSearchResult = NO;
                                                      _showingSearchResult = YES;
                                                      
                                                      [_searchNick setString:[[alert.textFields objectAtIndex:0] text]];
                                                      [_searchText setString:[[alert.textFields objectAtIndex:1] text]];
                                                      if ([self.peopleTableMode isEqualToString:kPeopleTableModeSearch])
                                                          [self getDataForSearchNick:_searchNick andText:_searchText];
                                                      if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox])
                                                          [self getDataForSearchMailboxNick:_searchNick andText:_searchText];
                                                      if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
                                                          [self getDataForSearchDiscussionNick:_searchNick andText:_searchText];
                                                  }];
    [alert addAction:search];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:cancel];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Nick";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Text";
    }];
    [self.nController presentViewController:alert animated:YES completion:^{}];
}


#pragma mark - NEW FEED POST

- (void)composeNewPost:(id)sender
{
    NewFeedPostVC *newFeedPostVC = [[NewFeedPostVC alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:newFeedPostVC];
    [self.nController presentViewController:nc animated:YES completion:^{}];
}


#pragma mark - COMPOSE NEW MAIL MESSAGE

- (void)chooseNickname:(id)sender
{
    PeopleAutocompleteVC *mailPeopleFindNick = [[PeopleAutocompleteVC alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:mailPeopleFindNick];
    [self.nController presentViewController:nc animated:YES completion:^{}];
}

- (void)composeNewMessageFor:(NSNotification *)notification
{
    // When responding from notification, this method opened from NSNotificationCenter could open 2 windows - one on window below.
    if (!self.view.window)
        return;
    
//        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), notification);
    NSDictionary *userData = [[notification userInfo] objectForKey:@"nKey"];
    NSString *nick = [userData objectForKey:@"nick"];
    NSString *lastActiveTimestamp = [[userData objectForKey:@"active"] objectForKey:@"time"];
    NSString *location = [[userData objectForKey:@"active"] objectForKey:@"location"];
    
    NSMutableString *body = [[NSMutableString alloc] initWithString:@"\nNová zpráva pro uživatele."];
    if (lastActiveTimestamp) {
        Timestamp *ts = [[Timestamp alloc] initWithTimestamp:lastActiveTimestamp];
        [body appendString:[NSString stringWithFormat:@"\nPoslední aktivita: %@", [ts getTime]]];
    }
    if (location) {
        [body appendString:[NSString stringWithFormat:@"\nPoslední lokace: %@", location]];
    }
    
    PeopleRespondVC *response = [[PeopleRespondVC alloc] init];
    response.nick = nick;
    response.bodyText = [[NSAttributedString alloc] initWithString:body attributes:@{NSForegroundColorAttributeName : [UIColor themeColorStandardText]}];
    response.bodyHeight = 80;
    response.postId = @"";
    response.postData = @{@"other_nick": nick};
    response.nController = self.nController;
    response.peopleRespondMode = kPeopleTableModeMailbox;
    [self.nController pushViewController:response animated:YES];
}

#pragma mark - AVATAR TAPPED

- (void)avatarTapped:(id)sender
{
    NSString *nick = [[sender userInfo] objectForKey:@"nick"];
    self.peopleManager = [[PeopleManager alloc] init];
    self.peopleManager.delegate = self;
    [self.peopleManager getDataForExactNick:nick];
}

- (void)peopleManagerFinished:(id)sender
{
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), peopleManager.userDataForExactNick);
    
    PeopleManager *peopleManager = (PeopleManager *)sender;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:peopleManager.userDataForExactNick, @"nKey", nil];
        NSNotification *n = [NSNotification notificationWithName:@"" object:nil userInfo:d];
        [self composeNewMessageFor:n];
    });
}


#pragma mark - DISMISS

- (void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}


@end


