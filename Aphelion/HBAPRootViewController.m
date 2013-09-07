//
//  HBAPRootViewController.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPRootViewController.h"
#import "HBAPAvatarImageView.h"
#import "HBAPNavigationController.h"
#import <QuartzCore/QuartzCore.h>

@interface HBAPRootViewController () {
	BOOL _hasAppeared;
	NSMutableArray *_deferredAnimateIns;
	NSMutableArray *_currentViewControllers;
	
	UIView *_containerView;
	UIScrollView *_scrollView;
	UIView *_sidebarView;
	
	UIImageView *_currentAvatar;
	// UITableView *_otherAccounts;
	
	UIButton *_homeButton;
	UIButton *_mentionsButton;
	UIButton *_messagesButton;
	UIButton *_searchButton;
	
	UIButton *_settingsButton;
}

@end

@implementation HBAPRootViewController

#pragma mark - Interface constants

+ (float)columnWidth {
	return 380.f;
}

+ (float)sidebarWidth {
	return 84.f;
}

#pragma mark - Interface

- (void)loadView {
	[super loadView];
	
	_currentPosition = 0;
	_hasAppeared = NO;
	_deferredAnimateIns = [[NSMutableArray alloc] init];
	_currentViewControllers = [[NSMutableArray alloc] init];
	
	_containerView = [[UIView alloc] initWithFrame:self.view.frame];
	_containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_containerView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.class.sidebarWidth, 0, _containerView.frame.size.width - self.class.sidebarWidth, _containerView.frame.size.height)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.backgroundColor = [UIColor colorWithWhite:0.3f alpha:1];
	[_containerView addSubview:_scrollView];
	
	_sidebarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.class.sidebarWidth, _containerView.frame.size.height)];
	_sidebarView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	_sidebarView.backgroundColor = [UIColor colorWithWhite:0.05f alpha:1];
	[_containerView addSubview:_sidebarView];
	
	float top = IS_IOS_7 ? 20.f : 0;
	
	_currentAvatar = [[HBAPAvatarImageView alloc] initWithUser:nil size:HBAPAvatarSizeRegular];
	_currentAvatar.frame = (CGRect){{10.f, top + 10.f}, _currentAvatar.frame.size};
	[_sidebarView addSubview:_currentAvatar];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	_hasAppeared = YES;
	
	for (UIView *view in _deferredAnimateIns) {
		[self _animateViewIn:view];
	}
	
	[_deferredAnimateIns release];
}

#pragma mark - View controller push/pop

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	HBAPNavigationController *newViewController = [[[HBAPNavigationController alloc] initWithRootViewController:viewController] autorelease];
	
	[self addChildViewController:newViewController];
	[_currentViewControllers addObject:newViewController];
	
	newViewController.view.tag = _currentViewControllers.count - 1;
	newViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	newViewController.view.frame = CGRectMake((self.class.columnWidth * (_currentViewControllers.count - 1)) - (animated ? 30.f : 0.f), 0, self.class.columnWidth, _containerView.frame.size.height);
	newViewController.view.alpha = animated ? 0.7f : 1;
	newViewController.toolbar.tag = newViewController.view.tag;
	newViewController.toolbarGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(toolbarGestureRecognizerFired:)] autorelease];
	
	[_scrollView insertSubview:newViewController.view atIndex:0];
	[newViewController didMoveToParentViewController:self];
	
	_scrollView.contentSize = CGSizeMake(self.class.columnWidth * _currentViewControllers.count, _scrollView.contentSize.height);
	
	if (animated) {
		if (_hasAppeared) {
			[self _animateViewIn:newViewController.view];
		} else {
			newViewController.view.alpha = 0;
			[_deferredAnimateIns addObject:newViewController.view];
		}
	}
}

- (void)popViewControllersAfter:(UIViewController *)viewController animated:(BOOL)animated {
	BOOL found = NO;
	HBAPNavigationController *afterViewController = viewController.class == HBAPNavigationController.class ? (HBAPNavigationController *)viewController : (HBAPNavigationController *)viewController.navigationController;
	
	for (UIViewController *childViewController in _currentViewControllers) {
		if (found) {
			[self popViewControllerAnimated:animated];
		} else if (childViewController == afterViewController) {
			found = YES;
		}
	}
	
	if (!found) {
		NSLog(@"popViewControllersAfter: after view controller not found");
		
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
	if (_currentViewControllers.count == 0) {
		NSLog(@"popViewControllerAnimated: wat. there are 0 view controllers visible");
		return;
	}
	
	UIViewController *viewController = _currentViewControllers.lastObject;
	
	[_currentViewControllers removeObjectAtIndex:_currentViewControllers.count - 1];
	
	if (animated) {
		[UIView animateWithDuration:0.3f animations:^{
			viewController.view.alpha = 0;
		} completion:^(BOOL finished) {
			[viewController removeFromParentViewController];
			[viewController.view removeFromSuperview];
		}];
	} else {
		[viewController removeFromParentViewController];
		[viewController.view removeFromSuperview];
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

#pragma mark - Gesture recognizers

- (void)toolbarGestureRecognizerFired:(UIPanGestureRecognizer *)gestureRecognizer {
	HBAPNavigationController *viewController = [_currentViewControllers objectAtIndex:gestureRecognizer.view.tag];
	
	float y = [gestureRecognizer translationInView:gestureRecognizer.view].y;
	
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:
		{
			viewController.view.alpha = 1;
			
			CGRect frame = viewController.view.frame;
			frame.origin.y = 0;
			viewController.view.frame = frame;
			break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
			float newAlpha = 1 - (-y / 150.f);
			viewController.view.alpha = newAlpha > 0.2f ? newAlpha : 0.2f;
			
			CGRect frame = viewController.view.frame;
			frame.origin.y = y;
			viewController.view.frame = frame;
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateFailed:
		case UIGestureRecognizerStateCancelled:
		{
			BOOL success = gestureRecognizer.state == UIGestureRecognizerStateEnded && y < -100.f;
			
			[UIView animateWithDuration:0.3f animations:^{
				viewController.view.alpha = success ? 0 : 1;
				
				CGRect frame = viewController.view.frame;
				frame.origin.y = success ? -viewController.view.frame.size.height / 3 * 2 : 0;
				viewController.view.frame = frame;
			} completion:^(BOOL finished) {
				if (success) {
					[self popViewControllersAfter:viewController animated:YES];
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
