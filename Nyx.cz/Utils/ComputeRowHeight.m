//
//  ComputeRowHeight.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 20/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ComputeRowHeight.h"
#import "Constants.h"
#import "Preferences.h"
#import "ComputeRowHeightTextAttachment.h"


@implementation ComputeRowHeight

- (instancetype)initWithText:(NSString *)text forWidth:(CGFloat)currentWidth minHeight:(CGFloat)minHeight inlineImages:(NSString *)inlineImages
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
        
        if (inlineImages && [inlineImages length] > 0)
        {
//            NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"-- Replacing URL link with attachments itself.");
            [self replaceLinkWithAttachments];
        } else {
//            NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), @"-- Keeping URL link in HTML.");
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
             if (newFont) {
                 [self.attributedText removeAttribute:NSFontAttributeName range:range];
                 [self.attributedText addAttribute:NSFontAttributeName value:newFont range:range];
             }
         }];
        
        CGSize constraintSize = CGSizeMake(currentWidth, MAXFLOAT);
        CGRect rect = [self.attributedText boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
        CGFloat finalHeight = rect.size.height < minHeight ? minHeight : rect.size.height;
        self.heightForRow = finalHeight;
    }
    return self;
}

#pragma mark - ATTACHMENTS

- (void)replaceLinkWithAttachments
{
//    NSLog(@"%@ - %@ : [%@]", self, NSStringFromSelector(_cmd), self.attributedText);
    
    // Detect properly configured URLs. Like with <a ...> <img ...> and so tags.
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, self.attributedText.length)
                                            options:NSAttributedStringEnumerationReverse
                                         usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        if ([attrs objectForKey:@"NSLink"]) {
            NSURL *url = [attrs objectForKey:@"NSLink"];
            NSString *urlStr = [url absoluteString];
//            NSLog(@"%@ - %@ Detected URL as NSLink : [%@]", self, NSStringFromSelector(_cmd), url);
            if ([urlStr hasPrefix:@"http"]) {
                if ([[urlStr lowercaseString] hasSuffix:@"jpeg"] ||
                    [[urlStr lowercaseString] hasSuffix:@"jpg"] ||
                    [[urlStr lowercaseString] hasSuffix:@"png"])
                {
                    UIImage *inlineImage = [self getImageForUrl:url];
                    if (inlineImage)
                    {
                        ComputeRowHeightTextAttachment *textAttachment = [[ComputeRowHeightTextAttachment alloc] init];
                        textAttachment.image = inlineImage;
                        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                        [self.attributedText replaceCharactersInRange:range withAttributedString:attrStringWithImage];
                    }
                }
            }
        }
    }];
}

- (UIImage *)getImageForUrl:(NSURL *)url
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data && [data length] > 0) {
        UIImage *i = [[UIImage alloc] initWithData:data];
        if (i) {
            return i;
        }
        NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"Some data arrived but can't create UIImage from that!");
    }
    NSLog(@"%@ - %@ : ERROR [%@]", self, NSStringFromSelector(_cmd), @"No data!");
    return nil;
}


@end










