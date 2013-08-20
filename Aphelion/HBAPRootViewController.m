//
//  HBAPRootViewController.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPRootViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation HBAPRootViewController

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
	newViewController.view.frame = CGRectMake(0.f, 0.f, 320.f, self.view.frame.size.height);
	[self.view addSubview:newViewController.view];
	[newViewController didMoveToParentViewController:self];
}

- (void)popViewController {
	NSLog(@"popViewController not implemented");
}

- (BOOL)shouldAutorotate {
	return YES;
}

#ifdef THEOS
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}
#endif

@end
