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
        _ratingLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_ratingLabel];
        
        _bodyView = [[UITextView alloc] init];
        _bodyView.backgroundColor = [UIColor clearColor];
        _bodyView.userInteractionEnabled = NO;
        [_bodyView setTextContainerInset:UIEdgeInsetsZero];
        _bodyView.textContainer.lineFragmentPadding = 0;
        [self addSubview:_bodyView];
        
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
        [self addSubview:_separator];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.numberOfTouchesRequired = 1;
        [_avatarView addGestureRecognizer:tapRecognizer];
        
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
    
    _nickLabel.frame = CGRectMake(avatarWidth + 2 * insect, insect, f.size.width - (avatarWidth + 3 * insect) - timeWidth - _ratingWidth - (3 * insect), 15);
    _timeLabel.frame = CGRectMake(_nickLabel.frame.origin.x + _nickLabel.frame.size.width + insect, insect, timeWidth, 13);
    _ratingLabel.frame = CGRectMake(_timeLabel.frame.origin.x + _timeLabel.frame.size.width + insect, insect, _ratingWidth, 13);
    
    _bodyView.frame = CGRectMake(avatarWidth + 2 * insect, 20, f.size.width - kWidthForTableCellBodyTextViewSubstract, f.size.height - 25);
    
    if (self.nick) {
        _separator.frame = CGRectMake(10, f.size.height - 1, f.size.width - 20, 1);
    }
}

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
    
    if (self.ratingGiven && [self.ratingGiven length] > 0) {
        self.rating = (NSString *)self.ratingGiven;
    }
    if (self.rating && [self.rating length] > 0 && ![self.rating isEqualToString:@"0"])
    {
        _ratingWidth = 25;
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
            _ratingLabel.textColor = [UIColor greenColor];
            _ratingLabel.text = [NSString stringWithFormat:@"+%@", self.rating];
        }
    } else {
        _ratingWidth = 0;
        [self setNeedsLayout];
        [self setNeedsDisplay];
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

- (void)cacheComplete:(NSData *)cache
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _avatarView.image = [UIImage imageWithData:cache];
        self.cache.delegate = nil;
        self.cache = nil;
    });
}



#pragma mark - TAP

- (void)tapped:(UITapGestureRecognizer *)sender
{
    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"AVATAR TAPPED.");
}


@end

