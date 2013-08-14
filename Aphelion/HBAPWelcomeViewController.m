//
//  HBAPWelcomeViewController.m
//  Aphelion
//
//  Created by Adam D on 24/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPWelcomeViewController.h"
#import "HBAPImportAccountViewController.h"
#import <Accounts/Accounts.h>

@interface HBAPWelcomeViewController () {
	UIView *_containerView;
	UILabel *_welcomeLabel;
	UIButton *_signInButton;
	UIPopoverController *_importPopoverController;
}

@end

@implementation HBAPWelcomeViewController

- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
	_containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	_welcomeLabel = [[UILabel alloc] init];
	_welcomeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_welcomeLabel.text = L18N(@"Welcome to Aphelion");
	_welcomeLabel.font = [UIFont systemFontOfSize:IS_IPAD ? 45.f : 30.f];
	_welcomeLabel.textAlignment = NSTextAlignmentCenter;
	[_welcomeLabel sizeToFit];
	_welcomeLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, _welcomeLabel.frame.size.height);
	[_containerView addSubview:_welcomeLabel];
	
	// _signInButton = [[UIButton alloc] initWithFrame:CGRectMake(10.f, _welcomeLabel.frame.size.height + 20.f, self.view.frame.size.width - 20.f, _welcomeLabel.frame.size.height)];
	_signInButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	_signInButton.frame = CGRectMake(10.f, _welcomeLabel.frame.size.height + 20.f, self.view.frame.size.width - 20.f, _welcomeLabel.frame.size.height);
	_signInButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[_signInButton setTitle:L18N(@"Sign In") forState:UIControlStateNormal];
	_signInButton.titleLabel.font = [UIFont systemFontOfSize:IS_IPAD ? 35.f : 25.f];
	[_signInButton addTarget:self action:@selector(signInTapped) forControlEvents:UIControlEventTouchUpInside];
	[_containerView addSubview:_signInButton];
	
	[self.view addSubview:_containerView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	CGRect frame = _containerView.frame;
	frame.size.height = _signInButton.frame.origin.y + _signInButton.frame.size.height;
	_containerView.frame = frame;
	
	_containerView.center = CGPointMake(_containerView.center.x, self.view.center.y);
}

- (void)signInTapped {
	ACAccountStore *store = [[[ACAccountStore alloc] init] autorelease];
	
	[store requestAccessToAccountsWithType:[store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]
#ifdef THEOS
	withCompletionHandler:
#else
	options:nil completion:
#endif
	^(BOOL granted, NSError *error) {
		if (granted && !error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				HBAPImportAccountViewController *importViewController = [[[HBAPImportAccountViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
				
				if (IS_IPAD) {
					UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:importViewController] autorelease];
					_importPopoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
					importViewController.importPopoverController = _importPopoverController;
					importViewController.welcomeViewController = self;
					[_importPopoverController presentPopoverFromRect:CGRectMake(10.f, _containerView.frame.origin.y + _signInButton.frame.origin.y, _signInButton.frame.size.width, _signInButton.frame.size.height) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
				} else {
					[self.navigationController pushViewController:importViewController animated:YES];
				}
			});
		} else {
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:L18N(@"Access to your Twitter accounts is required to sign in.") message:L18N(@"Please use the iOS Settings app to allow Aphelion to access your Twitter accounts.") delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
			[alertView show];
		}
	}];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if (_importPopoverController && _importPopoverController.isPopoverVisible) {
		[_importPopoverController dismissPopoverAnimated:NO];
		[self signInTapped];
	}
}

- (void)dealloc {
	[_containerView release];
	[_welcomeLabel release];
	[_signInButton release];
	[_importPopoverController release];
	
	[super dealloc];
}

@end
