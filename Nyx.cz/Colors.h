//
//  Colors.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 06/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Colors : NSObject


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define COLOR_CLEAR [UIColor clearColor]

#define COLOR_SYSTEM_TURQUOISE UIColorFromRGB(0x3fbeb8)
#define COLOR_SYSTEM_TURQUOISE_LIGHT UIColorFromRGB(0xF5FFFF)

#define COLOR_RATING_POSITIVE UIColorFromRGB(0x15D600)
#define COLOR_RATING_NEGATIVE UIColorFromRGB(0xFF0000)
#define COLOR_MAIL_READ UIColorFromRGB(0xF0F0F0)

#define COLOR_BACKGROUND_WHITE UIColorFromRGB(0xFFFFFF)
#define COLOR_BACKGROUND_ALERT_BAR UIColorFromRGB(0xFF0000)
#define COLOR_BACKGROUND_COVERVIEW UIColorFromRGB(0x000000)
#define COLOR_BACKGROUND_RESPOND_VIEW UIColorFromRGB(0xF2F2F2)
#define COLOR_BACKGROUND_NOTIFICATION_CIRCLE_SIDE_MENU COLOR_BACKGROUND_ALERT_BAR
#define COLOR_TEXT_BLACK UIColorFromRGB(0x000000)

#define COLOR_TEXT_ALERT_BAR UIColorFromRGB(0x000000)
#define COLOR_TIMELABEL UIColorFromRGB(0xa8a8a8)
#define COLOR_URL UIColorFromRGB(0x0000FF)
#define COLOR_PAGE_INDICATOR COLOR_BACKGROUND_WHITE
#define COLOR_SIDE_MENU_BORDER_LINES COLOR_TIMELABEL
#define COLOR_TEXT_NOTIFICATION_CIRCLE_SIDE_MENU COLOR_TEXT_ALERT_BAR
#define COLOR_SIDE_MENU_ITEM_TEXT UIColorFromRGB(0x7e7e7e)


@end
