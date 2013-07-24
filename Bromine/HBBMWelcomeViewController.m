//
//  HBBMWelcomeViewController.m
//  Bromine
//
//  Created by Adam D on 24/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBBMWelcomeViewController.h"
#import "HBBMImportAccountViewController.h"
#import <Accounts/Accounts.h>

@interface HBBMWelcomeViewController () {
	UIView *_containerView;
	UILabel *_welcomeLabel;
	UIButton *_signInButton;
}

@end

@implementation HBBMWelcomeViewController

- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
	_containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	_welcomeLabel = [[[UILabel alloc] init] autorelease];
	_welcomeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_welcomeLabel.text = L18N(@"Welcome to Bromine");
	_welcomeLabel.font = [UIFont systemFontOfSize:45.f];
	_welcomeLabel.textAlignment = NSTextAlignmentCenter;
	[_welcomeLabel sizeToFit];
	_welcomeLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, _welcomeLabel.frame.size.height);
	[_containerView addSubview:_welcomeLabel];
	
	_signInButton = [[[UIButton alloc] initWithFrame:CGRectMake(10.f, _welcomeLabel.frame.size.height + 20.f, self.view.frame.size.width - 20.f, _welcomeLabel.frame.size.height)] autorelease];
	_signInButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[_signInButton setTitle:L18N(@"Sign In") forState:UIControlStateNormal];
	_signInButton.titleLabel.font = [UIFont systemFontOfSize:35.f];
	[_signInButton setTitleColor:[UIColor colorWithRed:9.f / 255.f green:122.f / 255.f blue:1 alpha:1] forState:UIControlStateNormal];
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
	
	[store requestAccessToAccountsWithType:[store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter] options:nil completion:^(BOOL granted, NSError *error) {
		if (granted) {
			dispatch_async(dispatch_get_main_queue(), ^{
				HBBMImportAccountViewController *importViewController = [[[HBBMImportAccountViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
				UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:importViewController] autorelease];
				UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
				[popoverController presentPopoverFromRect:CGRectMake(10.f, _containerView.frame.origin.y + _signInButton.frame.origin.y, _signInButton.frame.size.width, _signInButton.frame.size.height) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			});
		} else {
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:L18N(@"Access to your Twitter accounts is required to sign in.") message:L18N(@"Please use the iOS Settings app to allow Bromine to access your Twitter accounts.") delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
			[alertView show];
		}
	}];
}

@end
