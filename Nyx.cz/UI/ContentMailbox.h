//
//  ContentMailbox.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 21/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContentTableWithPeople.h"
#import "ServerConnector.h"


@interface ContentMailbox : UIView <ServerConnectorDelegate>
{
    CGFloat _widthForTableCellBodyTextView;
    BOOL _firstInit;
    
    NSString *_serverIdentificationMailbox, *_serverIdentificationMailboxOlderMessages, *_serverIdentificationNewMessage;
}


@property (nonatomic , strong) UINavigationController *nController;
@property (nonatomic, strong) ContentTableWithPeople *table;


@end
