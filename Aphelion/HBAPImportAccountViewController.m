//
//  HBAPImportAccountViewController.m
//  Aphelion
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPImportAccountViewController.h"
#import <Accounts/Accounts.h>
#import "HBAPAppDelegate.h"
#import "HBAPTwitterAPIRequest.h"
#import "HBAPTutorialViewController.h"

@interface HBAPImportAccountViewController () {
	ACAccountStore *_accountStore;
	NSArray *_accounts;
	NSMutableArray *_selectedAccounts;
	NSMutableArray *_accountsDefaults;
}

@end

@implementation HBAPImportAccountViewController
@synthesize importPopoverController = _importPopoverController, welcomeViewController = _welcomeViewController;

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Add Accounts");
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:L18N(@"Add All") style:UIBarButtonItemStyleBordered target:self action:@selector(addAllTapped)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)] autorelease];
	
	self.tableView.backgroundColor = [UIColor whiteColor];
	
	_accountStore = [[ACAccountStore alloc] init];
	
	[self loadAccounts];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountStoreDidChange) name:ACAccountStoreDidChangeNotification object:nil];
}

- (void)addAllTapped {
	for (unsigned i = 0; i < _selectedAccounts.count; i++) {
		// _selectedAccounts[i] = @YES;
		[_selectedAccounts replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
	}
	
	[self doneTapped];
}

- (void)doneTapped {
	unsigned numberOfAccounts = 0;
	
	for (unsigned i = 0; i < _selectedAccounts.count; i++) {
		// if (((NSNumber *)_selectedAccounts[i]).boolValue) {
		if (((NSNumber *)[_selectedAccounts objectAtIndex:i]).boolValue) {
			numberOfAccounts++;
			
			// [_accountsDefaults addObject:((ACAccount *)_accounts[i]).identifier];
			[_accountsDefaults addObject:((ACAccount *)[_accounts objectAtIndex:i]).identifier];
		}
	}
	
	if (numberOfAccounts == 0) {
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:L18N(@"No accounts selected.") message:L18N(@"At least one of your Twitter accounts must be imported to use Aphelion.\n\nDon’t have any Twitter accounts set up on your device? Tap the “Settings” icon on your home screen, followed by “Twitter”.") delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
		[alertView show];
		
		return;
	}
	
	// [[NSUserDefaults standardUserDefaults] setObject:_accountsDefaults forKey:@"accounts"];
	
	/*dispatch_async(dispatch_whatever(), ^{
		HBAPTwitterAPIRequest *partOneRequest = [HBAPTwitterAPIRequest requestWithPath:@"/oauth/request_token" sendAutomatically:NO completion:^(NSData *data, NSError *error) {
			// ...
		}];
	});*/NSLog(@"shit");
	
	/* COPY/PASTE FROM TWITTERS DOCS FOR REFERENCE
	//  Assume that we stored the result of Step 1 into a var 'resultOfStep1'
	NSString *S = resultOfStep1;
	NSDictionary *step2Params = [[NSMutableDictionary alloc] init];
	[step2Params setValue:@"JP3PyvG67rXRsnayOJOcQ" forKey:@"x_reverse_auth_target"];
	[step2Params setValue:S forKey:@"x_reverse_auth_parameters"];			
	 
	NSURL *url2 = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
	SLRequest *stepTwoRequest = 
	[SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url2 parameters:step2Params];
	 
	//  You *MUST* keep the ACAccountStore alive for as long as you need an ACAccount instance
	//  See WWDC 2011 Session 124 for more info.
	self.accountStore = [[ACAccountStore alloc] init];
	 
	//  We only want to receive Twitter accounts
	ACAccountType *twitterType = 
	[self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	 
	//  Obtain the user's permission to access the store
	[self.accountStore requestAccessToAccountsWithType:twitterType 
	withCompletionHandler:^(BOOL granted, NSError *error) {
		if (!granted) {
			// handle this scenario gracefully
		} else {
			// obtain all the local account instances
			NSArray *accounts = 
			[self.accountStore accountsWithAccountType:twitterType];
	 
			// for simplicity, we will choose the first account returned - in your app,
			// you should ensure that the user chooses the correct Twitter account
			// to use with your application.  DO NOT FORGET THIS STEP.
			[stepTwoRequest setAccount:[accounts objectAtIndex:0]];
	 
			// execute the request
			[stepTwoRequest performRequestWithHandler:
	^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
				NSString *responseStr = 
				[[NSString alloc] initWithData:responseData 
	encoding:NSUTF8StringEncoding];
	 
							// see below for an example response
							NSLog(@"The user's info for your server:\n%@", responseStr);
			}];
		} 
	}];
	*/
	
	HBAPTutorialViewController *tutorialViewController = [[[HBAPTutorialViewController alloc] init] autorelease];
	tutorialViewController.isFirstRun = YES;
	[self.navigationController pushViewController:tutorialViewController animated:YES];
}

#pragma mark - Account store stuff

- (void)loadAccounts {
	_accountsDefaults = [[[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"] mutableCopy] ?: [[NSMutableArray alloc] init];
	_selectedAccounts = [[NSMutableArray alloc] init];
	
	_accounts = [[_accountStore accountsWithAccountType:[_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]] retain];
	
	for (unsigned i = 0; i < _accounts.count; i++) {
		// [_selectedAccounts addObject:@NO];
		[_selectedAccounts addObject:[NSNumber numberWithBool:NO]];
	}
}

- (void)accountStoreDidChange {
	[self loadAccounts];
	[self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsunsignedableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"AccountCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		#ifndef THEOS
		cell.selectionStyle = UITableViewCellSelectionStyleDefault;
		#endif
	}
	
	// cell.textLabel.text = [@"@" stringByAppendingString:((ACAccount *)_accounts[indexPath.row]).username];
	cell.textLabel.text = [@"@" stringByAppendingString:((ACAccount *)[_accounts objectAtIndex:indexPath.row]).username];
	cell.accessoryType = ((NSNumber *)[_selectedAccounts objectAtIndex:indexPath.row]).boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	// _selectedAccounts[indexPath.row] = @(!((NSNumber *)_selectedAccounts[indexPath.row]).boolValue);
	[_selectedAccounts replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:!((NSNumber *)[_selectedAccounts objectAtIndex:indexPath.row]).boolValue]];
	cell.accessoryType = ((NSNumber *)[_selectedAccounts objectAtIndex:indexPath.row]).boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return L18N(@"Use the iOS Settings app to add more Twitter accounts.");
}

#pragma mark - Memory management

- (void)dealloc {
	[_accountStore release];
	[_accounts release];
	[_selectedAccounts release];
	[_accountsDefaults release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

@end
