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
    
    // https://supereasyapps.com/blog/2014/3/21/screen-edge-swipe-gesture-on-iphone-using-the-uiscreenedgepangesturerecognizer-tutorial
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgeGesture:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;
    leftEdgeGesture.delegate = self;
    [leftEdgeGesture setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:leftEdgeGesture];
}

- (void)handleLeftEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture
{
    UIView *view = [self.view hitTest:[gesture locationInView:gesture.view] withEvent:nil];
    if(UIGestureRecognizerStateBegan == gesture.state || UIGestureRecognizerStateChanged == gesture.state)
    {
        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"TAM");
        CGPoint translation = [gesture translationInView:gesture.view];
        // Move the view's center using the gesture
        self.view.center = CGPointMake(_centerX + translation.x, view.center.y);
    } else {// cancel, fail, or ended
        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"ZPET");
        // Animate back to center x
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
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
