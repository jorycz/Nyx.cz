//
//  BackgroundDownloader.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 23/12/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ServerConnector.h"
#import "JSONParser.h"
#import "ApiBuilder.h"


@interface BackgroundDownloader : NSObject <ServerConnectorDelegate>
{
    NSString *_identificationDataRefresh;
}


- (void)getNewData;


@end
