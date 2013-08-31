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
	self.view.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1];
	
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
	containerView.tag = _currentViewControllers.count;
	containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	containerView.frame = CGRectMake((self.class.columnWidth * (_currentViewControllers.count - 1)) + (animated ? -30.f : 0.f), 0.f, self.class.columnWidth, self.view.frame.size.height);
	
	newViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	newViewController.view.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height - 44.f);
	newViewController.view.alpha = animated ? 0.7f : 1;
	[containerView addSubview:newViewController.view];
	
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(newViewController.view.frame.origin.x, self.view.frame.size.height - 44.f, newViewController.view.frame.size.width, 44.f)];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[toolbar addGestureRecognizer:[[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(toolbarGestureRecognizerFired:)] autorelease]];
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

- (void)popViewControllersAfter:(UIViewController *)viewController animated:(BOOL)animated {
	BOOL found = NO;
	
	for (UIViewController *childViewController in _currentViewControllers) {
		if (found) {
			[self popViewControllerAnimated:animated];
		} else if (childViewController == viewController) {
			found = YES;
		}
	}
	
	if (!found) {
		NSLog(@"popViewControllersAfter: after view controller not found"); // don't remove this. helps in debugging
		
		if (_currentViewControllers.count > 1) {
			for (unsigned i = 1; i < _currentViewControllers.count; i++) {
				[self popViewControllerAnimated:animated];
			}
		}
	}
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated removingViewControllersAfter:(UIViewController *)removeAfterVC {
	[self popViewControllersAfter:removeAfterVC animated:animated];
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

- (void)toolbarGestureRecognizerFired:(UIPanGestureRecognizer *)gestureRecognizer {
	UIView *containerView = gestureRecognizer.view.superview;
	
	float y = [gestureRecognizer translationInView:gestureRecognizer.view].y;
	
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:
		{
			containerView.alpha = 1;
			
			CGRect frame = containerView.frame;
			frame.origin.y = 0;
			containerView.frame = frame;
			break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
			float newAlpha = 1 - (-y / 150.f);
			containerView.alpha = newAlpha > 0.2f ? newAlpha : 0.2f;
			
			CGRect frame = containerView.frame;
			frame.origin.y = y;
			containerView.frame = frame;
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateFailed:
		case UIGestureRecognizerStateCancelled:
		{
			BOOL success = gestureRecognizer.state == UIGestureRecognizerStateEnded && y < -100.f;
			
			[UIView animateWithDuration:0.3f animations:^{
				containerView.alpha = success ? 0 : 1;
				
				CGRect frame = containerView.frame;
				frame.origin.y = success ? -containerView.frame.size.height / 3 * 2 : 0;
				containerView.frame = frame;
			} completion:^(BOOL finished) {
				if (success) {
					[self popViewControllersAfter:[_currentViewControllers objectAtIndex:containerView.tag] animated:YES];
					[self popViewControllerAnimated:NO];
				}
			}];
			break;
		}
		
		default: 
			// k shut up clang
			break;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - Memory management

- (void)dealloc {
	[_deferredAnimateIns release];
	[_currentViewControllers release];
	
	[_scrollView release];
	[_sidebarView release];;
	
	[_currentAvatar release];
	// [_otherAccounts release];
	
	[_homeButton release];
	[_mentionsButton release];
	[_messagesButton release];
	[_searchButton release];
	
	[_settingsButton release];
	
	[super dealloc];
}

@end
