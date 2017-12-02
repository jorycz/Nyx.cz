//
//  SideMenuCell.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "SideMenuCell.h"
#import "Preferences.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>


@implementation SideMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont boldSystemFontOfSize:20];
        
        _alert = [[UILabel alloc] initWithFrame:CGRectZero];
        _alert.userInteractionEnabled = NO;
        _alert.backgroundColor = [UIColor redColor];
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


#pragma mark - NEW MAIL ALERT

- (void)showNewMailAlert:(BOOL)show
{
    if (show) {
        _alert.frame = CGRectMake(0, 0, 7, self.frame.size.height);
    } else {
        _alert.frame = CGRectMake(0, 0, 0, self.frame.size.height);
    }
}

- (void)showNewNotificationsAlert:(BOOL)show
{
    if (show) {
        _alert.frame = CGRectMake(0, 0, 7, self.frame.size.height);
    } else {
        _alert.frame = CGRectMake(0, 0, 0, self.frame.size.height);
    }
}


@end
