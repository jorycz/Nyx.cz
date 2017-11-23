//
//  SideMenuCell.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuCell : UITableViewCell
{
    UILabel *_news;
}


@property (nonatomic, assign) NSInteger newPosts;


- (void)updateMenuLabel:(NSString *)l;
- (void)updateLabelColor;


@end
