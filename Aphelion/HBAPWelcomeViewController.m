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
}

@end

@implementation HBAPWelcomeViewController

- (void)loadView {
	[super loadView];
	
	self.navigationController.toolbarHidden = YES;
	
	UITableView *tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped] autorelease];
	tableView.userInteractionEnabled = NO;
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:tableView];
	
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
	
	_signInButton = [[UIButton buttonWithType:UIButtonTypeSystem] retain];
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
	
	[store requestAccessToAccountsWithType:[store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter] options:nil completion:^(BOOL granted, NSError *error) {
		if (granted && !error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				HBAPImportAccountViewController *importViewController = [[[HBAPImportAccountViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
				[self.navigationController pushViewController:importViewController animated:YES];
			});
		} else {
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:L18N(@"Access to your Twitter accounts is required to sign in.") message:L18N(@"Please use the iOS Settings app to allow Aphelion to access your Twitter accounts.") delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
			[alertView show];
		}
	}];
}

- (void)dealloc {
	[_containerView release];
	[_welcomeLabel release];
	[_signInButton release];
	
	[super dealloc];
}

@end
