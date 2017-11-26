//
//  ComputeRowHeightTextAttachment.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 26/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ComputeRowHeightTextAttachment.h"

@implementation ComputeRowHeightTextAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    CGFloat width = lineFrag.size.width;
    
    // Scale how you want
    float scalingFactor = 1.0;
    CGSize imageSize = [self.image size];
    if (width < imageSize.width)
        scalingFactor = width / imageSize.width;
    CGRect rect = CGRectMake(0, 0, imageSize.width * scalingFactor, imageSize.height * scalingFactor);
    
    return rect;
}

@end
