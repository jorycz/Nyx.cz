//
//  MainContentVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

#import "ContentTableWithPeople.h"
#import "ContentTableWithList.h"


@interface MainContentVC : UIViewController
{
    CGFloat _widthForTableCellBodyTextView;
    CGRect _mainScreen;
    UIImageView *_pinocchio;
}


@property (nonatomic , strong) UINavigationController *nController;

@property (nonatomic, strong) NSMutableString *menuKey;

@property (nonatomic, strong) ContentTableWithPeople *peopleTable;
@property (nonatomic, strong) ContentTableWithList *listTable;


- (void)loadContentWithNavigationController:(UINavigationController *)navController;


@end
