//
//  UIColor+Theme.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 25/01/2018.
//  Copyright © 2018 Josef Rysanek. All rights reserved.
//

#import "UIColor+Theme.h"
#import "Preferences.h"
#import "Constants.h"


@implementation UIColor (Theme)


+ (BOOL)dark
{
    if ([[Preferences theme:nil] isEqualToString:kThemeDark])
        return YES;
    return NO;
}


// BACKGROUNDS

+ (UIColor *)themeColorClear
{
    return [UIColor clearColor];
}

+ (UIColor *)themeColorMainBackgroundDefault
{
    if ([self dark])
        return UIColorFromRGB(0x000000);
    return UIColorFromRGB(0xFFFFFF);
}

+ (UIColor *)themeColorMainBackgroundStyledElement
{
    return UIColorFromRGB(0x3fbeb8);
}

+ (UIColor *)themeColorMainBackgroundUnreadHilight
{
    if ([self dark])
        return UIColorFromRGB(0x364040);
    return UIColorFromRGB(0xEBFFFF);
}

+ (UIColor *)themeColorBackgroundEmailSeen
{
    if ([self dark])
        return UIColorFromRGB(0x383838);
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

+ (UIColor *)themeColorBackgroundMainContentCoverView
{
    if ([self dark])
        return UIColorFromRGB(0xFFFFFF);
    return UIColorFromRGB(0x000000);
}

+ (UIColor *)themeColorBackgroundRespondElement
{
    if ([self dark])
        return UIColorFromRGB(0x4A4A4A);
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

+ (UIColor *)themeColorBackgroundLoadingView
{
    if ([self dark])
        return [UIColor colorWithWhite:0.1 alpha:.9];
    return  [UIColor colorWithWhite:1 alpha:.9];
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
    if ([self dark])
        return UIColorFromRGB(0xFFFFFF);
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
    if ([self dark])
        return UIColorFromRGB(0x5252FF);
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

