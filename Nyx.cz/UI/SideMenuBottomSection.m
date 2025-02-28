//
//  SideMenuBottomSection.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "SideMenuBottomSection.h"
#import "Preferences.h"
#import "Constants.h"
#import "Colors.h"


@implementation SideMenuBottomSection

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor themeColorMainBackgroundDefault];
        
        // https://www.iconfinder.com/iconsets/glyphs
        _logoutButton = [[UIButton alloc] init];
        [_logoutButton setImage:[UIImage imageNamed:@"logout"] forState:(UIControlStateNormal)];
        [_logoutButton addTarget:self action:@selector(openLogout) forControlEvents:(UIControlEventTouchUpInside)];
        _logoutButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_logoutButton];
        
        _contactButton = [[UIButton alloc] init];
        [_contactButton setImage:[UIImage imageNamed:@"contact"] forState:(UIControlStateNormal)];
        [_contactButton addTarget:self action:@selector(openContact) forControlEvents:(UIControlEventTouchUpInside)];
        _contactButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_contactButton];
        
        _settingsButton = [[UIButton alloc] init];
        [_settingsButton setImage:[UIImage imageNamed:@"settings"] forState:(UIControlStateNormal)];
        [_settingsButton addTarget:self action:@selector(openSettings) forControlEvents:(UIControlEventTouchUpInside)];
        _settingsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_settingsButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect f = self.frame;
    CGFloat shift = self.frame.size.height * 0.3;
    CGFloat height = (f.size.height - (2 * shift));
    CGFloat oneThird = self.frame.size.width / 3;
    
    _logoutButton.frame = CGRectMake(0, shift, oneThird, height);
    _contactButton.frame = CGRectMake(oneThird, shift, oneThird, height);
    _settingsButton.frame = CGRectMake(2 * oneThird, shift, oneThird, height);
}

- (void)openSettings
{
    NOTIFICATION_MAIN_BUTTON_PRESSED(kMainButtonSettings)
}

- (void)openContact
{
    NOTIFICATION_MAIN_BUTTON_PRESSED(kMainButtonContact)
}

- (void)openLogout
{
    NOTIFICATION_MAIN_BUTTON_PRESSED(kMainButtonLogout)
}

@end
