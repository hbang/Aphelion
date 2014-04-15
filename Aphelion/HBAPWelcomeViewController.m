//
//  HBAPWelcomeViewController.m
//  Aphelion
//
//  Created by Adam D on 24/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPWelcomeViewController.h"
#import "HBAPImportAccountController.h"
#import "HBAPFontManager.h"
#import "HBAPNavigationController.h"
#import "HBAPTutorialViewController.h"
#import "HBAPTwitterAPISessionManager.h"
#import "HBAPAccountController.h"
#import <Accounts/Accounts.h>

typedef NS_ENUM(NSUInteger, HBAPImportAccountState) {
	HBAPImportAccountStateWaiting,
	HBAPImportAccountStateImporting,
	HBAPImportAccountStateDone
};

@interface HBAPWelcomeViewController () {
	UIView *_containerView;
	UILabel *_detailLabel;
	UIButton *_button;
	UIActivityIndicatorView *_activityIndicatorView;
	HBAPImportAccountState _state;
}

@end

@implementation HBAPWelcomeViewController

#pragma mark - Constants

+ (UIColor *)buttonDisabledColor {
	return [UIColor colorWithWhite:0.5f alpha:1];
}

#pragma mark - Implementation

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
	welcomeLabel.font = [[HBAPFontManager sharedInstance].headingFont fontWithSize:IS_IPAD ? 45.f : 30.f];
	welcomeLabel.textAlignment = NSTextAlignmentCenter;
	welcomeLabel.text = L18N(@"Welcome to Aphelion");
	[welcomeLabel sizeToFit];
	welcomeLabel.frame = CGRectMake(0, iconImageView.frame.size.height + 20.f, self.view.frame.size.width, welcomeLabel.frame.size.height);
	[_containerView addSubview:welcomeLabel];
	
	_detailLabel = [[UILabel alloc] init];
	_detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_detailLabel.font = [[HBAPFontManager sharedInstance].bodyFont fontWithSize:IS_IPAD ? 20.f : 16.f];
	_detailLabel.textAlignment = NSTextAlignmentCenter;
	_detailLabel.numberOfLines = 0;
	_detailLabel.text = L18N(@"Aphelion will import the Twitter accounts you have added in the iOS Settings app.\nTap Sign In to authorize Aphelion to access these accounts.");
	_detailLabel.frame = CGRectMake(15.f, welcomeLabel.frame.origin.y + welcomeLabel.frame.size.height + 20.f, self.view.frame.size.width - 30.f, [_detailLabel.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30.f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: _detailLabel.font } context:nil].size.height);
	[_containerView addSubview:_detailLabel];
	
	_button = [[UIButton buttonWithType:UIButtonTypeSystem] retain];
	_button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_button.titleLabel.font = [[HBAPFontManager sharedInstance].subheadingFont fontWithSize:IS_IPAD ? 35.f : 25.f];
	_button.frame = CGRectMake(0, _detailLabel.frame.origin.y + _detailLabel.frame.size.height + 20.f, self.view.frame.size.width, [@" " sizeWithAttributes:@{ NSFontAttributeName: _button.titleLabel.font }].height);
	[_button setTitle:L18N(@"Sign In") forState:UIControlStateNormal];
	[_button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
	[_containerView addSubview:_button];
	
	_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_activityIndicatorView.frame = CGRectMake(0, _button.frame.origin.y + (_button.frame.size.height / 2) - (_activityIndicatorView.frame.size.height / 2), _activityIndicatorView.frame.size.width, _activityIndicatorView.frame.size.height);
	[_containerView addSubview:_activityIndicatorView];
	
	[self.view addSubview:_containerView];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	CGRect frame = _containerView.frame;
	frame.size.height = _button.frame.origin.y + _button.frame.size.height;
	_containerView.frame = frame;
	
	_containerView.center = CGPointMake(_containerView.center.x, self.view.center.y + (self.topLayoutGuide.length / 2));
}

- (void)buttonTapped {
	_button.userInteractionEnabled = NO;
	
	[UIView animateWithDuration:0.2 animations:^{
		_button.tintColor = [self.class buttonDisabledColor];
	}];
	
	[self _signIn];
}

