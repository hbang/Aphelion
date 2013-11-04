//
//  HBAPRootViewController.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPRootViewController.h"
#import "HBAPAvatarButton.h"
#import "HBAPNavigationController.h"
#import "HBAPSidebarButton.h"
#import "HBAPBackgroundView.h"
#import "HBAPHomeTimelineViewController.h"
#import "HBAPMentionsTimelineViewController.h"
#import "HBAPMessagesViewController.h"
#import "HBAPProfileViewController.h"
#import "HBAPSearchTimelineViewController.h"
#import "HBAPHomeTabBarController.h"
#import "HBAPAvatarSwitchButton.h"
#import "HBAPAccount.h"
#import "HBAPAccountController.h"
#import "HBAPUser.h"
#import "HBAPThemeManager.h"
#import "HBAPBlurView.h"

@interface HBAPRootViewController () {
	HBAPBackgroundView *_backgroundView;
	
	// ipad
	BOOL _hasAppeared;
	NSMutableArray *_deferredAnimateIns;
	NSMutableArray *_currentViewControllers;
	
	UIView *_containerView;
	UIScrollView *_scrollView;
	UIView *_sidebarView;
	
	HBAPAvatarSwitchButton *_avatarSwitchButton;
	
	HBAPSidebarButton *_homeButton;
	HBAPSidebarButton *_mentionsButton;
	HBAPSidebarButton *_messagesButton;
	HBAPSidebarButton *_searchButton;
	HBAPSidebarButton *_profileButton;
	HBAPSidebarButton *_settingsButton;
	
	UIToolbar *_currentBlurView;
	UIView *_staticBlurView;
	
	// iphone
	UINavigationController *_currentNavigationController;
	
	UINavigationController *_homeNavigationController;
	UINavigationController *_mentionsNavigationController;
	UINavigationController *_messagesNavigationController;
	UINavigationController *_profileNavigationController;
	UINavigationController *_searchNavigationController;
}

@end

@implementation HBAPRootViewController

#pragma mark - Interface constants

+ (CGFloat)columnWidth {
	return 380.f;
}

+ (CGFloat)columnWidthDouble {
	return 570.f;
}

+ (CGFloat)sidebarWidth {
	return 84.f;
}

+ (UIColor *)sidebarBackgroundColor {
	return [[HBAPThemeManager sharedInstance].backgroundColor colorWithAlphaComponent:0.4f];
}

#pragma mark - Interface

