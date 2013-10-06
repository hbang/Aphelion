//
//  HBAPAppDelegate.h
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HBAPNavigationController, HBAPRootViewController;

@interface HBAPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HBAPRootViewController *rootViewController;

@end
