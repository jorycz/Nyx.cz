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
// Post content
#import "WebVC.h"
#import "PostImagesPreview.h"
// Pasteboard
#import <MobileCoreServices/MobileCoreServices.h>


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
        _scrollToTopAfterDataReload = NO;
        _identificationDelete = @"rowDelete";
        _identificationThumbs = @"thumbs";
        _identificationThumbsAfterRatingGive = @"afterRatingRefresh";
    }
    return self;
}

- (void)dealloc
{
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
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _table = [[UITableView alloc] init];
    [self.view addSubview:_table];

    [_table setBackgroundColor:[UIColor clearColor]];
    [_table setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
    [_table setDataSource:self];
    [_table setDelegate:self];
    [_table setRowHeight:_rh];
    _table.allowsSelection = self.allowsSelection;
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion]) {
        self.nController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                                                             target:self
                                                                                                                             action:@selector(createNewPostToDiscussion)];
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

#pragma mark - Table view data source

- (void)reloadTableData
{
    [_table reloadData];
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
        [self removeLoadingView];
    // neposouvat kdyz scrollujeme dolu a nacitaji se dalsi posty !!!
    if (!_scrollToTopAfterDataReload) {
        _scrollToTopAfterDataReload = YES;
    } else {
        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
    }
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
    if (cellData)
    {
        // remove all custom params
        cell.activeFriendStatus = nil;
        cell.commentsCount = nil;
        cell.mailboxDirection = nil;
        cell.mailboxMailStatus = nil;
        
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
            cell.bodyTextSource = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"text"];
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox] || [self.peopleTableMode isEqualToString:kPeopleTableModeMailboxDetail])
        {
            nick = [cellData objectForKey:@"other_nick"];
            cell.mailboxDirection = [cellData objectForKey:@"direction"];
            cell.mailboxMailStatus = [cellData objectForKey:@"message_status"];
            cell.discussionNewPost = [cellData objectForKey:@"new"];
            cell.bodyTextSource = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"content"];
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion] || [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail])
        {
            nick = [cellData objectForKey:@"nick"];
            cell.discussionNewPost = [cellData objectForKey:@"new"];
            cell.rating = [cellData objectForKey:@"wu_rating"];
            cell.bodyTextSource = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"content"];
        }
        cell.nick = nick;
        Timestamp *ts = [[Timestamp alloc] initWithTimestamp:[cellData objectForKey:@"time"]];
        cell.time = [ts getTimeWithDate];
        
        // Must be always set!
        cell.bodyText = [[self.nyxPostsRowBodyTexts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        [cell configureCellForIndexPath:indexPath];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFriends] || [self.peopleTableMode isEqualToString:kPeopleTableModeFriendsDetail]) {
        return 70;
    } else {
        CGFloat f = [[[self.nyxPostsRowHeights objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] floatValue];
        // + 30 = Nick name at the top of the Cell.
        return f + 30;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[self.nyxSections firstObject] isEqualToString:kDisableTableSections]) {
        return nil;
    }
    return [self.nyxSections objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *userPostData = [[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), userPostData);
    
    NSString *nick;
    NSString *postId;
    CGFloat f = 2.0f;
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed] || [self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail]) {
        nick = [userPostData objectForKey:@"nick"];
        postId = [userPostData objectForKey:@"id_update"];
        f = [[[self.nyxPostsRowHeights objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] floatValue];
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox] || [self.peopleTableMode isEqualToString:kPeopleTableModeMailboxDetail]) {
        nick = [userPostData objectForKey:@"other_nick"];
        postId = [userPostData objectForKey:@"id_mail"];
        f = [[[self.nyxPostsRowHeights objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] floatValue];
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFriends] || [self.peopleTableMode isEqualToString:kPeopleTableModeFriendsDetail]) {
        nick = [userPostData objectForKey:@"nick"];
        postId = @"666";
        f = 70;
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion] || [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail]) {
        nick = [userPostData objectForKey:@"nick"];
        postId = [userPostData objectForKey:@"id_wu"];
        f = [[[self.nyxPostsRowHeights objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] floatValue];
    }
    NSString *firstPostId = [[[self.nyxRowsForSections objectAtIndex:0] objectAtIndex:0] objectForKey:@"id_wu"];
    NSAttributedString *str = [[self.nyxPostsRowBodyTexts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    // RESPOND VIEW --------
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeMailbox] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeFriends] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
    {
        // Previous reactions ID (wu) to this POST.
        ContentTableWithPeopleCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSArray *recipientNames = [self getRecipientNamesFromSourceHtml:cell.bodyTextSource];
        NSArray *recipientLinks = [self getRelativeOnlyUrls:[self getAllURLsFromAttributedAndSourceText:cell.bodyText]];
        NSMutableArray *previousResponses = [[NSMutableArray alloc] init];
        if ([recipientNames count] == [recipientLinks count]) {
            for (NSInteger index = 0; index < [recipientNames count] ; index++)
            {
                NSString *name = [recipientNames objectAtIndex:index];
                NSString *reactionId = [[[recipientLinks objectAtIndex:index] componentsSeparatedByString:@"="] lastObject];
                [previousResponses addObject:@{@"name": name, @"reactionId": reactionId}];
            }
        }
//        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), previousResponses);
        
        [self showRespondViewWithNick:nick
                             bodyText:str
                           bodyHeight:f
                               postId:postId
                         userPostData:userPostData
               refreshFromFirstPostId:firstPostId
                previousReactionPosts:(NSArray *)previousResponses
         ];
    }
    // ---------------------
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail]  ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeMailboxDetail] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail]) {
        ContentTableWithPeopleCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self cellClickedForMoreActions:cell];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeMailbox] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
    {
        return YES;
    }
    return NO;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _tableEditShowDelete = NO;
    _tableEditShowThumbs = NO;
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
        _tableEditShowThumbs = YES;
    
    NSString *nickForPost = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"nick"];
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion] &&
        [[[Preferences auth_nick:nil] uppercaseString] isEqualToString:nickForPost])
        _tableEditShowDelete = YES;
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox])
        _tableEditShowDelete = YES;
    
    
    UIContextualAction *thumbup = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                          title:@"Ohodnotit"
                                                                        handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
    {
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion]) {
            _indexPathToRating = indexPath;
            NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
            NSString *postId = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_wu"];
            [self giveRatingInDiscusstion:discussionId toPost:postId givePositiveRating:YES];
        }
        completionHandler(YES);
    }];
    thumbup.image = [UIImage imageNamed:@"thumbup"];
    thumbup.backgroundColor = UIColorFromRGB(0x00EB08);
    
    UIContextualAction *thumbdown = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                            title:@"Ohodnotit"
                                                                          handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
    {
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion]) {
            _indexPathToRating = indexPath;
            NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
            NSString *postId = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_wu"];
            [self giveRatingInDiscusstion:discussionId toPost:postId givePositiveRating:NO];
        }
        completionHandler(YES);
    }];
    thumbdown.image = [UIImage imageNamed:@"thumbdown"];
    thumbdown.backgroundColor = UIColorFromRGB(0xEB0000);
    
    UIContextualAction *delete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                         title:@"Smazat"
                                                                       handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
    {
        _indexPathToDelete = indexPath;
        // Try to find if we are going to delete COMMENT under FEED POST or OWN WHOLE FEED POST.
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
    
    NSArray *buttons;
    _tableEditShowThumbs && _tableEditShowDelete ? buttons = @[thumbdown, thumbup, delete] : NULL ;
    _tableEditShowThumbs ? buttons = @[thumbdown, thumbup] : NULL ;
    _tableEditShowDelete ? buttons = @[delete] : NULL ;
    
    UISwipeActionsConfiguration *swipeActionConfig = [UISwipeActionsConfiguration configurationWithActions:buttons];
    swipeActionConfig.performsFirstActionWithFullSwipe = NO;
    
    return swipeActionConfig;
}

