//
//  SideMenuTopSection.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 18/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CacheManager.h"


@interface SideMenuTopSection : UIView <CacheManagerDelegate>
{
    UIImageView *_userAvatarView;
    UITextField *_userName;
}


@property (nonatomic, strong) CacheManager *cache;


@end
