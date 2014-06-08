//
//  HBAPRootViewControllerIPad.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPRootViewControllerIPad.h"
#import "HBAPAvatarButton.h"
#import "HBAPNavigationController.h"
#import "HBAPSidebarButton.h"
#import "HBAPBackgroundView.h"
#import "HBAPHomeTimelineViewController.h"
#import "HBAPMentionsTimelineViewController.h"
#import "HBAPMessagesViewController.h"
#import "HBAPProfileViewController.h"
#import "HBAPSearchTimelineViewController.h"
#import "HBAPRootViewControllerIPhone.h"
#import "HBAPAvatarSwitchButton.h"
#import "HBAPAccount.h"
#import "HBAPAccountController.h"
#import "HBAPUser.h"
#import "HBAPThemeManager.h"
#import <FXBlurView/FXBlurView.h>

@interface HBAPRootViewControllerIPad () {
	HBAPBackgroundView *_backgroundView;

	// ipad
	BOOL _hasAppeared;
	NSMutableArray *_deferredAnimateIns;
	NSMutableArray *_currentViewControllers;

	UIScrollView *_scrollView;
	UIView *_sideView;
	
	UIButton *_settingsButton;

	UIToolbar *_currentBlurView;
	UIView *_staticBlurView;
}

@end

@implementation HBAPRootViewControllerIPad

#pragma mark - Interface constants

+ (CGFloat)columnWidth {
	return 400.f;
}

+ (CGFloat)columnWidthDouble {
	return 600.f;
}

+ (CGFloat)sideWidth {
	return 64.f;
}

#pragma mark - Interface

- (void)loadView {
	[super loadView];
	
	UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
	containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:containerView];
	
	_currentPosition = 0;
	_hasAppeared = NO;
	_deferredAnimateIns = [[NSMutableArray alloc] init];
	_currentViewControllers = [[NSMutableArray alloc] init];
	
	_backgroundView = [[HBAPBackgroundView alloc] initWithFrame:CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height)];
	_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[containerView addSubview:_backgroundView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
	_scrollView.delegate = self;
	[containerView addSubview:_scrollView];
	
	_sideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.class.sideWidth, _scrollView.frame.size.height)];
	_sideView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	_sideView.backgroundColor = [HBAPThemeManager sharedInstance].sideBackgroundColor;
	_sideView.clipsToBounds = YES;
	_sideView.alpha = 0;
	[containerView addSubview:_sideView];
	
	_settingsButton = [[UIButton buttonWithType:UIButtonTypeSystem] retain];
	_settingsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	_settingsButton.frame = CGRectMake(0, _sideView.frame.size.height - _sideView.frame.size.width, _sideView.frame.size.width, _sideView.frame.size.width);
	_settingsButton.tintColor = [HBAPThemeManager sharedInstance].sideTextColor;
	[_settingsButton setImage:[UIImage imageNamed:@"sidebar_settings"] forState:UIControlStateNormal];
	[_sideView addSubview:_settingsButton];
	
	CGFloat composeSize = 44.f;
	
	UIView *composeContainer = [[[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - composeSize, self.view.frame.size.height - composeSize, composeSize, composeSize)] autorelease];
	composeContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[self.view addSubview:composeContainer];
	
	FXBlurView *composeBlurView = [[[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, composeSize, composeSize)] autorelease];
	composeBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	composeBlurView.tintColor = [UIColor clearColor];
	composeBlurView.underlyingView = containerView;
	[composeContainer addSubview:composeBlurView];
	
	UIButton *composeButton = [UIButton buttonWithType:UIButtonTypeSystem];
	composeButton.frame = composeBlurView.frame;
	[composeButton setImage:[UIImage imageNamed:@"compose"] forState:UIControlStateNormal];
	[composeContainer addSubview:composeButton];
}

- (void)initialSetup {
	[self pushViewController:[[[HBAPHomeTimelineViewController alloc] init] autorelease] animated:YES];
	[self pushViewController:[[[HBAPMentionsTimelineViewController alloc] init] autorelease] animated:YES];
	[self pushViewController:[[[HBAPMessagesViewController alloc] init] autorelease] animated:YES];
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
	newViewController.view.frame = CGRectMake((self.class.columnWidth * (_currentViewControllers.count - 1)) - (animated ? 30.f : 0.f), 0, width, _scrollView.frame.size.height);
	newViewController.view.alpha = animated ? 0.7f : 1;
	newViewController.toolbar.tag = newViewController.view.tag;
	newViewController.toolbarGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(toolbarGestureRecognizerFired:)] autorelease];

	[_scrollView insertSubview:newViewController.view atIndex:0];
	[newViewController didMoveToParentViewController:self];

	CGSize contentSize = _scrollView.contentSize;
	contentSize.width += width;
	_scrollView.contentSize = contentSize;

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (_scrollView.contentOffset.x < 0 && _scrollView.contentOffset.x >= -[self.class sideWidth]) {
		[UIView animateWithDuration:0.3 animations:^{
			_sideView.alpha = -_scrollView.contentOffset.x / [self.class sideWidth];
			_scrollView.contentInset = UIEdgeInsetsMake(0, -_scrollView.contentOffset.x, 0, 0);
			_scrollView.scrollIndicatorInsets = _scrollView.contentInset;
			
			CGRect sideFrame = _sideView.frame;
			sideFrame.size.width = -_scrollView.contentOffset.x;
			_sideView.frame = sideFrame;
		}];
	}
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if (_scrollView.contentOffset.x < 0 && _scrollView.contentOffset.x >= -[self.class sideWidth]) {
		targetContentOffset->x = 0;
		BOOL shouldOpen = _scrollView.contentOffset.x >= [self.class sideWidth] / 2;
		
		[UIView animateWithDuration:0.2 animations:^{
			_sideView.alpha = shouldOpen ? 1 : 0;
			_scrollView.contentInset = shouldOpen ? UIEdgeInsetsMake(0, [self.class sideWidth], 0, 0) : UIEdgeInsetsZero;
			_scrollView.scrollIndicatorInsets = _scrollView.contentInset;
			
			CGRect sideFrame = _sideView.frame;
			sideFrame.size.width = [self.class sideWidth];
			_sideView.frame = sideFrame;
		}];
		return;
	}
	
	/*
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
	*/
}

#pragma mark - Memory management

- (void)dealloc {
	[_backgroundView release];
	[_deferredAnimateIns release];
	[_currentViewControllers release];
	[_scrollView release];
	[_sideView release];
	[_settingsButton release];
	[_currentBlurView release];
	[_staticBlurView release];

	[super dealloc];
}

@end
