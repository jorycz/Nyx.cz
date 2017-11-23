//
//  PeopleAutocompleteVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 22/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerConnector.h"
#import "ApiBuilder.h"
#import "JSONParser.h"
#import "CacheManager.h"


@interface PeopleAutocompleteVC : UITableViewController <UITextFieldDelegate, CacheManagerDelegate, ServerConnectorDelegate>
{
    BOOL _firstInit, _loadingInProgress;
    UITableView *_table;
    UITextField *_searchField;
    UIView *_topView;
    CGSize _keyboardSize;
    CGRect _tableFrame;
    
    NSDictionary *_choosenUser;
}


@property (nonatomic, strong) NSMutableArray *autocompleteData;
@property (nonatomic, strong) NSMutableArray *nickAvatarsToDownload;
@property (nonatomic, strong) NSMutableDictionary *avatarImagesByNick;
@property (nonatomic, strong) NSMutableArray *sections;

@property (nonatomic, strong) CacheManager *cache;


@end
