//
//  UserNotification.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "UserNotification.h"
#import "Constants.h"
#import "NotificationTopBar.h"

@implementation UserNotification

#pragma mark - INIT

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(processNotification:)
                                                     name:kNotificationShowError
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)processNotification:(id)sender
{
    if (![NSThread currentThread].isMainThread) {
        [self performSelectorOnMainThread:@selector(processNotification:) withObject:sender waitUntilDone:NO];
        return;
    }
    
    NSString *title = [[sender userInfo] objectForKey:@"title"];
    NSString *message = [[sender userInfo] objectForKey:@"error"];
    
    // CHECK if text is already showing ?
    // Here I can manage to NOT show notification twice in short time and so ....
    // TODO
    
    NotificationTopBar *nt = [[NotificationTopBar alloc] init];
    nt.notificationTitle = title;
    nt.notificationMessage = message;
    [nt showNotification];
}

@end
