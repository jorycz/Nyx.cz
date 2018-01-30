//
//  TableConfigurator.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 14/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "TableConfigurator.h"
#import "Constants.h"
#import "ComputeRowHeight.h"
#import "Preferences.h"
#import "Timestamp.h"
#import "Colors.h"


@implementation TableConfigurator


- (instancetype)init
{
    self = [super init];
    if (self) {}
    return self;
}


#pragma mark - LIST TABLE - FIRST TIME CONFIGURATION

- (void)configureListTableBookmark:(ContentTableWithList *)table withData:(NSDictionary *)dict
{
    NSDictionary *postDictionaries = [dict objectForKey:@"data"];
    NSArray *categories = [postDictionaries objectForKey:@"categories"];
    NSArray *discussions = [postDictionaries objectForKey:@"discussions"];
    
    [table.nyxSections removeAllObjects];
    [table.nyxRowsForSections removeAllObjects];
    
    if (postDictionaries && categories && discussions)
    {
        for (NSDictionary *category in categories)
        {
            NSString *id_cat = [category objectForKey:@"id_cat"];
            NSString *name = [category objectForKey:@"jmeno"];
            [table.nyxSections addObject:name];
            
            NSMutableArray *discussionsInSection = [[NSMutableArray alloc] init];
            for (NSDictionary *discussion in discussions)
            {
                NSString *discussion_id_cat = [discussion objectForKey:@"id_cat"];
                if ([discussion_id_cat isEqualToString:id_cat])
                {
                    [discussionsInSection addObject:discussion];
                }
            }
            [table.nyxRowsForSections addObject:discussionsInSection];
        }
    }
}

- (void)configureListTableHistory:(ContentTableWithList *)table withData:(NSDictionary *)dict
{
    NSDictionary *postDictionaries = [dict objectForKey:@"data"];
    NSArray *discussions = [postDictionaries objectForKey:@"discussions"];
    
    [table.nyxSections removeAllObjects];
    [table.nyxSections addObject:kDisableTableSections];
    [table.nyxRowsForSections removeAllObjects];
    
    if (postDictionaries && discussions)
    {
        NSMutableArray *discussionsInSection = [[NSMutableArray alloc] init];
        for (NSDictionary *discussion in discussions)
        {
            [discussionsInSection addObject:discussion];
        }
        [table.nyxRowsForSections addObject:discussionsInSection];
    }
}


#pragma mark - PEOPLE TABLE - FIRST TIME CONFIGURATION

- (void)configurePeopleTableFriendsFeed:(ContentTableWithPeople *)table withData:(NSDictionary *)dict
{
    NSMutableArray *_dateSections = [[NSMutableArray alloc] init];
    NSMutableArray *_datePosts = [[NSMutableArray alloc] init];
    NSMutableArray *_postsRowHeights = [[NSMutableArray alloc] init];
    NSMutableArray *_postsRowBodyTexts = [[NSMutableArray alloc] init];
    
    // Search for unique dates.
    for (NSDictionary *d in [dict objectForKey:@"data"])
    {
        Timestamp *ts = [[Timestamp alloc] initWithTimestamp:[d objectForKey:@"time"]];
        NSString *date = [ts getDayDate];
        if ([_dateSections indexOfObject:date] == NSNotFound)
        {
            [_dateSections addObject:date];
            
            // Assign object with same day to temp array and then insert this temp array to array which will be DS for rows (in section).
            NSMutableArray *tempArrayForPosts = [[NSMutableArray alloc] init];
            NSMutableArray *tempArrayForRowHeights = [[NSMutableArray alloc] init];
            NSMutableArray *tempArrayForRowBodyText = [[NSMutableArray alloc] init];
            for (NSDictionary *d in [dict objectForKey:@"data"])
            {
                Timestamp *tsForAll = [[Timestamp alloc] initWithTimestamp:[d objectForKey:@"time"]];
                NSString *dateForAll = [tsForAll getDayDate];
                if ([dateForAll isEqualToString:date]) {
                    [tempArrayForPosts addObject:d];
                    
                    // Calculate heights and create array with same structure just only for row height.
                    // 60 is minimum height - table ROW height is initialized to 70 below ( 70 - nick name )
                    ComputeRowHeight *rowHeight = [[ComputeRowHeight alloc] initWithText:[d objectForKey:@"text"]
                                                                                forWidth:self.widthForTableCellBodyTextView
                                                                               minHeight:kMinimumPeopleTableCellHeight
                                                                            inlineImages:nil];
                    [tempArrayForRowHeights addObject:[NSNumber numberWithFloat:rowHeight.heightForRow]];
                    [tempArrayForRowBodyText addObject:rowHeight.attributedText];
                }
            }
            [_datePosts addObject:tempArrayForPosts];
            [_postsRowHeights addObject:tempArrayForRowHeights];
            [_postsRowBodyTexts addObject:tempArrayForRowBodyText];
        }
    }
    
    // SECTIONS - dates in this case
    [table.nyxSections removeAllObjects];
    [table.nyxSections addObjectsFromArray:_dateSections];
    // WHOLE dictionaries with all data
    [table.nyxRowsForSections removeAllObjects];
    [table.nyxRowsForSections addObjectsFromArray:_datePosts];
    // Heights computed by attributed texts for rows
    [table.nyxPostsRowHeights removeAllObjects];
    [table.nyxPostsRowHeights addObjectsFromArray:_postsRowHeights];
    // Formated attributed texts
    [table.nyxPostsRowBodyTexts removeAllObjects];
    [table.nyxPostsRowBodyTexts addObjectsFromArray:_postsRowBodyTexts];
}