// NOT USED SINCE trailingSwipeActionsConfigurationForRowAtIndexPath is USED.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"");
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        _indexPathToDelete = indexPath;
//
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//        // Try to find if we are going to delete COMMENT under POST or OWN WHOLE POST.
//
//        if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail]) {
//            // Get COMMENT ID under this POST.
//            NSString *postToDelete = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_comment"];
//            // User MAIN POST data with MAIN POST id are stored always as first CELL - so get POST MAIN ID here.
//            NSDictionary *cellData = [[self.nyxRowsForSections objectAtIndex:0] objectAtIndex:0];
//            NSString *id_update = [cellData objectForKey:@"id_update"];
//            // Deleting by key id_comment
//            [self deleteCommentOnFriendFeedFor:[Preferences auth_nick:nil] withId:id_update commentId:postToDelete];
//        }
//        if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed]) {
//            // Deleting MAIN POST by key id_update
//            NSString *postToDelete = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_update"];
//            [self deleteFriendFeedPostFor:[Preferences auth_nick:nil] withId:postToDelete];
//        }
//        if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox]) {
//            NSString *postToDelete = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_mail"];
//            [self deleteMailMessageWithId:postToDelete];
//        }
//        if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion]) {
//            NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
//            NSString *postToDelete = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_wu"];
//            UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Smazat?"
//                                                                       message:@"Opravdu smazat příspěvek?"
//                                                                preferredStyle:(UIAlertControllerStyleAlert)];
//            UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Smazat" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
//                [self deleteDiscussionPostFrom:discussionId withId:postToDelete];
//            }];
//            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {}];
//            [a addAction:delete];
//            [a addAction:cancel];
//            [self presentViewController:a animated:YES completion:^{}];
//        }
//
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }
//}

