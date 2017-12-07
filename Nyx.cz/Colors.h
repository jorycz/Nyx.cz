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

#define COLOR_SYSTEM_TURQUOISE UIColorFromRGB(0x3fbeb8)
#define COLOR_SYSTEM_TURQUOISE_LIGHT UIColorFromRGB(0xE8F0FF)

#define COLOR_RATING_POSITIVE UIColorFromRGB(0x15D600)
#define COLOR_MAIL_READ UIColorFromRGB(0xF5F5F5)


@end
