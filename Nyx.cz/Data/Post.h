//
//  Post.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Post : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *nick;
@property (nonatomic, strong) NSString *body;

@end
