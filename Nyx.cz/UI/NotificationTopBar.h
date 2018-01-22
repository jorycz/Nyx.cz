//
//  NotificationTopBar.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTopBar : UIView
{
    CGRect _visible, _hidden, _title, _message;
    BOOL isDismissing;
    NSInteger _height;
}

@property (nonatomic, strong) NSString *notificationTitle;
@property (nonatomic, strong) NSString *notificationMessage;
@property (nonatomic, strong) NSTimer *dismissTimer;


- (void)showNotificationWithBackgroundColor:(UIColor *)c;


@end
