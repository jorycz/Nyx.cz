//
//  SideMenuTopSection.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "SideMenuTopSection.h"
#import "Preferences.h"
#import <QuartzCore/QuartzCore.h>
#import "Colors.h"


@implementation SideMenuTopSection

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = COLOR_BACKGROUND_WHITE;
        
        _userAvatarView = [[UIImageView alloc] init];
        _userAvatarView.contentMode = UIViewContentModeCenter;
        _userAvatarView.backgroundColor = COLOR_BACKGROUND_WHITE;
        _userAvatarView.userInteractionEnabled = YES;
        _userAvatarView.layer.cornerRadius = 5;
        _userAvatarView.layer.masksToBounds = YES;
        [self addSubview:_userAvatarView];
        
        _userName = [[UITextField alloc] init];
        _userName.userInteractionEnabled = NO;
        _userName.backgroundColor = COLOR_BACKGROUND_WHITE;
        _userName.textColor = COLOR_TEXT_BLACK;
        _userName.textAlignment = NSTextAlignmentLeft;
        _userName.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:_userName];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getAvatar)];
        tap.numberOfTapsRequired = 1;
        [_userAvatarView addGestureRecognizer:tap];
    }
    return self;
}

- (void)dealloc
{
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect f = self.frame;
    
    CGFloat avatarWidth = 40;
    CGFloat avatarHeight = 50;
    NSInteger y = (f.size.height / 2) - (avatarHeight / 2);
    
    _userAvatarView.frame = CGRectMake(y, y, 40, 50);
    
    _userName.frame = CGRectMake(y + avatarWidth + y, f.size.height / 4, f.size.width - avatarWidth - 30, f.size.height / 2);
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    !_userAvatarView.image ? [self getAvatar] : NULL ;
    [_userName.text length] < 1 ? _userName.text = [[Preferences auth_nick:nil] uppercaseString] : NULL ;
}

- (void)getAvatar
{
    NSString *avName = [[Preferences auth_nick:nil] uppercaseString];
    self.cache = [[CacheManager alloc] init];
    self.cache.delegate = self;
    [self.cache getAvatarForNick:avName];
}

- (void)cacheComplete:(CacheManager *)cache
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *a = [UIImage imageWithData:cache.cacheData];
        _userAvatarView.image = a;
        self.cache.delegate = nil;
        self.cache = nil;
    });
}

@end
