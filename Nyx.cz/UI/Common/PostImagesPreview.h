//
//  PostImagesPreview.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 27/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CacheManager.h"


@interface PostImagesPreview : UIViewController <UIScrollViewDelegate, CacheManagerDelegate>
{
    UIScrollView *_pageScrollView;
    NSInteger _actualViewTag;
    
    NSMutableArray *_toDownload;
    NSInteger _downloadTag;
}


@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSArray *imageUrls;

@property (nonatomic, strong) CacheManager *cm;


@end
