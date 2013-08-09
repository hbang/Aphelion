//
//  HBAPAppDelegate.h
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBAPRootViewController.h"

@interface HBAPAppDelegate : UIResponder <UIApplicationDelegate> {
	HBAPRootViewController *_rootViewController;
}

- (void)performFirstRunTutorial;

@property (strong, nonatomic) UIWindow *window;

@end
