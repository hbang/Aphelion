//
//  HBAPWelcomeViewController.m
//  Aphelion
//
//  Created by Adam D on 24/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPWelcomeViewController.h"
#import "HBAPImportAccountController.h"
#import <Accounts/Accounts.h>

typedef NS_ENUM(NSUInteger, HBAPImportAccountState) {
	HBAPImportAccountStateWaiting,
	HBAPImportAccountStateImporting,
	HBAPImportAccountStateError,
	HBAPImportAccountStateDone
};

@interface HBAPWelcomeViewController () {
	UIView *_containerView;
	UILabel *_detailLabel;
	UIButton *_button;
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
	
	UIImageView *iconImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bigicon"]] autorelease];
	iconImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	iconImageView.center = CGPointMake(self.view.frame.size.width / 2, iconImageView.center.y);
	[_containerView addSubview:iconImageView];
	
	UILabel *welcomeLabel = [[[UILabel alloc] init] autorelease];
	welcomeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	welcomeLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:IS_IPAD ? 45.f : 30.f];
	welcomeLabel.textAlignment = NSTextAlignmentCenter;
	welcomeLabel.text = L18N(@"Welcome to Aphelion");
	[welcomeLabel sizeToFit];
	welcomeLabel.frame = CGRectMake(0, iconImageView.frame.size.height + 20.f, self.view.frame.size.width, welcomeLabel.frame.size.height);
	[_containerView addSubview:welcomeLabel];
	
	_detailLabel = [[UILabel alloc] init];
	_detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_detailLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontWithSize:IS_IPAD ? 20.f : 16.f];
	_detailLabel.textAlignment = NSTextAlignmentCenter;
	_detailLabel.numberOfLines = 0;
	_detailLabel.text = L18N(@"Aphelion will import the Twitter accounts you have added in the iOS Settings app.\nTap Sign In to authorize Aphelion to access these accounts.");
	_detailLabel.frame = CGRectMake(15.f, welcomeLabel.frame.origin.y + welcomeLabel.frame.size.height + 20.f, self.view.frame.size.width - 30.f, [_detailLabel.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30.f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: _detailLabel.font } context:nil].size.height);
	[_containerView addSubview:_detailLabel];
	
	_button = [[UIButton buttonWithType:UIButtonTypeSystem] retain];
	_button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_button.titleLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] fontWithSize:IS_IPAD ? 35.f : 25.f];
	_button.frame = CGRectMake(0, _detailLabel.frame.origin.y + _detailLabel.frame.size.height + 20.f, self.view.frame.size.width, [@" " sizeWithAttributes:@{ NSFontAttributeName: _button.titleLabel.font }].height);
	[_button setTitle:L18N(@"Sign In") forState:UIControlStateNormal];
	[_button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
	[_containerView addSubview:_button];
	
	[self.view addSubview:_containerView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	CGRect frame = _containerView.frame;
	frame.size.height = _button.frame.origin.y + _button.frame.size.height;
	_containerView.frame = frame;
	
	_containerView.center = CGPointMake(_containerView.center.x, (self.view.frame.size.height + self.navigationController.navigationBar.frame.size.height) / 2);
}

- (void)buttonTapped {
	
}

- (void)beginImport {
	[_button setTitle:L18N(@"Importing Accounts") forState:UIControlStateNormal];
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
	[_button release];
	
	[super dealloc];
}

@end
