//
//  WebVC.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 27/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebVC : UIViewController <UIWebViewDelegate>
{
    UIWebView *_web;
}


@property (nonatomic, strong) NSURL *urlToLoad;


@end
