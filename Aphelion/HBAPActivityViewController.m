//
//  HBAPActivityViewController.m
//  Aphelion
//
//  Created by Adam D on 4/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPActivityViewController.h"
#import "HBAPActivity.h"
#import "HBAPActivitySectionView.h"
#import "HBAPThemeManager.h"
#import "HBAPRootViewControllerIPad.h"
#import "HBAPAppDelegate.h"

@interface HBAPActivityViewController () {
	NSDictionary *_items;
	BOOL _isVisible;
	UIPopoverController *_activityPopoverController;
	
	UIButton *_backgroundView;
	UIView *_contentView;
	UIButton *_cancelButton;
	NSArray *_sections;
}

@end

@implementation HBAPActivityViewController

#pragma mark - Constants

+ (UIColor *)cancelButtonSelectionColor {
	return [[HBAPThemeManager sharedInstance].dimTextColor colorWithAlphaComponent:0.35f];
}

#pragma mark - Implementation

- (void)loadView {
	[super loadView];
	
	_contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 410.f)];
	_contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:_contentView];
	
	_backgroundView = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_backgroundView.frame = CGRectMake(0, 0, _contentView.frame.size.width, 0);
	_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[_backgroundView addTarget:self action:@selector(cancelButtonTouchBegan) forControlEvents:UIControlEventTouchDown];
	[_backgroundView addTarget:self action:@selector(cancelButtonTouchBegan) forControlEvents:UIControlEventTouchDragEnter];
	[_backgroundView addTarget:self action:@selector(cancelButtonTouchEnded) forControlEvents:UIControlEventTouchDragExit];
	[_backgroundView addTarget:self action:@selector(cancelButtonTouchEnded) forControlEvents:UIControlEventTouchCancel];
	[_backgroundView addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_backgroundView];
	
	_cancelButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_cancelButton.frame = CGRectMake(0, _contentView.frame.size.height - 53.f, _contentView.frame.size.width, 53.f);
	_cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_cancelButton.titleLabel.font = [UIFont systemFontOfSize:23.f];
	[_cancelButton setTitle:L18N(@"Cancel") forState:UIControlStateNormal];
	[_cancelButton addTarget:self action:@selector(cancelButtonTouchBegan) forControlEvents:UIControlEventTouchDown];
	[_cancelButton addTarget:self action:@selector(cancelButtonTouchBegan) forControlEvents:UIControlEventTouchDragEnter];
	[_cancelButton addTarget:self action:@selector(cancelButtonTouchEnded) forControlEvents:UIControlEventTouchDragExit];
	[_cancelButton addTarget:self action:@selector(cancelButtonTouchEnded) forControlEvents:UIControlEventTouchCancel];
	[_cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[_contentView addSubview:_cancelButton];
	
	NSMutableArray *newSections = [NSMutableArray array];
	
	CGFloat top = 0;
	CGFloat height = [HBAPActivitySectionView height];
	
	for (NSString *key in _items.allKeys) {
		HBAPActivitySectionView *sectionView = [[[HBAPActivitySectionView alloc] initWithFrame:CGRectMake(0, top, _contentView.frame.size.width, height) title:key items:_items[key]] autorelease];
		[_contentView addSubview:sectionView];
		[newSections addObject:sectionView];
		
		top += height;
	}
	
	_sections = [newSections copy];
	
	[self setupTheme];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTheme) name:HBAPThemeChanged object:nil];
}

- (void)setupTheme {
	if (!IS_IPAD) {
		_contentView.backgroundColor = [[HBAPThemeManager sharedInstance].backgroundColor colorWithAlphaComponent:0.95f];
	}
	
	_backgroundView.backgroundColor = [[HBAPThemeManager sharedInstance].dimTextColor colorWithAlphaComponent:0.25f];
	
	[_cancelButton setTitleColor:[HBAPThemeManager sharedInstance].tintColor forState:UIControlStateNormal];
}

#pragma mark - Show/hide

- (void)didMoveToParentViewController:(UIViewController *)parent {
	[super didMoveToParentViewController:parent];
	
	if (!IS_IPAD) {
		CGRect contentFrame = _contentView.frame;
		contentFrame.origin.y = self.view.frame.size.height;
		contentFrame.size.height = ((CGFloat)_items.allKeys.count * [HBAPActivitySectionView height]) + _cancelButton.frame.size.height;
		_contentView.frame = contentFrame;
		
		CGRect backgroundFrame = _backgroundView.frame;
		backgroundFrame.size.height = self.view.frame.size.height;
		_backgroundView.frame = backgroundFrame;
		
		_backgroundView.alpha = 0;
		
		[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
			_backgroundView.alpha = 1;
			
			CGRect contentFrame = _contentView.frame;
			contentFrame.origin.y -= contentFrame.size.height;
			_contentView.frame = contentFrame;
			
			CGRect backgroundFrame = _backgroundView.frame;
			backgroundFrame.size.height = contentFrame.origin.y;
			_backgroundView.frame = backgroundFrame;
		} completion:NULL];
	}
}

- (void)presentInViewController:(UIViewController *)viewController frame:(CGRect)frame {
	if (_isVisible) {
		HBLogWarn(@"presentInViewController:frame: called when visible");
		return;
	}
	
	_isVisible = YES;
	
	if (IS_IPAD) {
		_activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:self];
		[_activityPopoverController presentPopoverFromRect:frame inView:viewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		UIViewController *rootViewController = ((HBAPAppDelegate *)[UIApplication sharedApplication].delegate).rootViewController;
		
		[rootViewController addChildViewController:self];
		[rootViewController.view addSubview:self.view];
		[self didMoveToParentViewController:rootViewController];
	}
}

- (void)dismissAnimated:(BOOL)animated {
	if (!_isVisible) {
		HBLogWarn(@"dismissAnimated: called when not visible");
		return;
	}
	
	_isVisible = NO;
	
	if (IS_IPAD) {
		[_activityPopoverController dismissPopoverAnimated:animated];
		[_activityPopoverController release];
		_activityPopoverController = nil;
	} else {
		void (^completion)(BOOL finished) = ^(BOOL finished) {
			[self removeFromParentViewController];
			[self.view removeFromSuperview];
		};
		
		if (animated) {
			[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
				_backgroundView.alpha = 0;
				
				CGRect contentFrame = _contentView.frame;
				contentFrame.origin.y += contentFrame.size.height;
				_contentView.frame = contentFrame;
				
				CGRect backgroundFrame = _backgroundView.frame;
				backgroundFrame.size.height += contentFrame.size.height;
				_backgroundView.frame = backgroundFrame;
			} completion:completion];
		} else {
			completion(YES);
		}
	}
}

#pragma mark - Cancel button

- (void)cancelButtonTouchBegan {
	[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
		_cancelButton.backgroundColor = [self.class cancelButtonSelectionColor];
	} completion:NULL];
}

- (void)cancelButtonTouchEnded {
	[UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseOut animations:^{
		_cancelButton.backgroundColor = nil;
	} completion:NULL];
}

- (void)cancelButtonTapped {
	[self dismissAnimated:YES];
}

#pragma mark - Memory management

- (void)dealloc {
	[_items release];
	[_activityPopoverController release];
	
	[super dealloc];
}

@end
