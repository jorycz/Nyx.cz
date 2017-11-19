//
//  MainContentVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"


@interface MainContentVC : UIViewController
{
    UITextField *_info;
}


@property (nonatomic, strong) NSMutableString *menuKey;


- (void)loadContent;


@end
