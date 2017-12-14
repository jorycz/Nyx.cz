//
//  RichTextProcessor.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 14/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "RichTextProcessor.h"

@implementation RichTextProcessor

#pragma mark - ATTRIBUTED TEXT BODY PARSING and REPLACE - INIT

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

#pragma mark - IMAGE INSIDE BODY

// Detect images inside attributed text and place them in array. NOT USED.
- (NSArray *)detectImageAttachmentsInsideAttribudetText:(NSAttributedString *)attrText
{
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    [attrText enumerateAttribute:NSAttachmentAttributeName
                         inRange:NSMakeRange(0, [attrText length])
                         options:0
                      usingBlock:^(id value, NSRange range, BOOL *stop)
     {
         if ([value isKindOfClass:[NSTextAttachment class]])
         {
             NSTextAttachment *attachment = (NSTextAttachment *)value;
             UIImage *image = nil;
             if ([attachment image])
             {
                 image = [attachment image];
             }
             else
             {
                 image = [attachment imageForBounds:[attachment bounds]
                                      textContainer:nil
                                     characterIndex:range.location];
             }
             if (image)
                 [imagesArray addObject:image];
         }
     }];
    return imagesArray;
}

#pragma mark - URL PROCESSING

- (NSMutableArray *)getAllURLsFromAttributedAndSourceText:(NSAttributedString *)attrText withHtmlSource:(NSString *)htmlSource
{
    NSMutableArray *detectedUrls = [[NSMutableArray alloc] init];
    
    // First - detect properly configured URLs. Like with <a ...> tags.
    [attrText enumerateAttributesInRange:NSMakeRange(0, attrText.length)
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
                                  if ([attrs objectForKey:@"NSLink"]) {
                                      NSURL *url = [attrs objectForKey:@"NSLink"];
                                      //                                      NSLog(@"%@ - %@ Detected URL as NSLink : [%@]", self, NSStringFromSelector(_cmd), url);
                                      [detectedUrls addObject:url];
                                  }
                              }];
    
    // Second - there could be URLs in text just in plain text - like https://
    NSArray *words = [[attrText string] componentsSeparatedByString:@" "];
    for (NSString *component in words) {
        if ([component hasPrefix:@"http"]) {
            //            NSLog(@"%@ - %@ Detected URL as TEXT : [%@]", self, NSStringFromSelector(_cmd), component);
            // If there is new line at the end of the string - NSURL is nil.
            NSURL *u = [NSURL URLWithString:[component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            if (u)
                [detectedUrls addObject:u];
        }
    }
    
    if (htmlSource && [htmlSource length] > 0)
    {
        NSArray *a = [htmlSource componentsSeparatedByString:@"\""];
        for (NSString *u in a) {
            if ([u hasPrefix:@"http"]) {
                NSURL *url = [NSURL URLWithString:u];
                if (url) {
                    [detectedUrls addObject:url];
                }
            }
        }
    }
    
    // REMOVE "thumbs"
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    for (NSURL *s in detectedUrls) {
        if (![[[s absoluteString] lowercaseString] containsString:@"thumb"]) {
            [tmp addObject:s];
        }
    }
    
    return tmp;
}

- (NSArray *)urlsWithoutImages:(NSArray *)detectedUrl
{
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for (NSURL *u in detectedUrl) {
        if ([[[u absoluteString] lowercaseString] containsString:@".jpeg"] ||
            [[[u absoluteString] lowercaseString] containsString:@".jpg"] ||
            [[[u absoluteString] lowercaseString] containsString:@".png"])
        {
            continue;
        }
        if (![a containsObject:u])
        {
            [a addObject:u];
        }
    }
    return (NSArray *)a;
}

- (NSArray *)urlsWithImagesOnly:(NSArray *)detectedUrl
{
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for (NSURL *u in detectedUrl) {
        if ([[[u absoluteString] lowercaseString] containsString:@".jpeg"] ||
            [[[u absoluteString] lowercaseString] containsString:@".jpg"] ||
            [[[u absoluteString] lowercaseString] containsString:@".png"])
        {
            if (![a containsObject:u]) {
                [a addObject:u];
            }
        }
    }
    return (NSArray *)a;
}

- (NSArray *)getHttpOnlyUrls:(NSArray *)allUrls
{
    NSMutableArray *urls = [NSMutableArray array];
    for (NSURL *url in allUrls) {
        if ([[url absoluteString] hasPrefix:@"http"])
        {
            [urls addObject:url];
        }
    }
    return (NSArray *)urls;
}

- (NSArray *)getRelativeOnlyUrls:(NSArray *)allUrls
{
    NSMutableArray *urls = [NSMutableArray array];
    for (NSURL *url in allUrls) {
        if ([[url absoluteString] hasPrefix:@"applewebdata"])
        {
            [urls addObject:[url query]];
        }
    }
    return (NSArray *)urls;
}

#pragma mark - REPLACING

- (NSAttributedString *)replaceRelativeNyxUrlsInsidePostWithAbsoluteUrls:(NSAttributedString *)attrText
{
    NSMutableAttributedString *newSource = [[NSMutableAttributedString alloc] initWithAttributedString:attrText];
    
    [newSource enumerateAttributesInRange:NSMakeRange(0, newSource.length)
                                  options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                               usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
                                   
                                   if ([attrs objectForKey:@"NSLink"])
                                   {
                                       NSURL *url = [attrs objectForKey:@"NSLink"];
                                       NSString *urlStr = [url absoluteString];
                                       if ([urlStr hasPrefix:@"applewebdata"])
                                       {
                                           // Replace NSLinkAttributeName
                                           NSRange rangeToReplace = [urlStr rangeOfString:@"?"];
                                           NSString *absoluteUrl = [urlStr substringFromIndex:rangeToReplace.location];
                                           NSString *finalUrl = [NSString stringWithFormat:@"https://www.nyx.cz/index.php%@", absoluteUrl];
                                           [newSource addAttribute:NSLinkAttributeName value:[NSURL URLWithString:finalUrl] range:range];
                                       }
                                   }
                               }];
    
    return (NSAttributedString *)newSource;
}

@end


