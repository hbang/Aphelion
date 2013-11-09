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

- (void)_loadUserID:(NSString *)userID {
	_isLoading = YES;
	
	[HBAPUser userWithUserID:userID callback:^(HBAPUser *user) {
		_user = [user retain];
		_isLoading = NO;
		
		[self.tableView reloadData];
	}];
}

- (void)loadView {
	[super loadView];
	
	if (!_user && !_isLoading) {
		HBLogError(@"no user provided");
	}
	
	self.title = L18N(@"Profile");
	self.tableView.backgroundColor = _user.profileBackgroundColor ?: [UIColor whiteColor];
}

- (instancetype)initWithUserID:(NSString *)userID {
	self = [super init];
	
	if (self) {
		[self _loadUserID:userID];
	}
	
	return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _isLoading ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
		{
			if (_isLoading) {
				static NSString *CellIdentifier = @"LoadingCell";
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
				
				if (!cell) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.textLabel.text = L18N(@"Loading…");
					cell.textLabel.textAlignment = NSTextAlignmentCenter;
				}
				
				return cell;
			} else {
				static NSString *CellIdentifier = @"HeaderCell";
				HBAPProfileHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
				
				if (!cell) {
					cell = [[[HBAPProfileHeaderTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
					cell.user = _user;
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
				}
				
				return cell;
			}
			break;
		}
		
		case 1:
		{
			static NSString *CellIdentifier = @"BioCell";
			HBAPProfileBioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (!cell) {
				cell = [[[HBAPProfileBioTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
				//cell.user = _user;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				// TODO: this
				cell.textLabel.text = _user.bio;
				cell.textLabel.numberOfLines = 0;
				cell.textLabel.font = [HBAPTweetTableViewCell contentTextViewFont];
			}
			
			return cell;
			break;
		}
	}

	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [HBAPProfileHeaderTableViewCell cellHeight];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
