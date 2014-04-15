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
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _containerView.frame.size.height)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
		_scrollView.delegate = self;
		_scrollView.contentInset = UIEdgeInsetsMake(0, self.class.sidebarWidth, 0, 0);
		_scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, self.class.sidebarWidth, 0, 0);
		[_containerView addSubview:_scrollView];
		
		_sidebarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.class.sidebarWidth, _containerView.frame.size.height)];
		_sidebarView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_sidebarView.backgroundColor = [HBAPThemeManager sharedInstance].sidebarBackgroundColor;
		[_containerView addSubview:_sidebarView];
		
		_avatarSwitchButton = [[HBAPAvatarSwitchButton alloc] initWithSize:HBAPAvatarSizeNormal];
		_avatarSwitchButton.frame = (CGRect){{18.f, 30.f}, _avatarSwitchButton.frame.size};
		[_sidebarView addSubview:_avatarSwitchButton];
		
		CGRect buttonFrame = CGRectMake(0, _avatarSwitchButton.frame.origin.y + _avatarSwitchButton.frame.size.height + 10.f, _sidebarView.frame.size.width, [HBAPSidebarButton buttonHeight]);
		
		_homeButton = [[HBAPSidebarButton button] retain];
		_homeButton.frame = buttonFrame;
		[_homeButton setTitle:L18N(@"Home") forState:UIControlStateNormal];
		[_homeButton setImage:[UIImage imageNamed:@"sidebar_home"] forState:UIControlStateNormal];
		[_sidebarView addSubview:_homeButton];
		
		buttonFrame.origin.y += _homeButton.frame.size.height;
		
		_mentionsButton = [[HBAPSidebarButton button] retain];
		_mentionsButton.frame = buttonFrame;
		[_mentionsButton setTitle:L18N(@"Mentions") forState:UIControlStateNormal];
		[_mentionsButton setImage:[UIImage imageNamed:@"sidebar_mentions"] forState:UIControlStateNormal];
		[_sidebarView addSubview:_mentionsButton];
		
		buttonFrame.origin.y += _mentionsButton.frame.size.height;
		
		_messagesButton = [[HBAPSidebarButton button] retain];
		_messagesButton.frame = buttonFrame;
		[_messagesButton setTitle:L18N(@"Messages") forState:UIControlStateNormal];
		[_messagesButton setImage:[UIImage imageNamed:@"sidebar_messages"] forState:UIControlStateNormal];
		[_sidebarView addSubview:_messagesButton];
		
		buttonFrame.origin.y += _messagesButton.frame.size.height;
		
		_searchButton = [[HBAPSidebarButton button] retain];
		_searchButton.frame = buttonFrame;
		[_searchButton setTitle:L18N(@"Search") forState:UIControlStateNormal];
		[_searchButton setImage:[UIImage imageNamed:@"sidebar_search"] forState:UIControlStateNormal];
		[_sidebarView addSubview:_searchButton];
		
		buttonFrame.origin.y += _searchButton.frame.size.height;
		
		_profileButton = [[HBAPSidebarButton button] retain];
		_profileButton.frame = buttonFrame;
		[_profileButton setTitle:L18N(@"Profile") forState:UIControlStateNormal];
		[_profileButton setImage:[UIImage imageNamed:@"sidebar_user"] forState:UIControlStateNormal];
		[_sidebarView addSubview:_profileButton];
		
		buttonFrame.origin.y = _sidebarView.frame.size.height - buttonFrame.size.height;
		
		_settingsButton = [[HBAPSidebarButton button] retain];
		_settingsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		_settingsButton.frame = buttonFrame;
		[_settingsButton setTitle:L18N(@"Settings") forState:UIControlStateNormal];
		[_settingsButton setImage:[UIImage imageNamed:@"sidebar_settings"] forState:UIControlStateNormal];
		[_sidebarView addSubview:_settingsButton];
	}
}

