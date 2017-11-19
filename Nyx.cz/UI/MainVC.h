//
//  MainVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenu.h"
#import "LoginScreenVC.h"
#import "CloseCoverView.h"
#import "MainContentVC.h"


@interface MainVC : UIViewController <UIGestureRecognizerDelegate, CloseCoverViewDelegate, SideMenuDelegate>
{
    CGPoint _viewCenter;
    CGFloat _sideMenuMaxShift, _sideMenuBreakingPoint;
}

@property (nonatomic, strong) LoginScreenVC *loginScreen;
@property (nonatomic, strong) MainContentVC *contentVc;
@property (nonatomic, strong) SideMenu *sideMenu;
@property (nonatomic, strong) CloseCoverView *closeCoverView;


- (void)sideMenuClose;


@end
