//
//  ContentTableWithPeopleCell.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 20/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ContentTableWithPeopleCell.h"
#import "ComputeRowHeight.h"
#import "Constants.h"
#import "NewNoticesForPost.h"


@implementation ContentTableWithPeopleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor whiteColor];
        
        _avatarView = [[UIImageView alloc] init];
        _avatarView.backgroundColor = [UIColor clearColor];
        _avatarView.contentMode = UIViewContentModeCenter;
        _avatarView.layer.cornerRadius = 5;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.userInteractionEnabled = YES;
        [self addSubview:_avatarView];
        
        _nickLabel = [[UILabel alloc] init];
        _nickLabel.backgroundColor = [UIColor clearColor];
        _nickLabel.userInteractionEnabled = NO;
        _nickLabel.textAlignment = NSTextAlignmentLeft;
        _nickLabel.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:_nickLabel];
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.userInteractionEnabled = NO;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_timeLabel];
        
        _ratingLabel = [[UILabel alloc] init];
        _ratingLabel.backgroundColor = [UIColor clearColor];
        _ratingLabel.userInteractionEnabled = NO;
        _ratingLabel.textAlignment = NSTextAlignmentCenter;
        _ratingLabel.font = [UIFont boldSystemFontOfSize:12];
        [self addSubview:_ratingLabel];
        
        _bodyView = [[UITextView alloc] init];
        _bodyView.backgroundColor = [UIColor clearColor];
        _bodyView.userInteractionEnabled = NO;
        [_bodyView setTextContainerInset:UIEdgeInsetsZero];
        _bodyView.textContainer.lineFragmentPadding = 0;
        [self addSubview:_bodyView];
        
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor],
                                         NSUnderlineColorAttributeName: [UIColor clearColor],
                                         NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
        _bodyView.linkTextAttributes = linkAttributes;
        
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
        [self addSubview:_separator];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.numberOfTouchesRequired = 1;
        [_avatarView addGestureRecognizer:tapRecognizer];
        
        _disclosure = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
        _disclosure.contentMode = UIViewContentModeCenter;
        _disclosure.backgroundColor = [UIColor clearColor];
        [self addSubview:_disclosure];
        
        self.ratingGiven = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    _separator.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    _separator.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect f = self.frame;
    
    CGFloat insect = 5;
    CGFloat avatarWidth = 40;
    CGFloat avatarHeight = 50;
    
    CGFloat timeWidth = 115;
    
    _avatarView.frame = CGRectMake(insect, insect, avatarWidth, avatarHeight);
    _ratingLabel.frame = CGRectMake(insect, _avatarView.frame.origin.y + avatarHeight + 3, avatarWidth, 14);
    
    _nickLabel.frame = CGRectMake(avatarWidth + 2 * insect, insect, f.size.width - (avatarWidth + 3 * insect) - timeWidth - (3 * insect), 15);
    _timeLabel.frame = CGRectMake(_nickLabel.frame.origin.x + _nickLabel.frame.size.width + insect, insect, timeWidth, 13);
    
    _bodyView.frame = CGRectMake(avatarWidth + 2 * insect, 20, f.size.width - kWidthForTableCellBodyTextViewSubstract, f.size.height - 25);
    
    if (self.nick) {
        _separator.frame = CGRectMake(10, f.size.height - 1, f.size.width - 20, 1);
    }
    
    _disclosure.frame = CGRectMake(f.size.width - 12, 0, 12, f.size.height);
}

#pragma mark - CONFIG

