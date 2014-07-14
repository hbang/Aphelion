//
//  HBAPRootViewControllerIPhone.m
//  Aphelion
//
//  Created by Adam D on 6/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPRootViewControllerIPhone.h"
#import "HBAPNavigationController.h"
#import "HBAPHomeTimelineViewController.h"
#import "HBAPMentionsTimelineViewController.h"
#import "HBAPMessagesViewController.h"
#import "HBAPProfileViewController.h"
#import "HBAPSearchTimelineViewController.h"
#import "HBAPPreferencesViewController.h"
#import "HBAPAccountController.h"
#import "HBAPAccount.h"
#import "HBAPBottomMenuView.h"
#import <FXBlurView/FXBlurView.h>

@interface HBAPRootViewControllerIPhone () {
	HBAPNavigationController *_navigationController;
	
	HBAPHomeTimelineViewController *_homeViewController;
	HBAPMentionsTimelineViewController *_mentionsViewController;
	HBAPMessagesViewController *_messagesViewController;
	HBAPProfileViewController *_profileViewController;
	HBAPSearchTimelineViewController *_searchViewController;
	HBAPPreferencesViewController *_preferencesViewController;
}

@end

/*
 sidebar_home_selected
		_mentions
		_messages
		_user
		_search
		_settings
*/

@implementation HBAPRootViewControllerIPhone

- (instancetype)initWithAccount:(HBAPAccount *)account {
	self = [super init];
	
	if (self) {
		_account = [account copy];
	}
	
	return self;
}

#pragma mark - UIViewController

- (void)loadView {
	[super loadView];
	
	_navigationController = [[HBAPNavigationController alloc] init];
	
	_homeViewController = [[HBAPHomeTimelineViewController alloc] init];
	_mentionsViewController = [[HBAPMentionsTimelineViewController alloc] init];
	_messagesViewController = [[HBAPMessagesViewController alloc] init];
	_profileViewController = [[HBAPProfileViewController alloc] init];
	_searchViewController = [[HBAPSearchTimelineViewController alloc] init];
	_preferencesViewController = [[HBAPPreferencesViewController alloc] initWithStyle:UITableViewStyleGrouped];
	
	UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
	containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:containerView];
	
	[_navigationController willMoveToParentViewController:self];
	[containerView addSubview:_navigationController.view];
	[_navigationController didMoveToParentViewController:self];
	
	HBAPBottomMenuView *menuView = [[[HBAPBottomMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 200.f, self.view.frame.size.width, 200.f)] autorelease];
	menuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	menuView.containerView = containerView;
	[self.view addSubview:menuView];
}

#pragma mark - Switching

- (void)initialSetup {
	[self switchToViewController:_homeViewController animated:NO];
}

- (void)switchToViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if (!animated) {
		_navigationController.viewControllers = @[ viewController ];
		return;
	}
	
	// TODO: use view controller transitions
	
	UIView *oldSnapshotView = [_navigationController.view snapshotViewAfterScreenUpdates:NO];
	[self.view addSubview:oldSnapshotView];
	
	FXBlurView *blurView = [[[FXBlurView alloc] initWithFrame:oldSnapshotView.frame] autorelease];
	blurView.tintColor = [UIColor colorWithWhite:0 alpha:0.1f];
	blurView.dynamic = NO;
	[oldSnapshotView addSubview:blurView];
	
	_navigationController.viewControllers = @[ viewController ];
	
	UIView *newSnapshotView = [_navigationController.view snapshotViewAfterScreenUpdates:NO];
	[self.view addSubview:newSnapshotView];
	
	__block CGRect newSnapshotFrame = newSnapshotView.frame;
	newSnapshotFrame.origin.x -= newSnapshotFrame.size.width / 2;
	newSnapshotView.frame = newSnapshotFrame;
	
	_navigationController.view.hidden = YES;
	_navigationController.view.alpha = 0;
	
	[UIView animateWithDuration:0.15 animations:^{
		blurView.alpha = 0;
	}];
	
	[UIView animateWithDuration:0.25 animations:^{
		oldSnapshotView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
		oldSnapshotView.alpha = 0;
		_navigationController.view.alpha = 1;
	} completion:^(BOOL finished) {
		[oldSnapshotView removeFromSuperview];
		[blurView removeFromSuperview];
	}];
	
	[UIView animateWithDuration:0.3 animations:^{
		newSnapshotFrame.origin.x = 0;
		newSnapshotView.frame = newSnapshotFrame;
	} completion:^(BOOL finished) {
		[newSnapshotView removeFromSuperview];
		_navigationController.view.hidden = NO;
	}];
}

#pragma mark - Memory management

- (void)dealloc {
	[_account release];
	
	[_navigationController release];
	[_homeViewController release];
	[_mentionsViewController release];
	[_messagesViewController release];
	[_profileViewController release];
	[_searchViewController release];
	[_preferencesViewController release];
	
	[super dealloc];
}

@end