- (void)loadView {
	[super loadView];
	
	if (IS_IPAD) {
		_backgroundView = [[HBAPBackgroundView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.view addSubview:_backgroundView];
		
		_currentPosition = 0;
		_hasAppeared = NO;
		_deferredAnimateIns = [[NSMutableArray alloc] init];
		_currentViewControllers = [[NSMutableArray alloc] init];
		
		_containerView = [[UIView alloc] initWithFrame:self.view.frame];
		_containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.view addSubview:_containerView];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.class.sidebarWidth, 0, self.view.frame.size.width - self.class.sidebarWidth, _containerView.frame.size.height)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[_containerView addSubview:_scrollView];
		
		_sidebarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.class.sidebarWidth, _containerView.frame.size.height)];
		_sidebarView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_sidebarView.backgroundColor = [self.class sidebarBackgroundColor];
		[_containerView addSubview:_sidebarView];
		
		_avatarSwitchButton = [[HBAPAvatarSwitchButton alloc] initWithSize:HBAPAvatarSizeNormal];
		_avatarSwitchButton.frame = (CGRect){{18.f, 30.f}, _avatarSwitchButton.frame.size};
		[_sidebarView addSubview:_avatarSwitchButton];
		
		_homeButton = [[HBAPSidebarButton button] retain];
		_homeButton.frame = CGRectMake(0, _avatarSwitchButton.frame.origin.y + _avatarSwitchButton.frame.size.height + 10.f, _sidebarView.frame.size.width, [HBAPSidebarButton buttonHeight]);
		[_homeButton setTitle:L18N(@"Home") forState:UIControlStateNormal];
		[_homeButton setImage:[UIImage imageNamed:@"sidebar_home"] forState:UIControlStateNormal];
		[_homeButton setImage:[UIImage imageNamed:@"sidebar_home_selected"] forState:UIControlStateSelected];
		[_homeButton addTarget:self action:@selector(sidebarButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
		[_homeButton addTarget:self action:@selector(sidebarButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
		_homeButton.selected = YES;
		[_sidebarView addSubview:_homeButton];
		
		_mentionsButton = [[HBAPSidebarButton button] retain];
		_mentionsButton.frame = CGRectMake(0, _homeButton.frame.origin.y + _homeButton.frame.size.height, _sidebarView.frame.size.width, [HBAPSidebarButton buttonHeight]);
		[_mentionsButton setTitle:L18N(@"Mentions") forState:UIControlStateNormal];
		[_mentionsButton setImage:[UIImage imageNamed:@"sidebar_mentions"] forState:UIControlStateNormal];
		[_mentionsButton setImage:[UIImage imageNamed:@"sidebar_mentions_selected"] forState:UIControlStateSelected];
		[_mentionsButton addTarget:self action:@selector(sidebarButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
		[_mentionsButton addTarget:self action:@selector(sidebarButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
		[_sidebarView addSubview:_mentionsButton];
		
		_messagesButton = [[HBAPSidebarButton button] retain];
		_messagesButton.frame = CGRectMake(0, _mentionsButton.frame.origin.y + _mentionsButton.frame.size.height, _sidebarView.frame.size.width, [HBAPSidebarButton buttonHeight]);
		[_messagesButton setTitle:L18N(@"Messages") forState:UIControlStateNormal];
		[_messagesButton setImage:[UIImage imageNamed:@"sidebar_messages"] forState:UIControlStateNormal];
		[_messagesButton setImage:[UIImage imageNamed:@"sidebar_messages_selected"] forState:UIControlStateSelected];
		[_messagesButton addTarget:self action:@selector(sidebarButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
		[_messagesButton addTarget:self action:@selector(sidebarButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
		[_sidebarView addSubview:_messagesButton];
		
		_searchButton = [[HBAPSidebarButton button] retain];
		_searchButton.frame = CGRectMake(0, _messagesButton.frame.origin.y + _messagesButton.frame.size.height, _sidebarView.frame.size.width, [HBAPSidebarButton buttonHeight]);
		[_searchButton setTitle:L18N(@"Search") forState:UIControlStateNormal];
		[_searchButton setImage:[UIImage imageNamed:@"sidebar_search"] forState:UIControlStateNormal];
		[_searchButton setImage:[UIImage imageNamed:@"sidebar_search_selected"] forState:UIControlStateSelected];
		[_searchButton addTarget:self action:@selector(sidebarButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
		[_searchButton addTarget:self action:@selector(sidebarButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
		[_sidebarView addSubview:_searchButton];
		
		_profileButton = [[HBAPSidebarButton button] retain];
		_profileButton.frame = CGRectMake(0, _searchButton.frame.origin.y + _searchButton.frame.size.height, _sidebarView.frame.size.width, [HBAPSidebarButton buttonHeight]);
		[_profileButton setTitle:L18N(@"Profile") forState:UIControlStateNormal];
		[_profileButton setImage:[UIImage imageNamed:@"sidebar_user"] forState:UIControlStateNormal];
		[_profileButton setImage:[UIImage imageNamed:@"sidebar_user_selected"] forState:UIControlStateSelected];
		[_profileButton addTarget:self action:@selector(sidebarButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
		[_profileButton addTarget:self action:@selector(sidebarButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
		[_sidebarView addSubview:_profileButton];
		
		_settingsButton = [[HBAPSidebarButton button] retain];
		_settingsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		_settingsButton.frame = CGRectMake(0, _sidebarView.frame.size.height - [HBAPSidebarButton buttonHeight], _sidebarView.frame.size.width, [HBAPSidebarButton buttonHeight]);
		[_settingsButton setTitle:L18N(@"Settings") forState:UIControlStateNormal];
		[_settingsButton setImage:[UIImage imageNamed:@"sidebar_settings"] forState:UIControlStateNormal];
		[_settingsButton setImage:[UIImage imageNamed:@"sidebar_settings_selected"] forState:UIControlStateSelected];
		[_settingsButton addTarget:self action:@selector(sidebarButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
		[_settingsButton addTarget:self action:@selector(sidebarButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
		[_sidebarView addSubview:_settingsButton];
	}
}

- (void)initialSetup {
	if (IS_IPAD) {
		HBAPHomeTimelineViewController *homeTimeline = [[[HBAPHomeTimelineViewController alloc] init] autorelease];
		[self pushViewController:homeTimeline animated:YES];
	} else {
		_iphoneTabBarController = [[HBAPHomeTabBarController alloc] initWithAccount:nil];
		[_iphoneTabBarController willMoveToParentViewController:self];
		[self addChildViewController:_iphoneTabBarController];
		[self.view addSubview:_iphoneTabBarController.view];
	}
}

- (void)sidebarButtonTouchDown:(UIButton *)sender {
	if (sender.selected) {
		return;
	}
}

- (void)sidebarButtonSelected:(UIButton *)sender {
	if (sender.selected) {
		return;
	}
	
	if (sender != _homeButton) {
		_homeButton.selected = NO;
	}
	
	if (sender != _mentionsButton) {
		_mentionsButton.selected = NO;
	}
	
	if (sender != _messagesButton) {
		_messagesButton.selected = NO;
	}
	
	if (sender != _searchButton) {
		_searchButton.selected = NO;
	}
	
	if (sender != _profileButton) {
		_profileButton.selected = NO;
	}
	
	if (sender != _settingsButton) {
		_settingsButton.selected = NO;
	}
	
	sender.selected = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (IS_IPAD) {
		 _avatarSwitchButton.userID = [HBAPAccountController sharedInstance].accountForCurrentUser.userID;
	}
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

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated doubleWidth:(BOOL)doubleWidth {
	if (IS_IPAD) {
		CGFloat width = doubleWidth ? [self.class columnWidthDouble] : [self.class columnWidth];
		HBAPNavigationController *newViewController = [[[HBAPNavigationController alloc] initWithRootViewController:viewController] autorelease];
		
		[self addChildViewController:newViewController];
		[_currentViewControllers addObject:newViewController];
		
		newViewController.view.tag = _currentViewControllers.count - 1;
		newViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		newViewController.view.frame = CGRectMake((self.class.columnWidth * (_currentViewControllers.count - 1)) - (animated ? 30.f : 0.f), 0, width, _containerView.frame.size.height);
		newViewController.view.alpha = animated ? 0.7f : 1;
		newViewController.toolbar.tag = newViewController.view.tag;
		newViewController.toolbarGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(toolbarGestureRecognizerFired:)] autorelease];
		
		[_scrollView insertSubview:newViewController.view atIndex:0];
		[newViewController didMoveToParentViewController:self];
		
		_scrollView.contentSize = CGSizeMake(self.class.columnWidth * (_currentViewControllers.count - 1) + width, _scrollView.contentSize.height);
		
		if (animated) {
			if (_hasAppeared) {
				[self _animateViewIn:newViewController.view];
			} else {
				newViewController.view.alpha = 0;
				[_deferredAnimateIns addObject:newViewController.view];
			}
		}
	} else {
		[_currentNavigationController pushViewController:viewController animated:animated];
	}
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[self pushViewController:viewController animated:animated doubleWidth:NO];
}

- (void)popViewControllersAfter:(UIViewController *)viewController animated:(BOOL)animated {
	if (!IS_IPAD) {
		return;
	}
	
	BOOL found = NO;
	HBAPNavigationController *afterViewController = viewController.class == HBAPNavigationController.class ? (HBAPNavigationController *)viewController : (HBAPNavigationController *)viewController.navigationController;
	
	for (UIViewController *childViewController in _currentViewControllers) {
		if (found) {
			[self _popViewControllerAnimated:animated initiatedByUser:NO];
		} else if (childViewController == afterViewController) {
			found = YES;
		}
	}
	
	if (!found) {
		HBLogWarn(@"popViewControllersAfter: after view controller not found");
		
		if (_currentViewControllers.count > 1) {
			for (NSUInteger i = 1; i < _currentViewControllers.count; i++) {
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
	if (IS_IPAD) {
		[self _popViewControllerAnimated:animated initiatedByUser:NO];
	} else {
		[_currentNavigationController popViewControllerAnimated:animated];
	}
}

- (void)_popViewControllerAnimated:(BOOL)animated initiatedByUser:(BOOL)initiatedByUser {
	if (_currentViewControllers.count == 0) {
		HBLogWarn(@"popViewControllerAnimated: wat. there are 0 view controllers visible");
		return;
	}
	
	UIViewController *viewController = _currentViewControllers.lastObject;
	
	[_currentViewControllers removeObjectAtIndex:_currentViewControllers.count - 1];
	
	if (animated) {
		if (_currentBlurView) {
			[_currentBlurView removeFromSuperview];
			[_currentBlurView release];
		}
		
		_currentBlurView = [[UIToolbar alloc] initWithFrame:viewController.view.frame];
		_currentBlurView.autoresizingMask = viewController.view.autoresizingMask;
		_currentBlurView.barTintColor = [[HBAPThemeManager sharedInstance].backgroundColor colorWithAlphaComponent:0.3f];
		[_scrollView addSubview:_currentBlurView];
		
		[UIView animateWithDuration:0.3f animations:^{
			viewController.view.alpha = 0;
			_currentBlurView.alpha = 0;
		} completion:^(BOOL finished) {
			[viewController removeFromParentViewController];
			[viewController.view removeFromSuperview];
			[_currentBlurView removeFromSuperview];
			[_currentBlurView release];
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
	
	CGFloat y = [gestureRecognizer translationInView:gestureRecognizer.view].y;
	
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:
		{
			viewController.view.alpha = 1;
			
			CGRect frame = viewController.view.frame;
			frame.origin.y = 0;
			viewController.view.frame = frame;
			
			if (_currentBlurView) {
				[_currentBlurView removeFromSuperview];
				[_currentBlurView release];
			}
			
			_currentBlurView = [[UIToolbar alloc] initWithFrame:viewController.view.frame];
			_currentBlurView.autoresizingMask = viewController.view.autoresizingMask;
			_currentBlurView.alpha = 0;
			_currentBlurView.userInteractionEnabled = NO;
			_currentBlurView.translucent = YES;
			_currentBlurView.barTintColor = [[HBAPThemeManager sharedInstance].backgroundColor colorWithAlphaComponent:0.35f];
			[_scrollView addSubview:_currentBlurView];
			break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
			CGFloat blurAlpha = -y / 150.f;
			_currentBlurView.alpha = blurAlpha < 1.f ? blurAlpha : 1.f;
			
			CGRect frame = viewController.view.frame;
			frame.origin.y = y;
			viewController.view.frame = frame;
			_currentBlurView.frame = frame;
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateFailed:
		case UIGestureRecognizerStateCancelled:
		{
			BOOL success = gestureRecognizer.state == UIGestureRecognizerStateEnded && y < -100.f;
			CGRect blurViewFrame;
			
			if (success) {
				blurViewFrame = _currentBlurView.frame;
				_staticBlurView = [_currentBlurView resizableSnapshotViewFromRect:CGRectMake(0, 0, blurViewFrame.size.width, blurViewFrame.size.height) afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
				
				_staticBlurView.frame = blurViewFrame;
				[_scrollView addSubview:_staticBlurView];
			}
			
			[_currentBlurView removeFromSuperview];
			[_currentBlurView release];
			_currentBlurView = nil;
			
			[UIView animateWithDuration:0.3f animations:^{
				CGRect frame = viewController.view.frame;
				frame.origin.y = success ? -viewController.view.frame.size.height / 3 * 2 : 0;
				viewController.view.frame = frame;
				viewController.view.alpha = success ? 0.2f : 1;
				
				if (_staticBlurView) {
					_staticBlurView.frame = frame;
					_staticBlurView.alpha = viewController.view.alpha;
				}
			} completion:^(BOOL finished) {
				if (success) {
					[self popViewControllersAfter:viewController animated:YES];
					[self _popViewControllerAnimated:NO initiatedByUser:YES];
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
	[_sidebarView release];
	
	[_avatarSwitchButton release];
	
	[_homeButton release];
	[_mentionsButton release];
	[_messagesButton release];
	[_searchButton release];
	
	[_settingsButton release];
	
	[_currentBlurView release];
	
	[super dealloc];
}

@end
