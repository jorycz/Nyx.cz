//
//  NewFeedPostVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 21/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApiBuilder.h"
#import "ServerConnector.h"


@interface NewFeedPostVC : UIViewController <ServerConnectorDelegate>
{
    UITextView *_tv;
    UIButton *_button;
}


@end
