//
//  ShareItemProviderImage.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 13/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ShareItemProviderImage.h"
#import "Preferences.h"


@implementation ShareItemProviderImage 


#pragma mark - INIT

- (id)initWithFileUrl:(NSURL *)fileUrl
{
    if (self = [super initWithPlaceholderItem:[[UIImage alloc] init]])
    {
        self.fileUrl = fileUrl;
    }
    return self;
}


#pragma mark - UIActivityItemSource

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
//    NSLog(@"%@ - %@ : IMAGE [%@]", self, NSStringFromSelector(_cmd), [self.fileUrl absoluteString]);
    if ([Preferences shareFullSizeImages:nil] && [[Preferences shareFullSizeImages:nil] length] > 0)
        return [NSData dataWithContentsOfURL:self.fileUrl];
    return nil;
//    return self.fileUrl;
}

- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(NSString *)activityType suggestedSize:(CGSize)size
{
//    UIImage *thumb = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:self.fileUrl]];
//    NSLog(@"%@ - %@ : IMAGE THUMB SIZE [%@]", self, NSStringFromSelector(_cmd), NSStringFromCGSize([thumb size]));
//    return thumb;
    return nil;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType
{
    return @"public.jpeg";
}


@end
