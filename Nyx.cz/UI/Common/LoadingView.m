//
//  LoadingView.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "LoadingView.h"
#import "Constants.h"
#import "Colors.h"


@implementation LoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.tag = kLoadingCoverViewTag;
        self.backgroundColor = [UIColor themeColorBackgroundLoadingView];
        
//        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
//        [self addSubview:spinner];
//        [spinner startAnimating];
//        spinner.center = self.center;
        
        // Image animation
        NSArray *imageNames = @[@"0.png", @"1.png", @"2.png", @"3.png", @"4.png", @"5.png", @"6.png", @"7.png", @"8.png", @"9.png", @"10.png",
                            @"11.png", @"12.png", @"13.png", @"14.png", @"15.png", @"16.png", @"17.png", @"18.png", @"19.png", @"20.png", @"21.png"];
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (int i = 0; i < imageNames.count; i++) {
            [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
        }
        // Normal Animation
        UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        animationImageView.center = self.center;
        animationImageView.animationImages = images;
        animationImageView.animationDuration = 0.5;
        [self addSubview:animationImageView];
        [animationImageView startAnimating];
    }
    return self;
}

- (void)dealloc
{
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"");
}

@end
