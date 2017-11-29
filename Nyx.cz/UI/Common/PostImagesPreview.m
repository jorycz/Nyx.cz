//
//  PostImagesPreview.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 27/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "PostImagesPreview.h"

@interface PostImagesPreview ()

@end

@implementation PostImagesPreview

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
    
    UIScrollView *pageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    pageScrollView.opaque = NO;
    pageScrollView.clipsToBounds = NO;
    pageScrollView.pagingEnabled = YES;
    pageScrollView.frame = CGRectMake(0, 80, viewWidth, viewHeight - 80);
    pageScrollView.showsHorizontalScrollIndicator = NO;
    pageScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:pageScrollView];
    
    
    for(NSInteger i = 0; i < [self.images count]; i++)
    {
        UIImageView *view = [[UIImageView alloc] init];
        view.tag = i;
        view.userInteractionEnabled = NO;
        view.contentMode = UIViewContentModeScaleAspectFit;
        view.backgroundColor = [UIColor clearColor];
        if (self.images && [self.images count] > 0)
            view.image = [self.images objectAtIndex:i];
        view.frame = CGRectMake(0 + (i * viewWidth), 0, pageScrollView.frame.size.width, pageScrollView.frame.size.height);
        [pageScrollView addSubview:view];
        
        // If SHOW IMAGES INLINE in the HTML is ENABLED, no images download is needed and this array is empty.
        // No http can be found inside HTML body, because all images are downloaded as NSTextAttachments in ComputeRowHeight class.
        if (self.imageUrls && [self.imageUrls count] > 0)
        {
            self.title = [NSString stringWithFormat:@"%@ - Nahrávám ...", self.title];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *u = [self.imageUrls objectAtIndex:i];
                if (u && [[u absoluteString] length] > 0)
                {
                    NSData *d = [NSData dataWithContentsOfURL:u];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (d && [d length] > 0)
                        {
                            view.image = [[UIImage alloc] initWithData:d];
                            self.title = @"Obrázky";
                        } else {
                            NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"Malformed data. Can't create UIImage from that data.");
                        }
                    });
                } else {
                    NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"Malformed URL.");
                }
            });
        }
    }
    
    pageScrollView.contentSize = CGSizeMake(self.view.frame.size.width * [self.images count], pageScrollView.frame.size.height);
}

#pragma mark - DISMISS

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}


@end
