//
//  ImageVC.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 06/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ImageVC.h"
#import "CacheManager.h"


@interface ImageVC ()

@end

@implementation ImageVC

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _zoomView = [[UIScrollView alloc] init];
    _zoomView.backgroundColor = [UIColor clearColor];
    _zoomView.showsHorizontalScrollIndicator = NO;
    _zoomView.showsVerticalScrollIndicator = NO;
    _zoomView.delegate = self;
    _zoomView.minimumZoomScale = 1.0;
    [self.view addSubview:_zoomView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_zoomView addSubview:_imageView];
    
    UITapGestureRecognizer *tapToZoom = [[UITapGestureRecognizer alloc] init];
    tapToZoom.numberOfTapsRequired = 2;
    [tapToZoom addTarget:self action:@selector(toggleZoom)];
    [_zoomView addGestureRecognizer:tapToZoom];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.url && [[self.url absoluteString] length] > 0)
    {
        self.cm = [[CacheManager alloc] init];
        self.cm.delegate = self;
        [self.cm getImageFromUrl:self.url];
    } else {
        self.title = @"Loading error!";
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - CACHE

- (void)cacheComplete:(CacheManager *)cache
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *d = cache.cacheData;
        if (d && [d length] > 0)
        {
            _imageView.image = [[UIImage alloc] initWithData:d];
            CGFloat maxWidth = _imageView.image.size.width / _zoomView.frame.size.width;
            CGFloat maxHeight = _imageView.image.size.height / _zoomView.frame.size.height;
            CGFloat max = fmax(maxWidth, maxHeight);
            
            _zoomView.maximumZoomScale = max;
            
            if (max < 1)
            {
                NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"Image is smaller than display. Zoom disabled.");
                _zoomView.userInteractionEnabled = NO;
                _imageView.alpha = .8;
            }
        }
    });
}

#pragma mark - LAYOUTS

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect f = self.view.bounds;
    _zoomView.frame = f;
    _imageView.frame = _zoomView.bounds;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)toggleZoom
{
    CGFloat scale = _zoomView.zoomScale;
    if (scale > 1)
    {
        [_zoomView setZoomScale:1 animated:YES];
    }
    else
    {
        [_zoomView setZoomScale:_zoomView.maximumZoomScale animated:YES];
    }
}


@end