#pragma mark - NEW POST TO DISCUSSION

- (void)createNewPostToDiscussion
{
    NSString *firstPostId = [[[self.nyxRowsForSections objectAtIndex:0] objectAtIndex:0] objectForKey:@"id_wu"];
    NSString *clubDescription = [NSString stringWithFormat:@"%@\n%@",
                                 [self.disscussionClubData objectForKey:@"name_main"],
                                 [self.disscussionClubData objectForKey:@"name_sub"]];
    NSAttributedString *club = [[NSAttributedString alloc] initWithString:clubDescription];
    [self showRespondViewWithNick:@""
                         bodyText:club
                       bodyHeight:45
                           postId:firstPostId
                     userPostData:@{@"content": clubDescription}
           refreshFromFirstPostId:(NSString *)firstPostId
            previousReactionPosts:nil
     ];
}

#pragma mark - TABLE ACTIONS - RESPOND TO SOMEONE

- (void)showRespondViewWithNick:(NSString *)nick
                       bodyText:(NSAttributedString *)bodyText
                     bodyHeight:(CGFloat)f
                         postId:(NSString *)postId
                   userPostData:(NSDictionary *)userPostData
         refreshFromFirstPostId:(NSString *)firstPostId
          previousReactionPosts:(NSArray *)previousReactionPostIds
{
    PeopleRespondVC *response = [[PeopleRespondVC alloc] init];
    response.nick = nick;
    response.bodyText = bodyText;
    response.bodyHeight = f;
    response.postId = postId;
    // --- Needed only for discussion club -------
    response.discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
    response.firstDiscussionPostId = firstPostId;
    response.previousReactions = previousReactionPostIds;
    // -------------------------------------------
    response.postData = userPostData;
    response.nController = self.nController;
    response.peopleRespondMode = self.peopleTableMode;
    [self.nController pushViewController:response animated:YES];
}

#pragma mark - TABLE ACTIONS when SCROLL REACH END (mailbox, discussion) - LOAD MORE

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox]) {
        // Load more mails when reach end.
        if (indexPath.row + 1 == [[self.nyxRowsForSections objectAtIndex:0] count])
        {
            NSString *fromID = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_mail"];
            _scrollToTopAfterDataReload = NO;
            POST_NOTIFICATION_MAILBOX_LOAD_FROM(fromID)
        }
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion]) {
        // Load more posts when reach end.
        if (indexPath.row + 1 == [[self.nyxRowsForSections objectAtIndex:0] count])
        {
            NSString *fromID = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_wu"];
            _scrollToTopAfterDataReload = NO;
            [self placeLoadingView];
            POST_NOTIFICATION_DISCUSSION_LOAD_OLDER_FROM(fromID)
        }
    }
}

