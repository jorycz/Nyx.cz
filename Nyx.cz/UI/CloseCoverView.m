//
//  CloseCoverView.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "CloseCoverView.h"
#import "Colors.h"


@implementation CloseCoverView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor themeColorBackgroundLoadingCoverView];
        self.alpha = 0.01;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)viewTapped
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(coverViewWouldLikeToCloseMenu)]) {
        [self.delegate performSelector:@selector(coverViewWouldLikeToCloseMenu)];
    } else {
        NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"Missing delegate.");
    }
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 0.01;
    }];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 0.4;
    }];
}

@end
