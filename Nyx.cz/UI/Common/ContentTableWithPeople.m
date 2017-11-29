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
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox] || [self.peopleTableMode isEqualToString:kPeopleTableModeMailboxDetail])
        {
            nick = [cellData objectForKey:@"other_nick"];
            cell.mailboxDirection = [cellData objectForKey:@"direction"];
            cell.mailboxMailStatus = [cellData objectForKey:@"message_status"];
            cell.discussionNewPost = [cellData objectForKey:@"new"];
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion] || [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail])
        {
            nick = [cellData objectForKey:@"nick"];
            cell.discussionNewPost = [cellData objectForKey:@"new"];
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
    NSAttributedString *str = [[self.nyxPostsRowBodyTexts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    // RESPOND VIEW --------
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeMailbox] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeFriends] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
    {
        [self showRespondViewWithNick:nick
                             bodyText:str
                           bodyHeight:f
                               postId:postId
                         userPostData:userPostData];
    }
    // ---------------------
    
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail]  ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeMailboxDetail] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussionDetail]) {
        ContentTableWithPeopleCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self cellClickedWithAttributedText:cell.bodyText];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Delete (own posts!) from Friends FEED, COMMENTS in FEED, DISCUSSION
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail] ||
        [self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion])
    {
        NSString *nickForPost = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"nick"];
        if ([[[Preferences auth_nick:nil] uppercaseString] isEqualToString:nickForPost]) {
            if (indexPath.section == 0 && indexPath.row == 0 && !self.canEditFirstRow) {
                // First row is MAIN POST itself in case, this table is used in detail of MAIN POST for comments.
                return NO;
            } else {
                return YES;
            }
        }
        // NOT MINE POST - can't delete
        return NO;
    }
    // Delete mails in MAILBOX only ! Not in detail when composing message !
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        _indexPathToDelete = indexPath;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        // Try to find if we are going to delete COMMENT under POST or OWN WHOLE POST.
        
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail]) {
            // Get COMMENT ID under this POST.
            NSString *postToDelete = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_comment"];
            // User MAIN POST data with MAIN POST id are stored always as first CELL - so get POST MAIN ID here.
            NSDictionary *cellData = [[self.nyxRowsForSections objectAtIndex:0] objectAtIndex:0];
            NSString *id_update = [cellData objectForKey:@"id_update"];
            // Deleting by key id_comment
            [self deleteCommentOnFriendFeedFor:[Preferences auth_nick:nil] withId:id_update commentId:postToDelete];
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed]) {
            // Deleting MAIN POST by key id_update
            NSString *postToDelete = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_update"];
            [self deleteFriendFeedPostFor:[Preferences auth_nick:nil] withId:postToDelete];
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox]) {
            NSString *postToDelete = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_mail"];
            [self deleteMailMessageWithId:postToDelete];
        }
        if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion]) {
            NSString *discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
            NSString *postToDelete = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_wu"];
            [self deleteDiscussionPostFrom:discussionId withId:postToDelete];
        }
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

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
                     userPostData:@{}];
}

#pragma mark - TABLE ACTIONS - FEED

- (void)showRespondViewWithNick:(NSString *)nick
                       bodyText:(NSAttributedString *)bodyText
                     bodyHeight:(CGFloat)f
                         postId:(NSString *)postId
                   userPostData:(NSDictionary *)userPostData
{
    PeopleRespondVC *response = [[PeopleRespondVC alloc] init];
    response.nick = nick;
    response.bodyText = bodyText;
    response.bodyHeight = f;
    response.postId = postId;
    // --- Needed only for discussion club -------
    response.discussionId = [self.disscussionClubData objectForKey:@"id_klub"];
    // -------------------------------------------
    response.postData = userPostData;
    response.nController = self.nController;
    response.peopleRespondMode = self.peopleTableMode;
    [self.nController pushViewController:response animated:YES];
}

- (void)deleteCommentOnFriendFeedFor:(NSString *)nick withId:(NSString *)postId commentId:(NSString *)commentId
{
    NSString *api = [ApiBuilder apiFeedOfFriendsDeleteCommentAs:nick withId:postId commentId:commentId];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.identifitaion = nil;
    sc.delegate = self;
    [sc downloadDataForApiRequest:api];
}

- (void)deleteFriendFeedPostFor:(NSString *)nick withId:(NSString *)postId
{
    NSString *api = [ApiBuilder apiFeedOfFriendsDeletePostAs:nick withId:postId];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.identifitaion = nil;
    sc.delegate = self;
    [sc downloadDataForApiRequest:api];
}

- (void)deleteMailMessageWithId:(NSString *)messageId
{
    NSString *api = [ApiBuilder apiMailboxDeleteMessage:messageId];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.identifitaion = nil;
    sc.delegate = self;
    [sc downloadDataForApiRequest:api];
}

