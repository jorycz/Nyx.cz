//
//  RichTextProcessor.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 14/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ComputeRowHeight.h"


@interface RichTextProcessor : NSObject


// Detect images inside attributed text and place them in array. NOT USED.
- (NSArray *)detectImageAttachmentsInsideAttribudetText:(NSAttributedString *)attrText;

- (NSMutableArray *)getAllURLsFromAttributedAndSourceText:(NSAttributedString *)attrText withHtmlSource:(NSString *)htmlSource;
- (NSArray *)urlsWithoutImages:(NSArray *)detectedUrl;
- (NSArray *)urlsWithImagesOnly:(NSArray *)detectedUrl;
- (NSArray *)getHttpOnlyUrls:(NSArray *)allUrls;
- (NSArray *)getRelativeOnlyUrls:(NSArray *)allUrls;

- (NSAttributedString *)replaceRelativeNyxUrlsInsidePostWithAbsoluteUrls:(NSAttributedString *)attrText;


@end
