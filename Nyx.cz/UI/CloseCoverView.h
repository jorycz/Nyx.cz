//
//  CloseCoverView.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CloseCoverViewDelegate
- (void)coverViewWouldLikeToCloseMenu;
@end


@interface CloseCoverView : UIView <UIGestureRecognizerDelegate>


@property (nonatomic, weak) id delegate;


- (void)viewTapped;


@end