#pragma mark - DELETING

- (void)deleteCommentOnFriendFeedFor:(NSString *)nick withId:(NSString *)postId commentId:(NSString *)commentId
{
    NSString *api = [ApiBuilder apiFeedOfFriendsDeleteCommentAs:nick withId:postId commentId:commentId];
    [self postPostWithApiCall:api andIdentification:_identificationDelete];
}

- (void)deleteFriendFeedPostFor:(NSString *)nick withId:(NSString *)postId
{
    NSString *api = [ApiBuilder apiFeedOfFriendsDeletePostAs:nick withId:postId];
    [self postPostWithApiCall:api andIdentification:_identificationDelete];
}

- (void)deleteMailMessageWithId:(NSString *)messageId
{
    NSString *api = [ApiBuilder apiMailboxDeleteMessage:messageId];
    [self postPostWithApiCall:api andIdentification:_identificationDelete];
}

- (void)deleteDiscussionPostFrom:(NSString *)discussionId withId:(NSString *)postId
{
    NSString *api = [ApiBuilder apiDiscussionDeleteMessage:discussionId postId:postId];
    [self postPostWithApiCall:api andIdentification:_identificationDelete];
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
            [self postPostWithApiCall:api andIdentification:_identificationThumbs];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {}];
        [a addAction:delete];
        [a addAction:cancel];
        [self presentViewController:a animated:YES completion:^{}];
    } else {
        [self postPostWithApiCall:api andIdentification:_identificationThumbs];
    }
}

- (void)getCurrentRating:(NSString *)dId toPost:(NSString *)postId
{
    NSString *api = [ApiBuilder apiDiscussionGetRatingInDiscussion:dId forPost:postId];
    [self postPostWithApiCall:api andIdentification:_identificationThumbsAfterRatingGive];
}

#pragma mark - SERVER CONNECTOR API CALL

- (void)postPostWithApiCall:(NSString *)api andIdentification:(NSString *)identification
{
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.identifitaion = identification;
    sc.delegate = self;
    [sc downloadDataForApiRequest:api];
}

#pragma mark - SERVER DELEGATE

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
                if ([identification isEqualToString:_identificationDelete])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[self.nyxRowsForSections objectAtIndex:_indexPathToDelete.section] removeObjectAtIndex:_indexPathToDelete.row];
                        [[self.nyxPostsRowHeights objectAtIndex:_indexPathToDelete.section] removeObjectAtIndex:_indexPathToDelete.row];
                        [[self.nyxPostsRowBodyTexts objectAtIndex:_indexPathToDelete.section] removeObjectAtIndex:_indexPathToDelete.row];
                        // !!! TODO TO DO - smazat sekci, pokud k ni jiz nepatri zadne bunky !!! ?? nebo znovy vytvorit ? ...
                        // !!! TOFIX TO FIX - pokud postnu neco na Friend feed tesne po pulnoci a pak to smazu, apka zatim asi jebne. !!!
                        [_table deleteRowsAtIndexPaths:@[_indexPathToDelete] withRowAnimation:UITableViewRowAnimationFade];
                    });
                }
                if ([identification isEqualToString:_identificationThumbs])
                {
                    NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
                    NSString *postId = [[[self.nyxRowsForSections objectAtIndex:_indexPathToRating.section] objectAtIndex:_indexPathToRating.row] objectForKey:@"id_wu"];
                    [self getCurrentRating:discussionId toPost:postId];
                }
                if ([identification isEqualToString:_identificationThumbsAfterRatingGive])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *negative = [jp.jsonDictionary objectForKey:@"negative"];
                        NSString *positive = [jp.jsonDictionary objectForKey:@"positive"];
                        NSInteger currentRating = ([positive integerValue]) - ([negative integerValue]);
                        ContentTableWithPeopleCell *c = [_table cellForRowAtIndexPath:_indexPathToRating];
                        [c.ratingGiven setString:[@(currentRating) stringValue]];
                        [c configureCellForIndexPath:_indexPathToRating];
                    });
                }
            }
        }
    }
}

