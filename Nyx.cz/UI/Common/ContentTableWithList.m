//
//  ContentTableWithList.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 25/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ContentTableWithList.h"
#import "Constants.h"
#import "JSONParser.h"


@interface ContentTableWithList ()

@end

@implementation ContentTableWithList

- (id)initWithRowHeight:(CGFloat)rowHeight
{
    self = [super init];
    if (self)
    {
        _rh = rowHeight;
        self.nyxSections = [[NSMutableArray alloc] init];
        self.nyxRowsForSections = [[NSMutableArray alloc] init];
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
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
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
    ContentTableWithListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdForReuse];
    if (cell == nil)
    {
        cell = [[ContentTableWithListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdForReuse];
    }
    
    NSDictionary *cellData = [[self.nyxRowsForSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (cellData)
    {
        cell.boardName = [cellData objectForKey:@"jmeno"];
        cell.unreadCount = [cellData objectForKey:@"unread"];
        [cell configureCellForIndexPath:indexPath];
    }
    return cell;
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
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), userPostData);
    
//    NSString *nick;
//    NSString *postId;
//    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed] || [self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail]) {
//        nick = [userPostData objectForKey:@"nick"];
//        postId = [userPostData objectForKey:@"id_update"];
//    }
//    if ([self.peopleTableMode isEqualToString:kPeopleTableModeMailbox] || [self.peopleTableMode isEqualToString:kPeopleTableModeMailboxDetail]) {
//        nick = [userPostData objectForKey:@"other_nick"];
//        postId = [userPostData objectForKey:@"id_mail"];
//    }
//    NSAttributedString *str = [[self.nyxPostsRowBodyTexts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    CGFloat f = [[[self.nyxPostsRowHeights objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] floatValue];
//
//    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeed] || [self.peopleTableMode isEqualToString:kPeopleTableModeMailbox])
//    {
//        PeopleRespondVC *response = [[PeopleRespondVC alloc] init];
//        response.nick = nick;
//        response.bodyText = str;
//        response.bodyHeight = f;
//        response.postId = postId;
//        response.postData = userPostData;
//        response.nController = self.nController;
//        response.peopleRespondMode = self.peopleTableMode;
//        [self.nController pushViewController:response animated:YES];
//    }
//
//    if ([self.peopleTableMode isEqualToString:kPeopleTableModeFeedDetail]  || [self.peopleTableMode isEqualToString:kPeopleTableModeMailboxDetail]) {
//        ContentTableWithPeopleCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        [self cellClickedWithAttributedText:cell.bodyText];
//    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - TABLE ACTIONS

- (void)deletePostFor:(NSString *)nick withId:(NSString *)postId
{
//    NSString *api = [ApiBuilder apiFeedOfFriendsDeletePostAs:nick withId:postId];
//    ServerConnector *sc = [[ServerConnector alloc] init];
//    sc.identifitaion = nil;
//    sc.delegate = self;
//    [sc downloadDataForApiRequest:api];
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
//                    [[self.nyxRowsForSections objectAtIndex:_indexPathToDelete.section] removeObjectAtIndex:_indexPathToDelete.row];
//                    [[self.nyxPostsRowHeights objectAtIndex:_indexPathToDelete.section] removeObjectAtIndex:_indexPathToDelete.row];
//                    [[self.nyxPostsRowBodyTexts objectAtIndex:_indexPathToDelete.section] removeObjectAtIndex:_indexPathToDelete.row];
//                    // TODO TO DO - smazat sekci, pokud k ni jiz nepatri zadne bunky !!! ?? nebo znovy vytvorit ? ...
//                    [_table deleteRowsAtIndexPaths:@[_indexPathToDelete] withRowAnimation:UITableViewRowAnimationFade];
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



@end
