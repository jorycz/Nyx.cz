//
//  ShareItemProviderText.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 13/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareItemProviderText : UIActivityItemProvider <UIActivityItemSource>


@property (nonatomic, strong) NSString *actTitle;
@property (nonatomic, strong) NSString *actBody;
@property (nonatomic, strong) NSAttributedString *actBodyAttributed;
@property (nonatomic, strong) NSArray *actUrls;


- (id)initWithTitle:(NSString *)title andBody:(NSString *)body andBodyAttributed:(NSAttributedString *)bodyAttributed andUrls:(NSArray *)urls;


@end