- (void)setButtonTitle:(NSString *)title {
	[_button setTitle:title forState:UIControlStateNormal];
	
	if (_state == HBAPImportAccountStateWaiting) {
		[_activityIndicatorView stopAnimating];
		
		CGRect buttonFrame = _button.frame;
		buttonFrame.origin.x = 0;
		_button.frame = buttonFrame;
	} else {
		CGRect buttonFrame = _button.frame;
		buttonFrame.origin.x += (_activityIndicatorView.frame.size.width / 2) + 5.f;
		_button.frame = buttonFrame;
		
		CGRect indicatorFrame = _activityIndicatorView.frame;
		indicatorFrame.origin.x = (self.view.frame.size.width - [title sizeWithAttributes:@{ NSFontAttributeName: _button.titleLabel.font }].width - indicatorFrame.size.width) / 2 - 5.f;
		_activityIndicatorView.frame = indicatorFrame;
		
		if (!_activityIndicatorView.isAnimating) {
			[_activityIndicatorView startAnimating];
		}
	}
}

#pragma mark - Stages

- (void)_signIn {
	ACAccountStore *store = [[[ACAccountStore alloc] init] autorelease];
	
	[store requestAccessToAccountsWithType:[store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter] options:nil completion:^(BOOL granted, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (granted && !error) {
				[self _performAuth];
			} else {
				UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:L18N(@"Access to your Twitter accounts is required to sign in.") message:L18N(@"Please use the iOS Settings app to allow Aphelion to access your Twitter accounts.") delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
				[alertView show];
				
				[self _resetState];
			}
		});
	}];
}

- (void)_performAuth {
	_state = HBAPImportAccountStateImporting;
	
	HBAPImportAccountController *controller = [[[HBAPImportAccountController alloc] init] autorelease];
	
	if (controller.accounts.count == 0) {
		[self _resetState];
		
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:L18N(@"No Twitter accounts were found.") message:L18N(@"Please use the iOS Settings app to add a Twitter account.") delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
		[alertView show];
		
		return;
	}
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSUInteger i = 0;
		__block NSUInteger errors = 0;
		
		for (ACAccount *account in controller.accounts) {
			dispatch_async(dispatch_get_main_queue(), ^{
				self.buttonTitle = account.accountDescription;
			});
			
			dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
			
			[controller importAccount:account callback:^(NSError *error) {
				dispatch_async(dispatch_get_main_queue(), ^{
					dispatch_semaphore_signal(semaphore);
					
					if (error) {
						errors++;
						
						UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:L18N(@"Couldn’t sign in “%@”."), account.accountDescription] message:error.localizedDescription delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
						[alertView show];
					}
					
					if (i == controller.accounts.count - 1) {
						[self doneImportingWithAccounts:i + 1 errors:errors];
					}
				});
			}];
			
			dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
			
			i++;
		}
	});
}

- (void)doneImportingWithAccounts:(NSUInteger)accounts errors:(NSUInteger)errors {
	if (accounts != errors) {
		_state = HBAPImportAccountStateDone;
		self.buttonTitle = L18N(@"Done");
		
		[HBAPTwitterAPISessionManager sharedInstance].account = [HBAPAccountController sharedInstance].currentAccount;
		
		HBAPTutorialViewController *tutorialViewController = [[[HBAPTutorialViewController alloc] init] autorelease];
		[self.navigationController pushViewController:tutorialViewController animated:YES];
	} else {
		[self _resetState];
		self.buttonTitle = L18N(@"Try Again");
	}
}

- (void)_resetState {
	_state = HBAPImportAccountStateWaiting;
	
	self.buttonTitle = L18N(@"Sign In");
	
	_button.userInteractionEnabled = YES;
	
	[UIView animateWithDuration:0.2 animations:^{
		_button.tintColor = nil;
	}];
}

#pragma mark - Memory management

- (void)dealloc {
	[_containerView release];
	[_detailLabel release];
	[_button release];
	[_activityIndicatorView release];
	
	[super dealloc];
}

@end