- (void)deleteDiscussionPostFrom:(NSString *)discussionId withId:(NSString *)postId
{
    NSString *api = [ApiBuilder apiDiscussionDeleteMessage:discussionId postId:postId];
    ServerConnector *sc = [[ServerConnector alloc] init];
    sc.identifitaion = nil;
    sc.delegate = self;
    [sc downloadDataForApiRequest:api];
}


#pragma mark - TABLE ACTIONS when SCROLL REACH END (mailbox, discussion) - LOAD MORE

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox]) {
        // Load more mails when reach end.
        if (indexPath.row + 1 == [[self.nyxRowsForSections objectAtIndex:0] count])
        {
            NSString *fromID = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_mail"];
            POST_NOTIFICATION_MAILBOX_LOAD_FROM(fromID)
        }
    }
    if ([self.peopleTableMode isEqualToString:kPeopleTableModeDiscussion]) {
        // Load more posts when reach end.
        if (indexPath.row + 1 == [[self.nyxRowsForSections objectAtIndex:0] count])
        {
            NSString *fromID = [[[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_wu"];
            [self placeLoadingView];
            POST_NOTIFICATION_DISCUSSION_LOAD_OLDER_FROM(fromID)
        }
    }
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[self.nyxRowsForSections objectAtIndex:_indexPathToDelete.section] removeObjectAtIndex:_indexPathToDelete.row];
                    [[self.nyxPostsRowHeights objectAtIndex:_indexPathToDelete.section] removeObjectAtIndex:_indexPathToDelete.row];
                    [[self.nyxPostsRowBodyTexts objectAtIndex:_indexPathToDelete.section] removeObjectAtIndex:_indexPathToDelete.row];
                    // !!! TODO TO DO - smazat sekci, pokud k ni jiz nepatri zadne bunky !!! ?? nebo znovy vytvorit ? ...
                    // !!! TOFIX TO FIX - pokud postnu neco na Friend feed tesne po pulnoci a pak to smazu, apka zatim asi jebne. !!!
                    [_table deleteRowsAtIndexPaths:@[_indexPathToDelete] withRowAnimation:UITableViewRowAnimationFade];
                });
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
        [self cellClickedWithAttributedText:cell.bodyText];
    }
}

#pragma mark - CELL BODY TEXT DETECTOR

- (void)cellClickedWithAttributedText:(NSAttributedString *)attrText
{
    if (!self.nController) {
        NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"Navigation controller doesn't exist !!!");
        return;
    }
    
    NSMutableArray *detectedUrls = [[NSMutableArray alloc] init];
    
    // First - detect properly configured URLs. Like with <a ...> tags.
    [attrText enumerateAttributesInRange:NSMakeRange(0, attrText.length)
                                 options:NSAttributedStringEnumerationReverse
                              usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        if ([attrs objectForKey:@"NSLink"]) {
            NSURL *url = [attrs objectForKey:@"NSLink"];
            NSLog(@"%@ - %@ Detected URL as NSLink : [%@]", self, NSStringFromSelector(_cmd), url);
            [detectedUrls addObject:url];
        }
    }];
    
    // Second - there could be URLs in text just in plain text - like https:// ...
    NSArray *words = [[attrText string] componentsSeparatedByString:@" "];
    for (NSString *component in words) {
        if ([component hasPrefix:@"http"]) {
            NSLog(@"%@ - %@ Detected URL as TEXT : [%@]", self, NSStringFromSelector(_cmd), component);
            // If there is new line at the end of the string - NSURL is nil.
            NSURL *u = [NSURL URLWithString:[component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            if (u)
                [detectedUrls addObject:u];
        }
    }
    
    // Remove strange links
    NSMutableArray *goodLinks = [NSMutableArray array];
    for (NSURL *url in detectedUrls) {
        if ([[url absoluteString] hasPrefix:@"http"]) {
            [goodLinks addObject:url];
        }
    }
    
    [self showActionSheetForURLs:goodLinks forText:attrText];
}

- (void)showActionSheetForURLs:(NSArray *)urls forText:(NSAttributedString *)attrText
{
    // Remove duplicates [NSSet] if any and filter arrays for images.
    NSArray *urlsWithoutImages = [[NSArray alloc] initWithArray:[self urlsWithoutImages:urls] copyItems:YES];
    NSArray *urlsWithImagesOnly = [[NSArray alloc] initWithArray:[self urlsWithImagesOnly:urls] copyItems:YES];
    
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
    
    NSArray *i = [self detectImagesAttributedText:attrText];
    if (i && [i count] > 0)
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

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Zrušit" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

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

- (NSArray *)detectImagesAttributedText:(NSAttributedString *)attrText
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
                image = [attachment image];
            else
                image = [attachment imageForBounds:[attachment bounds]
                                     textContainer:nil
                                    characterIndex:range.location];
            
            if (image)
                [imagesArray addObject:image];
        }
    }];
    return imagesArray;
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



