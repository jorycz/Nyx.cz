//
//  ImagePreviewVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 06/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ImagePreviewVC.h"
#import "Constants.h"
#import "Colors.h"


@interface ImagePreviewVC ()

@end

@implementation ImagePreviewVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrameForCurrentStatusBar) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = COLOR_BACKGROUND_WHITE;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Obrázky";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                           target:self
                                                                                           action:@selector(dismiss)];
    
    _imagesCount = [self.imageUrls count];
    
    // PAGE VIEW CONTROLLER SETUP
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    ImageVC *initialViewController = [self viewControllerAtIndex:0];
    initialViewController.index = 0;
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    UIPageControl *pc = [UIPageControl appearanceWhenContainedInInstancesOfClasses:@[[ImagePreviewVC class]]];
    pc.pageIndicatorTintColor = COLOR_PAGE_INDICATOR;
    pc.currentPageIndicatorTintColor = COLOR_SYSTEM_TURQUOISE;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self adjustFrameForCurrentStatusBar];
}

- (void)adjustFrameForCurrentStatusBar
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect f = self.view.bounds;
        self.pageController.view.frame = CGRectMake(0, kNavigationBarHeight + kStatusBarStandardHeight, f.size.width, f.size.height - (kNavigationBarHeight + kStatusBarStandardHeight));
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - PAGEVIEW CONTROLLER

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [(ImageVC *)viewController index];
    if (index == 0) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [(ImageVC *)viewController index];
    index++;
    if (index > (_imagesCount - 1)) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (ImageVC *)viewControllerAtIndex:(NSUInteger)index
{
    ImageVC *childViewController = [[ImageVC alloc] init];
    childViewController.index = index;
//    childViewController.image = [self.images count] > index ? [self.images objectAtIndex:index] : @"" ;
    childViewController.url = [self.imageUrls count] > index ? [self.imageUrls objectAtIndex:index] : @"" ;
    
    return childViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return _imagesCount;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


@end
