//
//  PostImagesPreview.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 27/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "PostImagesPreview.h"
#import "Preferences.h"
#import "Constants.h"


@interface PostImagesPreview ()

@end

@implementation PostImagesPreview

- (instancetype)init
{
    self = [super init];
    if (self) {
        _toDownload = [[NSMutableArray alloc] init];
        _downloadTag = 0;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Obrázky";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                           target:self
                                                                                           action:@selector(dismiss)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    
    _pageScrollView = [[UIScrollView alloc] init];
    _pageScrollView.opaque = NO;
    _pageScrollView.pagingEnabled = YES;
    _pageScrollView.frame = CGRectMake(0, kNavigationBarHeight + kStatusBarStandardHeight, viewWidth, viewHeight - (kNavigationBarHeight + kStatusBarStandardHeight));
    _pageScrollView.showsHorizontalScrollIndicator = NO;
    _pageScrollView.showsVerticalScrollIndicator = NO;
    _pageScrollView.delegate = self;
    [self.view addSubview:_pageScrollView];
    
    // CREATE VIEWS WITH TAG + 1 !!! (to avoid 0)
    NSInteger countOfViews = MAX([self.images count], [self.imageUrls count]);
    
    for (NSInteger index = 0; index < (countOfViews + 1); index++)
    {
        UIImageView *view = [self imgvWithTag:index + 1];
        view.frame = CGRectMake(0 + (index * viewWidth), 0, _pageScrollView.frame.size.width, _pageScrollView.frame.size.height);
        [_pageScrollView addSubview:view];
    }
    _pageScrollView.contentSize = CGSizeMake(self.view.frame.size.width * countOfViews, _pageScrollView.frame.size.height);
    
//    _pageScrollView.minimumZoomScale = 1.0;
//    _pageScrollView.maximumZoomScale = 1.4;
    
    // Place images if there are some in post body.
    if (self.images)
    {
        for (NSInteger i = 0; i < [self.images count]; i++)
        {
            if (self.images && [self.images count] > 0)
            {
                UIImageView *imgv = (UIImageView *)[_pageScrollView viewWithTag:i+1];
                if ([self.images count] > i)
                    imgv.image = [self.images objectAtIndex:i];
            }
        }
    }
    
    _actualViewTag = 1;
    
    // If there are only previews in post body, download full version if urls exists.
    if (self.imageUrls)
    {
        self.title = [NSString stringWithFormat:@"%@ - Nahrávám ...", self.title];
        [_toDownload addObjectsFromArray:self.imageUrls];
        [self downloadImages];
    }
}

#pragma mark - IMAGE VIEW

- (UIImageView *)imgvWithTag:(NSInteger)t
{
    UIImageView *view = [[UIImageView alloc] init];
    view.tag = t;
    view.userInteractionEnabled = NO;
    view.contentMode = UIViewContentModeScaleAspectFit;
    view.backgroundColor = [UIColor clearColor];
    return  view;
}

#pragma mark - DISMISS

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - CACHE

- (void)downloadImages
{
    _downloadTag += 1;
    NSURL *u;
    [self.imageUrls count] > (_downloadTag - 1) ? (u = [_toDownload firstObject]) : (u = nil) ;
    if (u && [[u absoluteString] length] > 0)
    {
//        NSLog(@"%@ - %@ : Downloading from URL [%@]", self, NSStringFromSelector(_cmd), [u absoluteString]);
//        NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), _toDownload);
        self.cm = [[CacheManager alloc] init];
        self.cm.delegate = self;
        self.cm.cacheTag = _downloadTag;
        [self.cm getImageFromUrl:u];
    } else {
        // Nothing to download.
        self.title = @"Obrázky";
    }
}

- (void)cacheComplete:(CacheManager *)cache
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"%@ - %@ : ------ [%li]", self, NSStringFromSelector(_cmd), (long)cache.cacheTag);
        NSData *d = cache.cacheData;
        if (d && [d length] > 0)
        {
            UIImageView *imgv = (UIImageView *)[_pageScrollView viewWithTag:cache.cacheTag];
            imgv.image = [[UIImage alloc] initWithData:d];
//            NSLog(@"%@ - %@ : ========== [%@]", self, NSStringFromSelector(_cmd), imgv);
        }
        [_toDownload removeObjectAtIndex:0];
        [self downloadImages];
    });
}

//#pragma mark - ZOOM
//
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return [_pageScrollView viewWithTag:_actualViewTag];
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    for (UIView *v in _pageScrollView.subviews) {
//        if ([v isKindOfClass:[UIImageView class]]) {
//            _actualViewTag = v.tag;
//        }
//    }
//}
//
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
//{
//    [scrollView setZoomScale:1.0 animated:YES];
//}

@end


