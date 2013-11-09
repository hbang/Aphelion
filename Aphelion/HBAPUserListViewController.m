//
//  HBAPUserListViewController.m
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPUserListViewController.h"
#import "HBAPUserTableViewCell.h"

@interface HBAPUserListViewController ()

@end

@implementation HBAPUserListViewController

- (void)loadView {
	[super loadView];
	
	_users = [[NSMutableArray alloc] init];

	self.title = @"Wat.";
	self.tableView.rowHeight = 62.f;
	
	if (!IS_IPAD) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped)];
	}
}

- (void)cancelTapped {
	[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)updateContentSize {
	self.preferredContentSize = CGSizeMake(320.f, _users.count * self.tableView.rowHeight);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _users && _users.count ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return _users ? _users.count : 0;
			break;
			
		case 1:
			return _users && _users.count ? 1 : 0;
			break;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
		{
			static NSString *CellIdentifier = @"AccountCell";
			HBAPUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

			if (!cell) {
				cell = [[[HBAPUserTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
			}
			
			cell.user = _users[indexPath.row];

			return cell;
			break;
		}
		
		case 1:
		{
			static NSString *CellIdentifier = @"NoneCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (!cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.textAlignment = NSTextAlignmentCenter;
			}
			
			cell.textLabel.text = _noUsersString;
			
			return cell;
			break;
		}
	}

	return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
