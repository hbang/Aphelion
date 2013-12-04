//
//  HBAPActivityViewController.m
//  Aphelion
//
//  Created by Adam D on 4/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPActivityViewController.h"
#import "HBAPThemeManager.h"

@interface HBAPActivityViewController () {
	BOOL _isVisible;
	
	UIPopoverController *_activityPopoverController;
	UIView *_contentView;
}

@end

@implementation HBAPActivityViewController

- (void)loadView {
	[super loadView];
	
	[self setupTheme];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTheme) name:HBAPThemeChanged object:nil];
}

- (void)setupTheme {
	self.view.backgroundColor = [[HBAPThemeManager sharedInstance].backgroundColor colorWithAlphaComponent:0.5f];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!IS_IPAD) {
		CGRect contentFrame = _contentView.frame;
		contentFrame.origin.y = self.view.frame.size.height;
		_contentView.frame = contentFrame;
		
		UIDynamicAnimator *animator = [[[UIDynamicAnimator alloc] initWithReferenceView:self.view] autorelease];
		UISnapBehavior *snapBehavior = [[[UISnapBehavior alloc] initWithItem:_contentView snapToPoint:CGPointMake(0, self.view.frame.size.height - _contentView.frame.size.height)] autorelease];
		[animator addBehavior:snapBehavior];
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
		self.view.alpha = 0;
		
		[viewController addChildViewController:self];
		[viewController.view addSubview:self.view];
		[self didMoveToParentViewController:viewController];
		
		[UIView animateWithDuration:0.2f animations:^{
			self.view.alpha = 1;
		}];
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
	} else {
		[UIView animateWithDuration:0.2f animations:^{
			self.view.alpha = 0;
		} completion:^(BOOL finished) {
			[self removeFromParentViewController];
			[self.view removeFromSuperview];
		}];
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[_items release];
	[_activityPopoverController release];
	
	[super dealloc];
}

@end
