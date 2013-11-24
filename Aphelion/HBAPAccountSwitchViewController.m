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
#import "HBAPUserTableViewCell.h"

@interface HBAPAccountSwitchViewController () {
	NSUInteger _currentAccountIndex;
}

@end

@implementation HBAPAccountSwitchViewController

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Accounts");
	
	NSString *currentUserID = [HBAPAccountController sharedInstance].currentAccount.userID;
	NSDictionary *accounts = [HBAPAccountController sharedInstance].accounts;
	NSUInteger i = 0;
	
	for (NSString *userID in accounts) {
		[self.users addObject:((HBAPAccount *)accounts[userID]).user];
		
		if (((HBAPAccount *)accounts[userID]).user.userID == currentUserID) {
			_currentAccountIndex = i;
		}
		
		i++;
	}
	
	[self updateContentSize];
}

#pragma mark - UITableViewDataSource

- (HBAPUserTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HBAPUserTableViewCell *cell = (HBAPUserTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	cell.accessoryType = indexPath.row == _currentAccountIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didDeselectRowAtIndexPath:indexPath];
}

@end
