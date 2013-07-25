//
//  HBBMAppDelegate.h
//  Bromine
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBBMRootViewController.h"

@interface HBBMAppDelegate : UIResponder <UIApplicationDelegate> {
	HBBMRootViewController *_rootViewController;
}

- (void)performFirstRunTutorial;

@property (strong, nonatomic) UIWindow *window;

@end
