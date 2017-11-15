//
//  LoginScreenVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ServerConnector.h"
#import "TabController.h"

@interface LoginScreenVC : UIViewController <ServerConnectorDelegate>
{
    UIImageView *_logoView;
}

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic, strong) ServerConnector *sc;
@property (nonatomic, strong) TabController *tab;

@end
