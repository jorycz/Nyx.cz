//
//  UIColor+Theme.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 25/01/2018.
//  Copyright © 2018 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface UIColor (Theme)


// BACKGROUNDS

+ (UIColor *)themeColorClear;
+ (UIColor *)themeColorMainBackgroundDefault;
+ (UIColor *)themeColorMainBackgroundStyledElement;
+ (UIColor *)themeColorMainBackgroundUnreadHilight;
+ (UIColor *)themeColorBackgroundEmailSeen;
+ (UIColor *)themeColorBackgroundAlert;
+ (UIColor *)themeColorBackgroundInfo;
+ (UIColor *)themeColorBackgroundLoadingCoverView;
+ (UIColor *)themeColorBackgroundRespondElement;
+ (UIColor *)themeColorBackgroundCircleAttention;
+ (UIColor *)themeColorBackgroundSideMenuTopBottomBorderLines;

// FOREGROUNDS

+ (UIColor *)themeColorRatingPositive;
+ (UIColor *)themeColorRatingNegative;
+ (UIColor *)themeColorStandardText;
+ (UIColor *)themeColorAlertText;
+ (UIColor *)themeColorTimestampText;
+ (UIColor *)themeColorURL;
+ (UIColor *)themeColorPageIndicatorInactive;
+ (UIColor *)themeColorPageIndicatorActive;
+ (UIColor *)themeColorTextCircleAttention;
+ (UIColor *)themeColorTextSideMenuCell;


@end
