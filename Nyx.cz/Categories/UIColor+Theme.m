//
//  UIColor+Theme.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 25/01/2018.
//  Copyright © 2018 Josef Rysanek. All rights reserved.
//

#import "UIColor+Theme.h"

@implementation UIColor (Theme)

// BACKGROUNDS

+ (UIColor *)themeColorClear
{
    return [UIColor clearColor];
}

+ (UIColor *)themeColorMainBackgroundDefault
{
    return UIColorFromRGB(0xFFFFFF);
}

+ (UIColor *)themeColorMainBackgroundStyledElement
{
    return UIColorFromRGB(0x3fbeb8);
}

+ (UIColor *)themeColorMainBackgroundUnreadHilight
{
    return UIColorFromRGB(0xEBFFFF);
}

+ (UIColor *)themeColorBackgroundEmailSeen
{
    return UIColorFromRGB(0xF0F0F0);
}

+ (UIColor *)themeColorBackgroundAlert
{
    return UIColorFromRGB(0xFF0000);
}

+ (UIColor *)themeColorBackgroundInfo
{
    return UIColorFromRGB(0x287874);
}

+ (UIColor *)themeColorBackgroundLoadingCoverView
{
    return UIColorFromRGB(0x000000);
}

+ (UIColor *)themeColorBackgroundRespondElement
{
    return UIColorFromRGB(0xF2F2F2);
}

+ (UIColor *)themeColorBackgroundCircleAttention
{
    return UIColorFromRGB(0xFF0000);
}

+ (UIColor *)themeColorBackgroundSideMenuTopBottomBorderLines
{
    return [self themeColorTimestampText];
}

+ (UIColor *)themeColorBackgroundCellThumbUp
{
    return UIColorFromRGB(0x00EB08);
}

+ (UIColor *)themeColorBackgroundCellThumbDown
{
    return UIColorFromRGB(0xEB0000);
}

// FOREGROUNDS

+ (UIColor *)themeColorRatingPositive
{
    return UIColorFromRGB(0x15D600);
}

+ (UIColor *)themeColorRatingNegative
{
    return UIColorFromRGB(0xFF0000);
}

+ (UIColor *)themeColorStandardText
{
    return UIColorFromRGB(0x000000);
}

+ (UIColor *)themeColorAlertText
{
    return UIColorFromRGB(0xFFFFFF);
}

+ (UIColor *)themeColorTimestampText
{
    return UIColorFromRGB(0xa8a8a8);
}

+ (UIColor *)themeColorURL
{
    return UIColorFromRGB(0x0000FF);
}

+ (UIColor *)themeColorPageIndicatorInactive
{
    return [self themeColorTimestampText];
}

+ (UIColor *)themeColorPageIndicatorActive
{
    return [self themeColorMainBackgroundStyledElement];
}

+ (UIColor *)themeColorTextCircleAttention
{
    return [self themeColorAlertText];
}

+ (UIColor *)themeColorTextSideMenuCell
{
    return UIColorFromRGB(0x7e7e7e);
}

+ (UIColor *)themeColorSwitchTint
{
    return [self themeColorTimestampText];
}




@end