- (void)configureCellForIndexPath:(NSIndexPath *)idxPath
{
    _nickLabel.text = self.nick;
    
    _bodyView.attributedText = self.bodyText;
    
    _avatarView.alpha = 1;
    _nickLabel.alpha = 1;
    _bodyView.alpha = 1;
    
    self.backgroundColor = [UIColor whiteColor];
    
    if (self.mailboxDirection && [self.mailboxDirection isEqualToString:@"to"]) {
        _avatarView.alpha = .4;
    } else {
        _avatarView.alpha = 1;
    }
    if (self.mailboxMailStatus && [self.mailboxMailStatus isEqualToString:@"read"]) {
        self.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    if (self.commentsCount && [self.commentsCount intValue] > 0) {
        self.backgroundColor = COLOR_SYSTEM_TURQUOISE_LIGHT;
    }
    if (self.activeFriendStatus) {
        self.backgroundColor = COLOR_SYSTEM_TURQUOISE_LIGHT;
    }
    if (self.discussionNewPost && [self.discussionNewPost isEqualToString:@"yes"]) {
        self.backgroundColor = COLOR_SYSTEM_TURQUOISE_LIGHT;
    }
    if (self.time && [self.time length] > 0) {
        _timeLabel.text = self.time;
    }
    // RATING
    if (self.ratingGiven && [self.ratingGiven length] > 0) {
        self.rating = (NSString *)self.ratingGiven;
    }
    if (self.rating && [self.rating length] > 0 && ![self.rating isEqualToString:@"0"])
    {
        NSInteger r = [self.rating integerValue];
        if (r < 0) {
            _ratingLabel.textColor = [UIColor redColor];
            _ratingLabel.text = self.rating;
            if (r < -5)
            {
                _avatarView.alpha = .3;
                _nickLabel.alpha = .3;
                _bodyView.alpha = .3;
            }
        } else {
            _ratingLabel.textColor = COLOR_RATING_POSITIVE;
            _ratingLabel.text = [NSString stringWithFormat:@"+%@", self.rating];
        }
    } else {
        _ratingLabel.text = @"";
    }
    
    // NOTICES
    _disclosure.alpha = 0;
    if (self.noticesLastVisit && [self.noticesLastVisit length] > 0) {
        [self checkNewsForPost:self.notice];
    }
    
    [self getAvatar];
}

#pragma mark - GET AVATAR

- (void)getAvatar
{
    if (self.nick && [self.nick length] > 0)
    {
        self.cache = [[CacheManager alloc] init];
        self.cache.delegate = self;
        [self.cache getAvatarForNick:self.nick];
    }
    else
    {
        _avatarView.image = [UIImage imageNamed:@"chat"];
    }
}

#pragma mark - DELEGATE

- (void)cacheComplete:(CacheManager *)cache
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _avatarView.image = [UIImage imageWithData:cache.cacheData];
        self.cache.delegate = nil;
        self.cache = nil;
    });
}

#pragma mark - TAP

- (void)tapped:(UITapGestureRecognizer *)sender
{
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"AVATAR TAPPED.");
}

#pragma mark - NOTICES NEWS CHECK

- (void)checkNewsForPost:(NSDictionary *)post
{
    NewNoticesForPost *np = [[NewNoticesForPost alloc] initWithPost:post forLastVisit:self.noticesLastVisit];
    if (np.nPosts && [np.nPosts count] > 0) {
        self.backgroundColor = COLOR_SYSTEM_TURQUOISE_LIGHT;
        if ([self.peopleCellMode isEqualToString:kPeopleTableModeNotices])
            _disclosure.alpha = 1;
    }
    if (np.nThumbup && [np.nThumbup count] > 0) {
        self.backgroundColor = COLOR_SYSTEM_TURQUOISE_LIGHT;
    }
    if (np.nThumbsdown && [np.nThumbsdown count] > 0) {
        self.backgroundColor = COLOR_SYSTEM_TURQUOISE_LIGHT;
    }
    // Show disclosure indicator even for old posts.
    if (np.oPosts && [np.oPosts count] > 0) {
        if ([self.peopleCellMode isEqualToString:kPeopleTableModeNotices])
            _disclosure.alpha = 1;
    }
    
    // IF content of POST itself in NOTICES TABLE DETAIL is REPLY, there shoud be time tag on first level.
    NSString *replyTime = [post objectForKey:@"time"];
    if (replyTime && [replyTime length] > 0) {
        NSInteger last = [self.noticesLastVisit integerValue];
        NSInteger postTime = [replyTime integerValue];
        if (postTime > last) {
            self.backgroundColor = COLOR_SYSTEM_TURQUOISE_LIGHT;
        }
    }
}



@end




