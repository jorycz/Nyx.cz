//
//  ShareItemProviderText.m
//  Nyx.cz
//
//  Created by Josef Rysanek on 13/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import "ShareItemProviderText.h"

@implementation ShareItemProviderText 


#pragma mark - INIT

- (id)initWithTitle:(NSString *)title andBody:(NSString *)body andBodyAttributed:(NSAttributedString *)bodyAttributed andUrls:(NSArray *)urls
{
    if (self = [super initWithPlaceholderItem:title])
    {
        self.actTitle = [[NSString alloc] initWithString:title];
        self.actBody = [[NSString alloc] initWithString:body];
        self.actBodyAttributed = [[NSAttributedString alloc] initWithAttributedString:bodyAttributed];
        self.actUrls = [[NSArray alloc] initWithArray:urls];
    }
    return self;
}



#pragma mark - UIActivityItemSource

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if (activityType == UIActivityTypeSaveToCameraRoll)
    {
        return nil;
    }

    if (activityType == UIActivityTypePostToTwitter ||
        activityType == UIActivityTypePostToFacebook ||
        activityType == UIActivityTypeCopyToPasteboard ||
        activityType == UIActivityTypeMail)
    {
        return self.actBodyAttributed;
    }
    else
    {
        NSMutableString *forNonRichSharing = [[NSMutableString alloc] init];
        [forNonRichSharing appendString:self.actTitle];
        [forNonRichSharing appendString:@"\n"];
        [forNonRichSharing appendString:[self.actBodyAttributed string]];
        [forNonRichSharing appendString:@"\n"];
        
        for (NSURL *u in self.actUrls)
        {
            if (![forNonRichSharing containsString:[u absoluteString]])
            {
                [forNonRichSharing appendString:[NSString stringWithFormat:@"%@\n", [u absoluteString]]];
            }
        }
        
        return forNonRichSharing;
    }
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    // In case of mail and actitivy "subject type" kind of messages
    return @"Zpráva z aplikace nyx.cz pro iOS.";
}


@end
