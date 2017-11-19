//
//  LoginScreenVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ServerConnector.h"

@interface LoginScreenVC : UIViewController <ServerConnectorDelegate>
{
    UIImageView *_logoView;
    NSInteger _baseX, _baseY, _fWidth, _fHeight;
}

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) ServerConnector *sc;
@property (nonatomic, assign) BOOL userIsLoggedIn;


@end
