//
//  SideMenuTopSection.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "SideMenuTopSection.h"
#import "Preferences.h"


@implementation SideMenuTopSection

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _userAvatarView = [[UIImageView alloc] init];
        _userAvatarView.contentMode = UIViewContentModeCenter;
        _userAvatarView.backgroundColor = [UIColor clearColor];
        _userAvatarView.userInteractionEnabled = YES;
        [self addSubview:_userAvatarView];
        
        _userName = [[UITextField alloc] init];
        _userName.userInteractionEnabled = NO;
        _userName.backgroundColor = [UIColor clearColor];
        _userName.textColor = [UIColor blackColor];
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
    CGFloat avatarWidth = (f.size.width / 3.5) - 5;
    CGFloat avatarHeight = f.size.height - 10;
    _userAvatarView.frame = CGRectMake(5, 5, avatarWidth, avatarHeight);
    _userName.frame = CGRectMake(avatarWidth + 10, f.size.height / 4, f.size.width - avatarWidth - 30, f.size.height / 2);
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

- (void)cacheComplete:(NSData *)cache
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *a = [UIImage imageWithData:cache];
        _userAvatarView.image = a;
        self.cache.delegate = nil;
        self.cache = nil;
    });
}

@end
