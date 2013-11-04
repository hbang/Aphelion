//
//  HBAPAccountSwitchViewController.m
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAccountSwitchViewController.h"
#import "HBAPAccountController.h"
#import "HBAPAccount.h"
#import "HBAPUser.h"

@interface HBAPAccountSwitchViewController () {
	NSUInteger _currentAccountIndex;
}

@end

@implementation HBAPAccountSwitchViewController

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Accounts");
	
	NSString *currentUserID = [HBAPAccountController sharedInstance].accountForCurrentUser.userID;
	NSUInteger i = 0;

	for (HBAPAccount *account in [HBAPAccountController sharedInstance].allAccounts) {
		[self.users addObject:account.user];
		
		if (account.user.userID == currentUserID) {
			_currentAccountIndex = i;
		}
		
		i++;
	}
	
	[self updateContentSize];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	cell.accessoryType = indexPath.row == _currentAccountIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didDeselectRowAtIndexPath:indexPath];
}

@end
