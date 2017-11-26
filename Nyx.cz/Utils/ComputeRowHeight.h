//
//  ComputeRowHeight.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 20/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ComputeRowHeight : NSObject


@property (nonatomic, assign) CGFloat heightForRow;
@property (nonatomic, strong) NSMutableAttributedString *attributedText;


- (instancetype)initWithText:(NSString *)text forWidth:(CGFloat)currentWidth minHeight:(CGFloat)minHeight inlineImages:(NSString *)inlineImages;


@end
