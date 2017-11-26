//
//  ContentTableWithListCell.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 25/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentTableWithListCell : UITableViewCell
{
    UILabel *_unreadLabel, *_boardNameLabel;
    UIView *_separator;
}


@property (nonatomic, strong) NSString *unreadCount;
@property (nonatomic, strong) NSString *boardName;


- (void)configureCellForIndexPath:(NSIndexPath *)idxPath;


@end
