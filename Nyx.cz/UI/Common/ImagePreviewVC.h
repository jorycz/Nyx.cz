//
//  ImagePreviewVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 06/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageVC.h"


@interface ImagePreviewVC : UIViewController <UIPageViewControllerDataSource>
{
    NSInteger _imagesCount;
    CGRect _mainScreen;
}


@property (strong, nonatomic) UIPageViewController *pageController;
//@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *imageUrls;

@property (nonatomic , strong) UINavigationController *nc;


@end
