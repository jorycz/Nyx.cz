//
//  ContentHistory.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContentTableWithList.h"
#import "ServerConnector.h"


@interface ContentHistory : UIView <ServerConnectorDelegate>
{
    BOOL _firstInit;
}


@property (nonatomic , strong) UINavigationController *nController;
@property (nonatomic, strong) ContentTableWithList *table;


@end
