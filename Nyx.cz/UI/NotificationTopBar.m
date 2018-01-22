//
//  NotificationTopBar.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "NotificationTopBar.h"
#import "Colors.h"


@implementation NotificationTopBar

#pragma mark - INIT

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        isDismissing = NO;
        
        int screenWidth = [UIScreen mainScreen].bounds.size.width;
        int horizontalPadding = 20;
        int verticalPadding = 20;
        int spacing = 5;
        int titleHeight = 28;
        int messageHeight = 21;
        
        _title = CGRectMake(horizontalPadding, verticalPadding, screenWidth - (2 * horizontalPadding), titleHeight);
        _message = CGRectMake(horizontalPadding, verticalPadding + titleHeight + spacing, screenWidth - (2 * horizontalPadding), messageHeight);
        
        _height = (2 * verticalPadding) + spacing + titleHeight + messageHeight + 5;
        _visible = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _height);
        _hidden = CGRectMake(0, -_height, [UIScreen mainScreen].bounds.size.width, _height);
        
        self.frame = _hidden;
    }
    return self;
}

- (void)dealloc
{
    //    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"DEALLOC");
}


#pragma mark - SHOW NOTIFICATION

- (void)showNotificationWithBackgroundColor:(UIColor *)c
{
    self.backgroundColor = c;
    
    [self addSubview:[self createLabel]];
    [self addSubview:[self createMessage]];
    [self addSubview:[self createCloseInfo]];
    [self addGestureRecognizer:[self tap]];
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0.95;
        self.frame = _visible;
    } completion:^(BOOL finished) {
        [self startDismissTimer];
    }];
}


#pragma mark - LABEL and MESSAGE
#pragma mark

- (UILabel *)createLabel
{
    UILabel *notificationView = [[UILabel alloc] initWithFrame:_title];
    notificationView.backgroundColor = COLOR_CLEAR;
    notificationView.textColor = COLOR_TEXT_ALERT_BAR;
    notificationView.font = [UIFont systemFontOfSize:24];
    notificationView.textAlignment = NSTextAlignmentLeft;
    notificationView.adjustsFontSizeToFitWidth = YES;
    notificationView.numberOfLines = 1;
    notificationView.minimumScaleFactor = 0.8;
    notificationView.text = self.notificationTitle;
    return notificationView;
}

- (UILabel *)createMessage
{
    UILabel *notificationView = [[UILabel alloc] initWithFrame:_message];
    notificationView.backgroundColor = COLOR_CLEAR;
    notificationView.textColor = COLOR_TEXT_ALERT_BAR;
    notificationView.font = [UIFont systemFontOfSize:16];
    notificationView.textAlignment = NSTextAlignmentLeft;
    notificationView.adjustsFontSizeToFitWidth = YES;
    notificationView.numberOfLines = 1;
    notificationView.minimumScaleFactor = 0.8;
    notificationView.text = self.notificationMessage;
    return notificationView;
}

- (UILabel *)createCloseInfo
{
    int width = 150;
    int viewWidth = self.frame.size.width;
    CGRect _closeInfo = CGRectMake(viewWidth - width - 10, _height - 25, width, 20);
    UILabel *notificationView = [[UILabel alloc] initWithFrame:_closeInfo];
    notificationView.backgroundColor = COLOR_CLEAR;
    notificationView.textColor = COLOR_TEXT_ALERT_BAR;
    notificationView.font = [UIFont systemFontOfSize:12];
    notificationView.textAlignment = NSTextAlignmentRight;
    notificationView.adjustsFontSizeToFitWidth = YES;
    notificationView.numberOfLines = 1;
    notificationView.minimumScaleFactor = 0.8;
    notificationView.text = @"Tap to close.";
    return notificationView;
}

#pragma mark - DISMISS

- (void)startDismissTimer
{
    self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                         target:self
                                                       selector:@selector(dismissNotificationAnimation:)
                                                       userInfo:nil
                                                        repeats:NO
                         ];
}

- (void)dismissNotificationAnimation:(UITapGestureRecognizer *)gesture
{
    [self.dismissTimer invalidate];
    self.dismissTimer = nil;
    
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 0;
        self.frame = _hidden;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark - TAP/PAN GESTURES

- (UITapGestureRecognizer *)tap
{
    return [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissNotificationAnimation:)];
}

@end
