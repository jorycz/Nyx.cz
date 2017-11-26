//
//  SettingsVCCell.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 26/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "SettingsVCCell.h"
#import "Constants.h"


@implementation SettingsVCCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.settingsSwitch)
    {
        self.settingsSwitch.tintColor = [UIColor lightGrayColor];
        self.settingsSwitch.onTintColor = COLOR_SYSTEM_TURQUOISE;
        CGRect f = self.frame;
        CGRect sf = self.settingsSwitch.frame;
        [self addSubview:self.settingsSwitch];
        self.settingsSwitch.frame = CGRectMake(f.size.width - sf.size.width - 15, (f.size.height / 2) - (sf.size.height / 2) , 0, 0);
    }
}


@end
