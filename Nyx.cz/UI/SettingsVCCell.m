//
//  SettingsVCCell.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 26/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "SettingsVCCell.h"
#import "Colors.h"


@implementation SettingsVCCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = COLOR_BACKGROUND_WHITE;
        
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
        [self addSubview:_separator];
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
    
    if (self.settingsSwitch)
    {
        self.settingsSwitch.tintColor = [UIColor lightGrayColor];
        self.settingsSwitch.onTintColor = COLOR_SYSTEM_TURQUOISE;
        CGRect f = self.frame;
        CGRect sf = self.settingsSwitch.frame;
        [self addSubview:self.settingsSwitch];
        self.settingsSwitch.frame = CGRectMake(f.size.width - sf.size.width - 15, (f.size.height / 2) - (sf.size.height / 2) , 0, 0);
    }
    
    CGRect f = self.frame;
    _separator.frame = CGRectMake(10, f.size.height - 1, f.size.width - 20, 1);
}


@end
