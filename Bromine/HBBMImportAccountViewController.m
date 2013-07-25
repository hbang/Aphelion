//
//  HBBMImportAccountViewController.m
//  Bromine
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBBMImportAccountViewController.h"
#import <Accounts/Accounts.h>

@interface HBBMImportAccountViewController () {
	NSArray *_accounts;
	NSMutableArray *_selectedAccounts;
}

@end

@implementation HBBMImportAccountViewController
@synthesize importPopoverController = _importPopoverController;

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
			[self importAccountAtIndex:i];
		}
	}
	
	if (IS_IPAD) {
		[_importPopoverController dismissPopoverAnimated:YES];
		[self.parentViewController dismissViewControllerAnimated:YES completion:NULL];
	} else {
		[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
	}
}

#pragma mark - Account store stuff

- (void)loadAccounts {
	ACAccountStore *store = [[[ACAccountStore alloc] init] autorelease];
	_accounts = [store accountsWithAccountType:[store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
	_selectedAccounts = [[NSMutableArray alloc] init];
	
	for (unsigned i = 0; i < _accounts.count; i++) {
		[_selectedAccounts addObject:@NO];
	}
}

- (void)importAccountAtIndex:(unsigned)index {
	// TODO: this
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
		cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	}
	
	cell.textLabel.text = [@"@" stringByAppendingString:((ACAccount *)_accounts[indexPath.row]).username];
	NSLog(@"%i %@",indexPath.row,_selectedAccounts[indexPath.row]);
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