- (void)initialSetup {
	if (IS_IPAD) {
		HBAPHomeTimelineViewController *homeTimeline = [[[HBAPHomeTimelineViewController alloc] init] autorelease];
		HBAPMentionsTimelineViewController *mentionsTimeline = [[[HBAPMentionsTimelineViewController alloc] init] autorelease];
		HBAPMessagesViewController *messagesViewController = [[[HBAPMessagesViewController alloc] init] autorelease];
		
		[self pushViewController:homeTimeline animated:YES];
		[self pushViewController:mentionsTimeline animated:YES];
		[self pushViewController:messagesViewController animated:YES];
	} else {
		_iphoneTabBarController = [[HBAPHomeTabBarController alloc] initWithAccount:nil];
		[_iphoneTabBarController willMoveToParentViewController:self];
		[self addChildViewController:_iphoneTabBarController];
		[self.view addSubview:_iphoneTabBarController.view];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (IS_IPAD) {
		 _avatarSwitchButton.userID = [HBAPAccountController sharedInstance].currentAccount.userID;
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

#pragma mark - View controller add/remove

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated doubleWidth:(BOOL)doubleWidth {
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
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[self pushViewController:viewController animated:animated doubleWidth:NO];
}

- (void)popViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated {
	[self _popViewControllerAtIndex:index animated:YES initiatedByUser:NO];
}

- (void)_popViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated initiatedByUser:(BOOL)initiatedByUser {
	if (_currentViewControllers.count == 0) {
		HBLogWarn(@"popViewControllerAnimated: wat. there are 0 view controllers visible");
		return;
	}
	
	UIViewController *viewController = _currentViewControllers.lastObject;
	
	[_currentViewControllers removeObjectAtIndex:_currentViewControllers.count - 1];
	
	void (^updateScrollViewSize)() = ^{
		CGSize contentSize = _scrollView.contentSize;
		contentSize.width -= viewController.view.frame.size.width;
		_scrollView.contentSize = contentSize;
	};
	
	if (animated) {
		if (_currentBlurView) {
			[_currentBlurView removeFromSuperview];
			[_currentBlurView release];
		}
		
		_currentBlurView = [[UIToolbar alloc] initWithFrame:viewController.view.frame];
		_currentBlurView.autoresizingMask = viewController.view.autoresizingMask;
		_currentBlurView.barTintColor = [[HBAPThemeManager sharedInstance].backgroundColor colorWithAlphaComponent:0.3f];
		[_scrollView addSubview:_currentBlurView];
		
		[UIView animateWithDuration:0.3 animations:^{
			viewController.view.alpha = 0;
			_currentBlurView.alpha = 0;
			updateScrollViewSize();
		} completion:^(BOOL finished) {
			[viewController removeFromParentViewController];
			[viewController.view removeFromSuperview];
			[_currentBlurView removeFromSuperview];
			[_currentBlurView release];
		}];
	} else {
		[viewController removeFromParentViewController];
		[viewController.view removeFromSuperview];
		updateScrollViewSize();
	}
}

- (void)_animateViewIn:(UIView *)view {
	[UIView animateWithDuration:0.4 animations:^{
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
			_currentBlurView.barTintColor = [UIColor clearColor];
			[_scrollView addSubview:_currentBlurView];
			
			UIView *overlayView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, _currentBlurView.frame.size.width, _currentBlurView.frame.size.height)] autorelease];
			overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			overlayView.backgroundColor = [[HBAPThemeManager sharedInstance].backgroundColor colorWithAlphaComponent:0.75f];
			[_currentBlurView addSubview:overlayView];
			break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
			CGFloat blurAlpha = -y / 300.f;
			_currentBlurView.alpha = blurAlpha < 0.7f ? blurAlpha : 0.7f;
			
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
			
			[UIView animateWithDuration:0.3 animations:^{
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
					[self _popViewControllerAtIndex:gestureRecognizer.view.tag animated:YES initiatedByUser:YES];
				}
			}];
			break;
		}
		
		default: 
			// k shut up clang
			break;
	}
}

#pragma mark - UIScrollViewDelegate

/*
// TODO: get back to this
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	NSMutableArray *viewControllerWidths = [NSMutableArray array];
	
	if (velocity.x < 0) {
		for (NSInteger i = 0; i <= _currentPosition; i++) {
			[viewControllerWidths addObject:@(((UIViewController *)_currentViewControllers[_currentPosition]).view.frame.size.width)];
		}
	} else {
		for (NSInteger i = _currentPosition; i < _currentViewControllers.count; i++) {
			[viewControllerWidths addObject:@(((UIViewController *)_currentViewControllers[_currentPosition]).view.frame.size.width)];
		}
	}
	
	CGFloat origin = 0.f;
	CGFloat scrollViewWidth = _scrollView.frame.size.width - _scrollView.contentInset.left;
	NSUInteger i = 0;
	
	for (NSNumber *widthNumber in viewControllerWidths) {
		CGFloat width = widthNumber.floatValue;
		
		if ((velocity.x < 0) || (velocity.x >= 0 && targetContentOffset->x > width)) {
			_currentPosition = i;
			break;
		}
		
		origin += width;
		i++;
	}
	
	targetContentOffset->x = MIN(-_scrollView.contentInset.left + ((UIViewController *)_currentViewControllers[_currentPosition]).view.frame.origin.x, scrollViewWidth);
}
*/

#pragma mark - Memory management

- (void)dealloc {
	[_backgroundView release];
	[_deferredAnimateIns release];
	[_currentViewControllers release];
	[_containerView release];
	[_scrollView release];
	[_sidebarView release];
	[_avatarSwitchButton release];
	[_homeButton release];
	[_mentionsButton release];
	[_messagesButton release];
	[_searchButton release];
	[_settingsButton release];
	[_currentBlurView release];
	[_staticBlurView release];
	
	[super dealloc];
}

@end
