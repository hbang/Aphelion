//
//  HBBMRootViewController.m
//  Bromine
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBBMRootViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation HBBMRootViewController

- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_currentPosition = 0;
}

- (void)pushViewController:(UIViewController *)viewController {
	UIViewController *newViewController;
	
	if ([viewController isKindOfClass:UITabBarController.class]) {
		newViewController = viewController;
	} else {
		newViewController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
		[self addChildViewController:newViewController];
	}
	
	newViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	newViewController.view.frame = CGRectMake(0.f, 20.f, 320.f, self.view.frame.size.height - 20.f);
	[self.view addSubview:newViewController.view];
	[newViewController didMoveToParentViewController:self];
}

- (void)popViewController {
	NSLog(@"popViewController not implemented");
}

- (BOOL)shouldAutorotate {
	return YES;
}

@end
