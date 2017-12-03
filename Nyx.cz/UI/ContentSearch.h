//
//  ContentSearch.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 19/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentTableWithPeople.h"
#import "ServerConnector.h"


@interface ContentSearch : UIView <ServerConnectorDelegate>
{
    CGFloat _widthForTableCellBodyTextView;
    BOOL _firstInit;
    
    NSMutableString *_nickToSearch, *_textToSearch;
}


@property (nonatomic , strong) UINavigationController *nController;
@property (nonatomic, strong) ContentTableWithPeople *table;


@end
