//
//  ImageVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 06/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CacheManager.h"


@interface ImageVC : UIViewController <UIScrollViewDelegate>
{
    UIScrollView *_zoomView;
    UIImageView *_imageView;
    
    CGFloat _minimumZoomScale;
}


@property (assign, nonatomic) NSInteger index;
//@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSURL *url;


@property (nonatomic, strong) CacheManager *cm;


@end