- (void)configurePeopleTableMailbox:(ContentTableWithPeople *)table withData:(NSDictionary *)dict addingData:(BOOL)addData
{
    NSMutableArray *postDictionaries = [[NSMutableArray alloc] init];
    [postDictionaries addObjectsFromArray:[dict objectForKey:@"data"]];
    
    if ([postDictionaries count] > 0)
    {
        // Add FEED post as first cell here also.
        [table.nyxSections removeAllObjects];
        [table.nyxSections addObjectsFromArray:@[kDisableTableSections]];
        
        NSMutableArray *tempArrayForRowSections = [[NSMutableArray alloc] init];
        NSMutableArray *tempArrayForRowHeights = [[NSMutableArray alloc] init];
        NSMutableArray *tempArrayForRowBodyText = [[NSMutableArray alloc] init];
        
        for (NSDictionary *d in postDictionaries)
        {
            [tempArrayForRowSections addObject:d];
            // Calculate heights and create array with same structure just only for row height.
            // 60 is minimum height - table ROW height is initialized to 70 below ( 70 - nick name )
            ComputeRowHeight *rowHeight = [[ComputeRowHeight alloc] initWithText:[d objectForKey:@"content"]
                                                                        forWidth:self.widthForTableCellBodyTextView
                                                                       minHeight:kMinimumPeopleTableCellHeight
                                                                    inlineImages:[Preferences showImagesInlineInPost:nil]];
            [tempArrayForRowHeights addObject:[NSNumber numberWithFloat:rowHeight.heightForRow]];
            [tempArrayForRowBodyText addObject:rowHeight.attributedText];
        }
        
        if (addData)
        {
            // Add new posts complete data to previous complete posts data.
            NSMutableArray *previousNyxRowsForSections = [[NSMutableArray alloc] initWithArray:[table.nyxRowsForSections objectAtIndex:0]];
            [previousNyxRowsForSections addObjectsFromArray:tempArrayForRowSections];
            [table.nyxRowsForSections removeAllObjects];
            [table.nyxRowsForSections addObjectsFromArray:@[previousNyxRowsForSections]];
            
            NSMutableArray *previousNyxPostsRowHeights = [[NSMutableArray alloc] initWithArray:[table.nyxPostsRowHeights objectAtIndex:0]];
            [previousNyxPostsRowHeights addObjectsFromArray:tempArrayForRowHeights];
            [table.nyxPostsRowHeights removeAllObjects];
            [table.nyxPostsRowHeights addObjectsFromArray:@[previousNyxPostsRowHeights]];
            
            NSMutableArray *previousNyxPostsRowBodyTexts = [[NSMutableArray alloc] initWithArray:[table.nyxPostsRowBodyTexts objectAtIndex:0]];
            [previousNyxPostsRowBodyTexts addObjectsFromArray:tempArrayForRowBodyText];
            [table.nyxPostsRowBodyTexts removeAllObjects];
            [table.nyxPostsRowBodyTexts addObjectsFromArray:@[previousNyxPostsRowBodyTexts]];
        }
        else
        {
            [table.nyxRowsForSections removeAllObjects];
            [table.nyxRowsForSections addObjectsFromArray:@[tempArrayForRowSections]];
            
            [table.nyxPostsRowHeights removeAllObjects];
            [table.nyxPostsRowHeights addObjectsFromArray:@[tempArrayForRowHeights]];
            
            [table.nyxPostsRowBodyTexts removeAllObjects];
            [table.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
        }
    }
}

- (void)configurePeopleTablePeople:(ContentTableWithPeople *)table withData:(NSDictionary *)dict
{
    NSMutableArray *postDictionaries = [[NSMutableArray alloc] init];
    [postDictionaries addObjectsFromArray:[dict objectForKey:@"data"]];
    
    if ([postDictionaries count] > 0)
    {
        // Add FEED post as first cell here also.
        [table.nyxSections removeAllObjects];
        [table.nyxSections addObjectsFromArray:@[kDisableTableSections]];
        
        NSMutableArray *tempArrayForRowSections = [[NSMutableArray alloc] init];
        NSMutableArray *tempArrayForRowBodyText = [[NSMutableArray alloc] init];
        
        for (NSDictionary *d in postDictionaries)
        {
            [tempArrayForRowSections addObject:d];
            
            NSDictionary *active = [d objectForKey:@"active"];
            if (active) {
                Timestamp *ts = [[Timestamp alloc] initWithTimestamp:[active objectForKey:@"time"]];
                NSString *location = [active objectForKey:@"location"];
                NSMutableString *body = [[NSMutableString alloc] initWithString:@""];
                [body appendString:[NSString stringWithFormat:@"Aktivita: %@ - %@", [ts getTime], location]];
                NSAttributedString *atStr = [[NSAttributedString alloc] initWithString:body attributes:@{NSForegroundColorAttributeName : [UIColor themeColorStandardText]}];
                [tempArrayForRowBodyText addObject:atStr];
            } else {
                [tempArrayForRowBodyText addObject:[[NSAttributedString alloc] initWithString:@""]];
            }
        }
        [table.nyxRowsForSections removeAllObjects];
        [table.nyxRowsForSections addObjectsFromArray:@[tempArrayForRowSections]];
        [table.nyxPostsRowBodyTexts removeAllObjects];
        [table.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
    }
}

- (void)configurePeopleTableNotices:(ContentTableWithPeople *)table withData:(NSDictionary *)dict
{
    // To forward last visit information. NEEDED ONLY FOR NOTICES TABLE.
    table.noticesLastVisitTimestamp = [[dict objectForKey:@"data"] objectForKey:@"notice_last_visit"];
    
    NSMutableArray *postDictionaries = [[NSMutableArray alloc] init];
    [postDictionaries addObjectsFromArray:[[dict objectForKey:@"data"] objectForKey:@"items"]];
    
    if ([postDictionaries count] > 0)
    {
        [table.nyxSections removeAllObjects];
        [table.nyxSections addObjectsFromArray:@[kDisableTableSections]];
        
        NSMutableArray *tempArrayForRowSections = [[NSMutableArray alloc] init];
        NSMutableArray *tempArrayForRowHeights = [[NSMutableArray alloc] init];
        NSMutableArray *tempArrayForRowBodyText = [[NSMutableArray alloc] init];
        
        for (NSDictionary *d in postDictionaries)
        {
            [tempArrayForRowSections addObject:d];
            // Calculate heights and create array with same structure just only for row height.
            // 60 is minimum height - table ROW height is initialized to 70 below ( 70 - nick name )
            ComputeRowHeight *rowHeight = [[ComputeRowHeight alloc] initWithText:[d objectForKey:@"content"]
                                                                        forWidth:self.widthForTableCellBodyTextView
                                                                       minHeight:kMinimumPeopleTableCellHeight
                                                                    inlineImages:[Preferences showImagesInlineInPost:nil]];
            [tempArrayForRowHeights addObject:[NSNumber numberWithFloat:rowHeight.heightForRow]];
            [tempArrayForRowBodyText addObject:rowHeight.attributedText];
        }
        
        // First discussion load - remove all data and start again
        [table.nyxRowsForSections removeAllObjects];
        [table.nyxRowsForSections addObjectsFromArray:@[tempArrayForRowSections]];
        
        [table.nyxPostsRowHeights removeAllObjects];
        [table.nyxPostsRowHeights addObjectsFromArray:@[tempArrayForRowHeights]];
        
        [table.nyxPostsRowBodyTexts removeAllObjects];
        [table.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
    }
}

- (void)configurePeopleTableSearch:(ContentTableWithPeople *)table withData:(NSDictionary *)dict addingData:(BOOL)addData
{
    NSMutableArray *postDictionaries = [[NSMutableArray alloc] init];
    [postDictionaries addObjectsFromArray:[dict objectForKey:@"data"]];
    
    if ([postDictionaries count] > 0)
    {
        [table.nyxSections removeAllObjects];
        [table.nyxSections addObjectsFromArray:@[kDisableTableSections]];
        
        NSMutableArray *tempArrayForRowSections = [[NSMutableArray alloc] init];
        NSMutableArray *tempArrayForRowHeights = [[NSMutableArray alloc] init];
        NSMutableArray *tempArrayForRowBodyText = [[NSMutableArray alloc] init];
        
        for (NSDictionary *d in postDictionaries)
        {
            // In case I need show club name inside body of the search result user post.
            NSMutableString *finalBody = [[NSMutableString alloc] init];
            NSString *clubNameFromGLobalSearch = [d objectForKey:@"klub_jmeno"];
            // If it is post from GLOBAL SEARCH ONLY - there will be KEY "klub_jmeno"
            // In that case - insert that CLUB NAME before post body and replace that KEY in dictionary for TABLE.
            if (clubNameFromGLobalSearch && [clubNameFromGLobalSearch length] > 0)
                [finalBody appendString:[NSString stringWithFormat:@"<b>%@</b><br>", clubNameFromGLobalSearch]];
            [finalBody appendString:[d objectForKey:@"content"]];
            NSMutableDictionary *finalDictionary = [[NSMutableDictionary alloc] initWithDictionary:d];
            [finalDictionary setValue:finalBody forKey:@"content"];
            
            [tempArrayForRowSections addObject:finalDictionary];
            // Calculate heights and create array with same structure just only for row height.
            // 60 is minimum height - table ROW height is initialized to 70 below ( 70 - nick name )
            ComputeRowHeight *rowHeight = [[ComputeRowHeight alloc] initWithText:finalBody
                                                                        forWidth:self.widthForTableCellBodyTextView
                                                                       minHeight:kMinimumPeopleTableCellHeight
                                                                    inlineImages:[Preferences showImagesInlineInPost:nil]];
            [tempArrayForRowHeights addObject:[NSNumber numberWithFloat:rowHeight.heightForRow]];
            [tempArrayForRowBodyText addObject:rowHeight.attributedText];
        }
        
        if (addData)
        {
            // Add new posts complete data to previous complete posts data.
            NSMutableArray *previousNyxRowsForSections = [[NSMutableArray alloc] initWithArray:[table.nyxRowsForSections objectAtIndex:0]];
            [previousNyxRowsForSections addObjectsFromArray:tempArrayForRowSections];
            [table.nyxRowsForSections removeAllObjects];
            [table.nyxRowsForSections addObjectsFromArray:@[previousNyxRowsForSections]];
            
            NSMutableArray *previousNyxPostsRowHeights = [[NSMutableArray alloc] initWithArray:[table.nyxPostsRowHeights objectAtIndex:0]];
            [previousNyxPostsRowHeights addObjectsFromArray:tempArrayForRowHeights];
            [table.nyxPostsRowHeights removeAllObjects];
            [table.nyxPostsRowHeights addObjectsFromArray:@[previousNyxPostsRowHeights]];
            
            NSMutableArray *previousNyxPostsRowBodyTexts = [[NSMutableArray alloc] initWithArray:[table.nyxPostsRowBodyTexts objectAtIndex:0]];
            [previousNyxPostsRowBodyTexts addObjectsFromArray:tempArrayForRowBodyText];
            [table.nyxPostsRowBodyTexts removeAllObjects];
            [table.nyxPostsRowBodyTexts addObjectsFromArray:@[previousNyxPostsRowBodyTexts]];
        }
        else
        {
            // First discussion load - remove all data and start again
            [table.nyxRowsForSections removeAllObjects];
            [table.nyxRowsForSections addObjectsFromArray:@[tempArrayForRowSections]];
            
            [table.nyxPostsRowHeights removeAllObjects];
            [table.nyxPostsRowHeights addObjectsFromArray:@[tempArrayForRowHeights]];
            
            [table.nyxPostsRowBodyTexts removeAllObjects];
            [table.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
        }
    }
}

#pragma mark - PEOPLE TABLE - RECONFIGURATION

- (void)reconfigurePeopleTableDiscussion:(ContentTableWithPeople *)table withData:(NSDictionary *)dict withActionIdentification:(NSString *)identification
{
    // To forward all information about current discussion club. NEEDED ONLY FOR DISCUSSION CLUB TABLES.
    table.disscussionClubData = [dict objectForKey:@"discussion"];
    
    NSMutableArray *postDictionaries = [[NSMutableArray alloc] init];
    [postDictionaries addObjectsFromArray:[dict objectForKey:@"data"]];
    
    if ([postDictionaries count] > 0)
    {
        [table.nyxSections removeAllObjects];
        [table.nyxSections addObjectsFromArray:@[kDisableTableSections]];
        
        NSMutableArray *tempArrayForRowSections = [[NSMutableArray alloc] init];
        NSMutableArray *tempArrayForRowHeights = [[NSMutableArray alloc] init];
        NSMutableArray *tempArrayForRowBodyText = [[NSMutableArray alloc] init];
        
        for (NSDictionary *d in postDictionaries)
        {
            [tempArrayForRowSections addObject:d];
            // Calculate heights and create array with same structure just only for row height.
            // 60 is minimum height - table ROW height is initialized to 70 below ( 70 - nick name )
            ComputeRowHeight *rowHeight = [[ComputeRowHeight alloc] initWithText:[d objectForKey:@"content"]
                                                                        forWidth:self.widthForTableCellBodyTextView
                                                                       minHeight:kMinimumPeopleTableCellHeight
                                                                    inlineImages:[Preferences showImagesInlineInPost:nil]];
            [tempArrayForRowHeights addObject:[NSNumber numberWithFloat:rowHeight.heightForRow]];
            [tempArrayForRowBodyText addObject:rowHeight.attributedText];
        }
        
        if ([identification isEqualToString:kApiIdentificationDataForDiscussionFromID])
        {
            // Add new posts data at the END of previous posts data - if there are any (loading FROM ID from Notices cause no previous data are loaded).
            if ([table.nyxRowsForSections count] > 0)
            {
                NSMutableArray *previousNyxRowsForSections = [[NSMutableArray alloc] initWithArray:[table.nyxRowsForSections objectAtIndex:0]];
                [previousNyxRowsForSections addObjectsFromArray:tempArrayForRowSections];
                [table.nyxRowsForSections removeAllObjects];
                [table.nyxRowsForSections addObjectsFromArray:@[previousNyxRowsForSections]];
                
                NSMutableArray *previousNyxPostsRowHeights = [[NSMutableArray alloc] initWithArray:[table.nyxPostsRowHeights objectAtIndex:0]];
                [previousNyxPostsRowHeights addObjectsFromArray:tempArrayForRowHeights];
                [table.nyxPostsRowHeights removeAllObjects];
                [table.nyxPostsRowHeights addObjectsFromArray:@[previousNyxPostsRowHeights]];
                
                NSMutableArray *previousNyxPostsRowBodyTexts = [[NSMutableArray alloc] initWithArray:[table.nyxPostsRowBodyTexts objectAtIndex:0]];
                [previousNyxPostsRowBodyTexts addObjectsFromArray:tempArrayForRowBodyText];
                [table.nyxPostsRowBodyTexts removeAllObjects];
                [table.nyxPostsRowBodyTexts addObjectsFromArray:@[previousNyxPostsRowBodyTexts]];
            } else {
                [table.nyxRowsForSections addObjectsFromArray:@[tempArrayForRowSections]];
                [table.nyxPostsRowHeights addObjectsFromArray:@[tempArrayForRowHeights]];
                [table.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
            }
        }
        if ([identification isEqualToString:kApiIdentificationDataForDiscussion])
        {
            // First discussion load - remove all data and start again
            [table.nyxRowsForSections removeAllObjects];
            [table.nyxRowsForSections addObjectsFromArray:@[tempArrayForRowSections]];
            
            [table.nyxPostsRowHeights removeAllObjects];
            [table.nyxPostsRowHeights addObjectsFromArray:@[tempArrayForRowHeights]];
            
            [table.nyxPostsRowBodyTexts removeAllObjects];
            [table.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
        }
        if ([identification isEqualToString:kApiIdentificationDataForDiscussionRefreshAfterPost])
        {
            // Add new posts data at the BEGINNING of previous posts data - IF EXISTS (this could be first post in new discussion).
            if ([table.nyxRowsForSections count] > 0) {
                [tempArrayForRowSections addObjectsFromArray:[table.nyxRowsForSections objectAtIndex:0]];
                [table.nyxRowsForSections removeAllObjects];
            }
            [table.nyxRowsForSections addObjectsFromArray:@[tempArrayForRowSections]];
            
            if ([table.nyxPostsRowHeights count] > 0) {
                [tempArrayForRowHeights addObjectsFromArray:[table.nyxPostsRowHeights objectAtIndex:0]];
                [table.nyxPostsRowHeights removeAllObjects];
            }
            [table.nyxPostsRowHeights addObjectsFromArray:@[tempArrayForRowHeights]];
            
            if ([table.nyxPostsRowBodyTexts count] > 0) {
                [tempArrayForRowBodyText addObjectsFromArray:[table.nyxPostsRowBodyTexts objectAtIndex:0]];
                [table.nyxPostsRowBodyTexts removeAllObjects];
            }
            [table.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
        }
    }
}

#pragma mark - PEOPLE TABLE - CONFIGURATION FOR RESPONSE SCREEN - DIFFERENT MODES

- (void)reconfigurePeopleTableForResponseScreen:(ContentTableWithPeople *)table withData:(NSDictionary *)dict withTableMode:(NSString *)tableMode postData:(NSDictionary *)postData moreRows:(NSArray *)moreRows moreHeights:(NSArray *)moreHeights moreTexts:(NSArray *)moreTexts
{
    // Response VC for Feed comments.
    if ([tableMode isEqualToString:kPeopleTableModeFeed])
    {
        NSMutableArray * postDictionaries = [[NSMutableArray alloc] init];
        [postDictionaries addObject:postData];
        [postDictionaries addObjectsFromArray:[[dict objectForKey:@"data"] objectForKey:@"comments"]];
        
        if ([postDictionaries count] > 0)
        {
            // Add FEED post as first cell here also.
            [table.nyxSections removeAllObjects];
            [table.nyxSections addObjectsFromArray:@[kDisableTableSections]];
            [table.nyxRowsForSections removeAllObjects];
            [table.nyxRowsForSections addObjectsFromArray:@[postDictionaries]];
            
            NSMutableArray *tempArrayForRowHeights = [[NSMutableArray alloc] init];
            NSMutableArray *tempArrayForRowBodyText = [[NSMutableArray alloc] init];
            
            for (NSDictionary *d in postDictionaries)
            {
                // Calculate heights and create array with same structure just only for row height.
                // 60 is minimum height - table ROW height is initialized to 70 below ( 70 - nick name )
                ComputeRowHeight *rowHeight = [[ComputeRowHeight alloc] initWithText:[d objectForKey:@"text"]
                                                                            forWidth:self.widthForTableCellBodyTextView
                                                                           minHeight:kMinimumPeopleTableCellHeight
                                                                        inlineImages:nil];
                [tempArrayForRowHeights addObject:[NSNumber numberWithFloat:rowHeight.heightForRow]];
                [tempArrayForRowBodyText addObject:rowHeight.attributedText];
            }
            [table.nyxPostsRowHeights removeAllObjects];
            [table.nyxPostsRowHeights addObjectsFromArray:@[tempArrayForRowHeights]];
            [table.nyxPostsRowBodyTexts removeAllObjects];
            [table.nyxPostsRowBodyTexts addObjectsFromArray:@[tempArrayForRowBodyText]];
        }
    }
    
    // Response VC for Mailbox response.
    if ([tableMode isEqualToString:kPeopleTableModeMailbox] ||
        [tableMode isEqualToString:kPeopleTableModeFriends] ||
        [tableMode isEqualToString:kPeopleTableModeDiscussion] ||
        [tableMode isEqualToString:kPeopleTableModeNotices] ||
        [tableMode isEqualToString:kPeopleTableModeDiscussionDetail])
    {
        [table.nyxSections removeAllObjects];
        [table.nyxRowsForSections removeAllObjects];
        [table.nyxPostsRowHeights removeAllObjects];
        [table.nyxPostsRowBodyTexts removeAllObjects];
        
        [table.nyxSections addObjectsFromArray:@[kDisableTableSections]];
        [table.nyxRowsForSections addObjectsFromArray:@[moreRows]];
        [table.nyxPostsRowHeights addObjectsFromArray:@[moreHeights]];
        [table.nyxPostsRowBodyTexts addObjectsFromArray:@[moreTexts]];
    }
}

#pragma mark - RATING INFO

- (void)configurePeopleTableRatingInfo:(ContentTableWithPeople *)table withData:(NSDictionary *)dict
{
    if ([[dict objectForKey:@"positive"] isEqualToString:@"0"]) {
        [table.nyxSections addObject:[NSString stringWithFormat:@"Pozitivní žádné."]];
    } else {
        [table.nyxSections addObject:[NSString stringWithFormat:@"Pozitivní (%@)", [dict objectForKey:@"positive"]]];
    }
    if ([[dict objectForKey:@"negative"] isEqualToString:@"0"]) {
        [table.nyxSections addObject:[NSString stringWithFormat:@"Negativní žádné."]];
    } else {
        [table.nyxSections addObject:[NSString stringWithFormat:@"Negativní (%@)", [dict objectForKey:@"negative"]]];
    }
    
    NSMutableArray *positive = [[NSMutableArray alloc] init];
    NSMutableArray *positiveRows = [[NSMutableArray alloc] init];
    NSMutableArray *positiveTexts = [[NSMutableArray alloc] init];
    for (NSString *nick in [dict objectForKey:@"positive_list"]) {
        [positive addObject:@{@"nick": nick}];
        [positiveRows addObject:[NSNumber numberWithFloat:35]];
        [positiveTexts addObject:[[NSAttributedString alloc] initWithString:@"Pozitivní hodnocení" attributes:@{NSForegroundColorAttributeName : [UIColor themeColorStandardText]}]];
    }
    
    NSMutableArray *negative = [[NSMutableArray alloc] init];
    NSMutableArray *negativeRows = [[NSMutableArray alloc] init];
    NSMutableArray *negativeTexts = [[NSMutableArray alloc] init];
    for (NSString *nick in [dict objectForKey:@"negative_list"]) {
        [negative addObject:@{@"nick": nick}];
        [negativeRows addObject:[NSNumber numberWithFloat:35]];
        [negativeTexts addObject:[[NSAttributedString alloc] initWithString:@"Negativní hodnocení" attributes:@{NSForegroundColorAttributeName : [UIColor themeColorStandardText]}]];
    }
    
    [table.nyxRowsForSections addObject:positive];
    [table.nyxRowsForSections addObject:negative];
    [table.nyxPostsRowHeights addObject:positiveRows];
    [table.nyxPostsRowHeights addObject:negativeRows];
    [table.nyxPostsRowBodyTexts addObject:positiveTexts];
    [table.nyxPostsRowBodyTexts addObject:negativeTexts];
}





@end