#pragma mark - RESULT

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

#pragma mark - CELL BODY TEXT DETECTOR

- (void)cellClickedForMoreActions:(ContentTableWithPeopleCell *)cell
{
    if (!self.nController) {
        NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"Navigation controller doesn't exist !!!");
        return;
    }
    
    // ENABLE sharing actions only for some table modes.
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeMailbox] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeMailboxDetail] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail])
    {
        // Remove strange links and detect recipient URLs if any
        NSArray *httpOnlyUrls = [self getHttpOnlyUrls:[self getAllURLsFromAttributedAndSourceText:cell.bodyText]];
        [self showActionSheetForURLs:httpOnlyUrls forText:cell.bodyText withSource:cell.bodyTextSource];
    }
}

- (void)showActionSheetForURLs:(NSArray *)httpUrls forText:(NSAttributedString *)attrText withSource:(NSString *)sourceText
{
    // Remove duplicates [NSSet] if any and filter arrays for images. // TODO TO DO
    NSArray *urlsWithoutImages = [[NSArray alloc] initWithArray:[self urlsWithoutImages:httpUrls] copyItems:YES];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Volby příspěvku"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([urlsWithoutImages count] > 0) {
        for (NSURL *url in urlsWithoutImages) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:[url absoluteString] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
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
            [alert addAction:action];
        }
    }
    
    NSArray *urlsWithImagesOnly = [[NSArray alloc] initWithArray:[self urlsWithImagesOnly:httpUrls] copyItems:YES];
    NSArray *i = [self detectImageAttachmentsInsideAttribudetText:attrText];
    if ((i && [i count] > 0) || [urlsWithImagesOnly count] > 0)
    {
        UIAlertAction *showImages = [UIAlertAction actionWithTitle:@"Zobrazit obrázky" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            PostImagesPreview *pip = [[PostImagesPreview alloc] init];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:pip];
            pip.images = i;
            pip.imageUrls = urlsWithImagesOnly;
            nc.modalPresentationStyle = UIModalPresentationCustom;
            [self presentViewController:nc animated:YES completion:^{}];
        }];
        [alert addAction:showImages];
    }
    
    UIAlertAction *copy = [UIAlertAction actionWithTitle:@"Kopírovat" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        NSData *rtf = [attrText dataFromRange:NSMakeRange(0, attrText.length)
                           documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType}
                                        error:nil];
        if (rtf)
            [item setObject:rtf forKey:(id)kUTTypeFlatRTFD];
        // Fallback
        [item setObject:attrText.string forKey:(id)kUTTypeUTF8PlainText];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.items = @[item];
    }];
    [alert addAction:copy];
    
    UIAlertAction *copySource = [UIAlertAction actionWithTitle:@"Kopírovat HTML kód" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = sourceText;
    }];
    [alert addAction:copySource];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TEXT BODY PARSING FOR URLs

- (NSArray *)urlsWithoutImages:(NSArray *)detectedUrl
{
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for (NSURL *u in detectedUrl) {
        if ([[[u absoluteString] lowercaseString] hasSuffix:@"jpeg"] ||
            [[[u absoluteString] lowercaseString] hasSuffix:@"jpg"] ||
            [[[u absoluteString] lowercaseString] hasSuffix:@"png"])
        {
            continue;
        }
        if (![a containsObject:u])
        {
            [a addObject:u];
        }
    }
    return (NSArray *)a;
}

- (NSArray *)urlsWithImagesOnly:(NSArray *)detectedUrl
{
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for (NSURL *u in detectedUrl) {
        if ([[[u absoluteString] lowercaseString] hasSuffix:@"jpeg"] ||
            [[[u absoluteString] lowercaseString] hasSuffix:@"jpg"] ||
            [[[u absoluteString] lowercaseString] hasSuffix:@"png"])
        {
            if (![a containsObject:u]) {
                [a addObject:u];
            }
        }
    }
    return (NSArray *)a;
}

