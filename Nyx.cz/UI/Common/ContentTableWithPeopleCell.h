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
    UILabel *_nickLabel, *_timeLabel, *_ratingLabel;
    UITextView *_bodyView;
    UIView *_separator;
    
    CGFloat _ratingWidth;
}


@property (nonatomic, strong) CacheManager *cache;

@property (nonatomic, strong) NSString *nick;
@property (nonatomic, strong) NSAttributedString *bodyText;

// Not used inside cell but used for copy in ActionShareSheet
@property (nonatomic, strong) NSString *bodyTextSource;


// Optional
@property (nonatomic, strong) NSString *commentsCount;
@property (nonatomic, strong) NSString *mailboxDirection;
@property (nonatomic, strong) NSString *mailboxMailStatus;
@property (nonatomic, strong) NSString *activeFriendStatus;
@property (nonatomic, strong) NSString *discussionNewPost;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *rating;

@property (nonatomic, strong) NSMutableString *ratingGiven;


- (void)configureCellForIndexPath:(NSIndexPath *)idxPath;


@end
