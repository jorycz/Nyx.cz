//
//  ContentTableWithPeopleCell.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 20/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CacheManager.h"


@interface ContentTableWithPeopleCell : UITableViewCell <CacheManagerDelegate>
{
    UIImageView *_avatarView;
    UILabel *_nickLabel;
    UITextView *_bodyView;
    UIView *_separator;
}


@property (nonatomic, strong) CacheManager *cache;

@property (nonatomic, strong) NSString *nick;
@property (nonatomic, strong) NSAttributedString *bodyText;

// Optional
@property (nonatomic, strong) NSString *commentsCount;
@property (nonatomic, strong) NSString *mailboxDirection;
@property (nonatomic, strong) NSString *mailboxMailStatus;


- (void)configureCellForIndexPath:(NSIndexPath *)idxPath;


@end
