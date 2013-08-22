//
//  HBAPRootViewController.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPRootViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface HBAPRootViewController () {
	BOOL _hasAppeared;
	NSMutableArray *_deferredAnimateIns;
	NSMutableArray *_currentViewControllers;
}

@end

@implementation HBAPRootViewController

+ (float)columnWidth {
	return 340.f;
}

- (void)loadView {
	[super loadView];
	
	self.view = [[UIScrollView alloc] initWithFrame:self.view.frame];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.backgroundColor = [UIColor whiteColor];
	
	_currentPosition = 0;
	_hasAppeared = NO;
	_deferredAnimateIns = [[NSMutableArray alloc] init];
	_currentViewControllers = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	_hasAppeared = YES;
	
	for (UIView *view in _deferredAnimateIns) {
		[self _animateViewIn:view];
	}
	
	[_deferredAnimateIns release];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	UIViewController *newViewController;
	
	if ([viewController isKindOfClass:UITabBarController.class]) {
		newViewController = viewController;
	} else {
		newViewController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	}
	
	[self addChildViewController:newViewController];
	[_currentViewControllers addObject:newViewController];
	
	UIView *containerView = [[[UIView alloc] init] autorelease];
	containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	containerView.frame = CGRectMake((self.class.columnWidth * (_currentViewControllers.count - 1)) + (animated ? -30.f : 0.f), 0.f, self.class.columnWidth, self.view.frame.size.height);
	
	newViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	newViewController.view.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height - 44.f);
	newViewController.view.alpha = animated ? 0.7f : 1;
	[containerView addSubview:newViewController.view];
	
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(newViewController.view.frame.origin.x, self.view.frame.size.height - 44.f, newViewController.view.frame.size.width, 44.f)];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[toolbar addGestureRecognizer:[[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedOnToolbar:)] autorelease]];
	[containerView addSubview:toolbar];
	
	[self.view insertSubview:containerView atIndex:0];
	
	((UIScrollView *)self.view).contentSize = CGSizeMake(self.class.columnWidth * _currentViewControllers.count, ((UIScrollView *)self.view).contentSize.height);
	
	[newViewController didMoveToParentViewController:self];
	
	if (animated) {
		if (_hasAppeared) {
			[self _animateViewIn:containerView];
		} else {
			containerView.alpha = 0;
			[_deferredAnimateIns addObject:containerView];
		}
	}
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated removingViewControllersAfter:(UIViewController *)removeAfterVC {
	BOOL foundAfterVC = NO;
	
	for (UIViewController *childViewController in _currentViewControllers) {
		if (foundAfterVC) {
			[self popViewControllerAnimated:animated];
		} else if (childViewController == removeAfterVC) {
			foundAfterVC = YES;
		}
	}
	
	if (!foundAfterVC) {
		NSLog(@"pushViewController:animated:removingViewControllersAfter: after view controller not found"); // don't remove this. helps in debugging
		
		for (unsigned i = 1; i < _currentViewControllers.count; i++) {
			[self popViewControllerAnimated:animated];
		}
	}
	
	[self pushViewController:viewController animated:animated];
}

- (void)popViewControllerAnimated:(BOOL)animated {
	UIViewController *viewController = _currentViewControllers.lastObject;
	UIView *containerView = viewController.view.superview;
	
	[_currentViewControllers removeObjectAtIndex:_currentViewControllers.count - 1];
	
	if (animated) {
		[UIView animateWithDuration:0.3f animations:^{
			containerView.alpha = 0;
		} completion:^(BOOL finished) {
			[viewController removeFromParentViewController];
			[containerView removeFromSuperview];
		}];
	} else {
		[viewController removeFromParentViewController];
		[containerView removeFromSuperview];
	}
}

- (void)_animateViewIn:(UIView *)view {
	[UIView animateWithDuration:0.4f animations:^{
		view.alpha = 1;
		
		CGRect newFrame = view.frame;
		newFrame.origin.x += 30.f;
		view.frame = newFrame;
	}];
}

- (void)pannedOnToolbar:(UIPanGestureRecognizer *)gestureRecognizer {
	UIView *containerView = gestureRecognizer.view.superview;
	
	float y = [gestureRecognizer translationInView:gestureRecognizer.view].y;
	
	containerView.alpha -= y / 100.f;
	
	CGRect frame = containerView.frame;
	frame.origin.y += y > 0 ? 2.f : -2.f;
	containerView.frame = frame;
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
