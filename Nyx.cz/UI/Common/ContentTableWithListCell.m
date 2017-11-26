//
//  ContentTableWithListCell.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 25/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ContentTableWithListCell.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>


@implementation ContentTableWithListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor whiteColor];
        
        _unreadLabel = [[UILabel alloc] init];
        _unreadLabel.backgroundColor = COLOR_SYSTEM_TURQUOISE;
        _unreadLabel.textColor = [UIColor whiteColor];
        _unreadLabel.userInteractionEnabled = NO;
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        _unreadLabel.font = [UIFont boldSystemFontOfSize:10];
        _unreadLabel.layer.cornerRadius = 12;
        _unreadLabel.clipsToBounds = YES;
        [self addSubview:_unreadLabel];
        
        _boardNameLabel = [[UILabel alloc] init];
        _boardNameLabel.backgroundColor = [UIColor clearColor];
        _boardNameLabel.userInteractionEnabled = NO;
        _boardNameLabel.textAlignment = NSTextAlignmentLeft;
        _boardNameLabel.font = [UIFont boldSystemFontOfSize:10];
        [self addSubview:_boardNameLabel];
        
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
        [self addSubview:_separator];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Preserver background colors.
    _unreadLabel.backgroundColor = COLOR_SYSTEM_TURQUOISE;
    _separator.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    // Preserver background colors.
    _unreadLabel.backgroundColor = COLOR_SYSTEM_TURQUOISE;
    _separator.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect f = self.frame;
    
    _unreadLabel.frame = CGRectMake(3, 3, 26, f.size.height - 6);
    
    _boardNameLabel.frame = CGRectMake(34, 2, f.size.width - 36, f.size.height - 4);
    
    _separator.frame = CGRectMake(5, f.size.height - 1, f.size.width - 10, 1);
}

- (void)configureCellForIndexPath:(NSIndexPath *)idxPath
{
    NSInteger unread = [self.unreadCount integerValue];
    if (unread > 999) {
        _unreadLabel.text = @"1K+";
    } else {
        _unreadLabel.text = self.unreadCount;
    }
    _boardNameLabel.text = self.boardName;
    self.backgroundColor = [UIColor whiteColor];
}


@end
