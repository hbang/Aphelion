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

@interface HBAPImportAccountViewController () {
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
	
	[self loadAccounts];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountStoreDidChange) name:ACAccountStoreDidChangeNotification object:nil];
}

- (void)addAllTapped {
	for (unsigned i = 0; i < _selectedAccounts.count; i++) {
		_selectedAccounts[i] = @YES;
	}
	
	[self doneTapped];
}

- (void)doneTapped {
	for (unsigned i = 0; i < _selectedAccounts.count; i++) {
		if (((NSNumber *)_selectedAccounts[i]).boolValue) {
			[_accountsDefaults addObject:((ACAccount *)_accounts[i]).identifier];
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:_accountsDefaults forKey:@"accounts"];
	
	if (IS_IPAD) {
		[_importPopoverController dismissPopoverAnimated:NO];
		[_welcomeViewController dismissViewControllerAnimated:YES completion:NULL];
	} else {
		[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
	}
	
	[((HBAPAppDelegate *)[UIApplication sharedApplication].delegate) performFirstRunTutorial];
}

#pragma mark - Account store stuff

- (void)loadAccounts {
	_accountsDefaults = [[[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"] mutableCopy] ?: [[NSMutableArray alloc] init];
	_selectedAccounts = [[NSMutableArray alloc] init];
	
	ACAccountStore *store = [[[ACAccountStore alloc] init] autorelease];
	_accounts = [[store accountsWithAccountType:[store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]] retain];
	
	for (unsigned i = 0; i < _accounts.count; i++) {
		[_selectedAccounts addObject:@NO];
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
	
	cell.textLabel.text = [@"@" stringByAppendingString:((ACAccount *)_accounts[indexPath.row]).username];
	cell.accessoryType = ((NSNumber *)_selectedAccounts[indexPath.row]).boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	_selectedAccounts[indexPath.row] = @(!((NSNumber *)_selectedAccounts[indexPath.row]).boolValue);
	cell.accessoryType = ((NSNumber *)_selectedAccounts[indexPath.row]).boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return L18N(@"Use the iOS Settings app to add more Twitter accounts.");
}

#pragma mark - Memory management

- (void)dealloc {
	[_accounts release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

@end
