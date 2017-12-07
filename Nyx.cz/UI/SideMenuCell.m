//
//  SideMenuCell.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "SideMenuCell.h"
#import "Preferences.h"
#import "Colors.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"


@implementation SideMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont boldSystemFontOfSize:20];
        
        _alert = [[UILabel alloc] initWithFrame:CGRectZero];
        _alert.userInteractionEnabled = NO;
        _alert.backgroundColor = [UIColor redColor];
        _alert.layer.cornerRadius = 15;
        _alert.clipsToBounds = YES;
        _alert.alpha = 0;
        _alert.textColor = [UIColor whiteColor];
        _alert.textAlignment = NSTextAlignmentCenter;
        _alert.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:_alert];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)updateMenuLabel:(NSString *)l
{
    self.textLabel.text = l;
    [self updateLabelColor];
}

- (void)updateLabelColor
{
    self.textLabel.textColor = [UIColor grayColor];
    if ([self.textLabel.text isEqualToString:[Preferences lastUserPosition:nil]]) {
        self.textLabel.textColor = COLOR_SYSTEM_TURQUOISE;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSInteger xPos = 0;
    if ([self.textLabel.text isEqualToString:kMenuMail])
        xPos = 81;
    if ([self.textLabel.text isEqualToString:kMenuNotifications])
        xPos = 137;
    _alert.frame = CGRectMake(xPos, 5, self.frame.size.height - 10, self.frame.size.height - 10);
}


#pragma mark - NEW NOTIFICATION ALERT

- (void)showNewNotificationAlert:(NSInteger)show
{
    if (show > 0) {
        _alert.text = show > 99 ? @"99" : [@(show) stringValue] ;
        [UIView animateWithDuration:.5 animations:^{
            _alert.alpha = .8;
        }];
    } else {
        [UIView animateWithDuration:.5 animations:^{
            _alert.alpha = 0;
            _alert.text = @"";
        }];
    }
}


@end
