//
//  AppDelegate.h
//  Nyx.cz
//
//  Created by Josef Rysanek on 15/11/2017.
//  Copyright © 2017 Josef Rysanek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ViewController.h"
#import "TabController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (nonatomic, strong) ViewController *mainScreen;
@property (nonatomic, strong) TabController *mainTab;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