- (NSArray *)detectImageAttachmentsInsideAttribudetText:(NSAttributedString *)attrText
{
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    [attrText enumerateAttribute:NSAttachmentAttributeName
                         inRange:NSMakeRange(0, [attrText length])
                         options:0
                      usingBlock:^(id value, NSRange range, BOOL *stop)
    {
        if ([value isKindOfClass:[NSTextAttachment class]])
        {
            NSTextAttachment *attachment = (NSTextAttachment *)value;
            UIImage *image = nil;
            if ([attachment image])
            {
                image = [attachment image];
            }
            else
            {
                image = [attachment imageForBounds:[attachment bounds]
                                     textContainer:nil
                                    characterIndex:range.location];
            }
            if (image)
                [imagesArray addObject:image];
        }
    }];
    return imagesArray;
}

- (NSMutableArray *)getAllURLsFromAttributedAndSourceText:(NSAttributedString *)attrText
{
    NSMutableArray *detectedUrls = [[NSMutableArray alloc] init];
    
    // First - detect properly configured URLs. Like with <a ...> tags.
    [attrText enumerateAttributesInRange:NSMakeRange(0, attrText.length)
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
                                  if ([attrs objectForKey:@"NSLink"]) {
                                      NSURL *url = [attrs objectForKey:@"NSLink"];
//                                      NSLog(@"%@ - %@ Detected URL as NSLink : [%@]", self, NSStringFromSelector(_cmd), url);
                                      [detectedUrls addObject:url];
                                  }
                              }];
    
    // Second - there could be URLs in text just in plain text - like https:// ...
    NSArray *words = [[attrText string] componentsSeparatedByString:@" "];
    for (NSString *component in words) {
        if ([component hasPrefix:@"http"]) {
//            NSLog(@"%@ - %@ Detected URL as TEXT : [%@]", self, NSStringFromSelector(_cmd), component);
            // If there is new line at the end of the string - NSURL is nil.
            NSURL *u = [NSURL URLWithString:[component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            if (u)
                [detectedUrls addObject:u];
        }
    }
    return detectedUrls;
}

- (NSArray *)getHttpOnlyUrls:(NSArray *)allUrls
{
    NSMutableArray *urls = [NSMutableArray array];
    for (NSURL *url in allUrls) {
        if ([[url absoluteString] hasPrefix:@"http"])
        {
            [urls addObject:url];
        }
    }
    return (NSArray *)urls;
}

- (NSArray *)getRelativeOnlyUrls:(NSArray *)allUrls
{
    NSMutableArray *urls = [NSMutableArray array];
    for (NSURL *url in allUrls) {
        if ([[url absoluteString] hasPrefix:@"applewebdata"])
        {
            [urls addObject:[url query]];
        }
    }
    return (NSArray *)urls;
}

- (NSArray *)getRecipientNamesFromSourceHtml:(NSString *)sourceText
{
    NSArray *recNames = [sourceText componentsSeparatedByString:@"\""];
    NSMutableArray *recipientNames = [NSMutableArray array];
    for (NSString *name in recNames) {
        if ([name hasPrefix:@"replyto"])
        {
            [recipientNames addObject:[name substringFromIndex:7]];
        }
    }
    return (NSArray *)recipientNames;
}

#pragma mark - LOADING VIEW

- (void)placeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.nController.topViewController.navigationItem.rightBarButtonItem setEnabled:NO];
        LoadingView *lv = [[LoadingView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:lv];
    });
}

- (void)removeLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.nController.topViewController.navigationItem.rightBarButtonItem setEnabled:YES];
        [[self.view viewWithTag:kLoadingCoverViewTag] removeFromSuperview];
    });
}

#pragma mark - REFRESH DATA IN LIST TABLE

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion]) {
        if (!parent) {
            POST_NOTIFICATION_LIST_TABLE_CHANGED
        }
    }
}


@end



