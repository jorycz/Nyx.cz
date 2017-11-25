//
//  ComputeRowHeight.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 20/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ComputeRowHeight.h"
#import "Constants.h"
#import <UIKit/UIKit.h>


@implementation ComputeRowHeight

- (instancetype)initWithText:(NSString *)text forWidth:(CGFloat)currentWidth andWithMinHeight:(CGFloat)minHeight
{
    self = [super init];
    if (self)
    {
        NSData *textData = [text dataUsingEncoding:(NSUTF8StringEncoding)];
        
        BOOL _useAppleHTMLParsing = YES;
        
        if (_useAppleHTMLParsing)
        {
//            PERFSTART
            // HACK !!!
            // that magical 10 si 2 * textView.textContainer.lineFragmentPadding
            // read more https://stackoverflow.com/questions/13621084/boundingrectwithsize-for-nsattributedstring-returning-wrong-size
            currentWidth -= 10;
            
            NSError *error = nil;
            self.attributedText = [[NSMutableAttributedString alloc] initWithData:textData options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                                     NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                               documentAttributes:nil
                                                                            error:&error];
            if (error) {
                NSLog(@"%@ - %@ ERROR : [%@]", self, NSStringFromSelector(_cmd), [error localizedDescription]);
            }
//            PERFSTOP
        }
        else
        {
            
        }
        
        // Count size
        // Replace FONT inside HTML string.
        UIFont *font = [UIFont systemFontOfSize:14];
        UIFontDescriptor *baseDescriptor = font.fontDescriptor;
        BOOL bPreserveSize = YES;
        
        [self.attributedText enumerateAttribute:NSFontAttributeName
                                        inRange:NSMakeRange(0, [self.attributedText length])
                                        options:0
                                     usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop)
         {
             UIFont *font = (UIFont*)value;
             UIFontDescriptorSymbolicTraits traits = font.fontDescriptor.symbolicTraits;
             UIFontDescriptor *descriptor = [baseDescriptor fontDescriptorWithSymbolicTraits:traits];
             UIFont *newFont = [UIFont fontWithDescriptor:descriptor size:bPreserveSize?baseDescriptor.pointSize:descriptor.pointSize];
             [self.attributedText removeAttribute:NSFontAttributeName range:range];
             [self.attributedText addAttribute:NSFontAttributeName value:newFont range:range];
         }];
        
        CGSize constraintSize = CGSizeMake(currentWidth, MAXFLOAT);
        CGRect rect = [self.attributedText boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
        CGFloat finalHeight = rect.size.height < minHeight ? minHeight : rect.size.height;
        self.heightForRow = finalHeight;
    }
    return self;
}

@end
