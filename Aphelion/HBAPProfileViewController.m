//
//  HBAPProfileViewController.m
//  Aphelion
//
//  Created by Adam D on 1/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPProfileViewController.h"
#import "HBAPUser.h"
#import "HBAPProfileHeaderTableViewCell.h"
#import "HBAPProfileBioTableViewCell.h"

@interface HBAPProfileViewController () {
	HBAPUser *_user;
	BOOL _isLoading;
	CGFloat _bioHeight;
}

@end

@implementation HBAPProfileViewController

- (instancetype)initWithUser:(HBAPUser *)user {
	self = [super init];
	
	if (self) {
		if (user.loadedFullProfile) {
			_user = [user retain];
		} else {
			[self _loadUserID:user.userID];
		}
	}
	
	return self;
}

- (instancetype)initWithUserID:(NSString *)userID {
	self = [super init];
	
	if (self) {
		[self _loadUserID:userID];
	}
	
	return self;
}

- (void)loadView {
	[super loadView];
	
	if (!_user && !_isLoading) {
		HBLogError(@"no user provided");
	}
	
	self.title = L18N(@"Profile");
	self.tableView.backgroundColor = _user.profileBackgroundColor ?: [UIColor whiteColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)_loadUserID:(NSString *)userID {
	_isLoading = YES;
	
	[HBAPUser userWithUserID:userID callback:^(HBAPUser *user) {
		_user = [user retain];
		_isLoading = NO;
		_bioHeight = [HBAPProfileBioTableViewCell heightForUser:_user tableView:self.tableView];
		
		[self.tableView reloadData];
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
		case 1:
		default:
			return 1;
			break;
		
		case 2:
			return 1;
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
		{
			static NSString *CellIdentifier = @"HeaderCell";
			HBAPProfileHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (!cell) {
				cell = [[[HBAPProfileHeaderTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			
			if (_user && cell.user != _user) {
				cell.user = _user;
			}
			
			return cell;
			break;
		}
		
		case 1:
		{
			static NSString *CellIdentifier = @"BioCell";
			HBAPProfileBioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (!cell) {
				cell = [[[HBAPProfileBioTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
				cell.user = _user;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			
			if (_user && cell.user != _user) {
				cell.user = _user;
			}
			
			return cell;
			break;
		}
			
		case 2:
		{
			static NSString *CellIdentifier = @"Cell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (!cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
			}
			
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = L18N(@"url");
					cell.detailTextLabel.text = _user.displayURL;
					break;
					
				case 2:
					cell.textLabel.text = L18N(@"tweets");
					cell.detailTextLabel.text = @(_user.tweetCount).stringValue;
					break;
			}
			
			return cell;
			break;
		}
	}

	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			return [HBAPProfileHeaderTableViewCell cellHeight];
			break;
		
		case 1:
			NSLog(@"%f",_bioHeight);
			return _bioHeight;
			break;
		
		case 2:
		default:
			return 44.f;
			break;
	}
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
