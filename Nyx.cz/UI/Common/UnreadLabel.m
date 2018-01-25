//
//  UnreadLabel.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/01/2018.
//  Copyright © 2018 Josef Rysanek. All rights reserved.
//

#import "UnreadLabel.h"
#import "Colors.h"


@implementation UnreadLabel


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor themeColorMainBackgroundStyledElement];
        self.textColor = [UIColor themeColorMainBackgroundDefault];
        self.userInteractionEnabled = NO;
        self.numberOfLines = 1;
        self.textAlignment = NSTextAlignmentCenter;
        // Font size 12 = minimum.
        self.font = [UIFont boldSystemFontOfSize:16];
        self.layer.cornerRadius = 6;
        self.clipsToBounds = YES;
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    // With smaller font a small shift up is needed.
    NSInteger bottom = 0;
    NSInteger textLength = [self.text length];
    
    if (textLength == 2) {
        bottom += 0.5;
        self.font = [UIFont boldSystemFontOfSize:14];
    }
    if (textLength == 3) {
        bottom += 1;
        self.font = [UIFont boldSystemFontOfSize:12];
    }
    
    UIEdgeInsets insets = {0, 0, bottom, 0};
    
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}


@end
