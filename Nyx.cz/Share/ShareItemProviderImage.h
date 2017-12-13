//
//  ShareItemProviderImage.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 13/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareItemProviderImage : UIActivityItemProvider <UIActivityItemSource>


@property (nonatomic, strong) NSURL *fileUrl;


- (id)initWithFileUrl:(NSURL *)fileUrl;


@end
