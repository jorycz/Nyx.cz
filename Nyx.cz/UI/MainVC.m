//
//  MainVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "MainVC.h"

@interface MainVC ()

@end

@implementation MainVC

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Move left to access Side menu.
    // https://supereasyapps.com/blog/2014/3/21/screen-edge-swipe-gesture-on-iphone-using-the-uiscreenedgepangesturerecognizer-tutorial
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgeGesture:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;
    leftEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:leftEdgeGesture];
}

- (void)handleLeftEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture
{
    UIView *view = [self.view hitTest:[gesture locationInView:gesture.view] withEvent:nil];
    if(UIGestureRecognizerStateBegan == gesture.state || UIGestureRecognizerStateChanged == gesture.state)
    {
        CGPoint translation = [gesture translationInView:gesture.view];
        self.view.center = CGPointMake(_centerX + translation.x, view.center.y);
    } else { // cancel, fail, or ended
        [UIView animateWithDuration:.3 animations:^{
            self.view.center = CGPointMake(_centerX, view.center.y);
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _centerX = self.view.bounds.size.width / 2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
