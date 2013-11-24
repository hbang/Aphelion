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
#import "HBAPProfileDataTableViewCell.h"
#import "HBAPThemeManager.h"
#import "HBAPDominantColor.h"
#import "HBAPFontManager.h"

@interface HBAPProfileViewController () {
	HBAPUser *_user;
	BOOL _isLoading;
	CGFloat _bioHeight;
	BOOL _backgroundIsDark;
	
	NSString *_tweetCount;
	NSString *_followerCount;
	NSString *_followingCount;
	NSString *_favoriteCount;
	NSString *_listedCount;
	NSString *_userID;
	NSString *_creationDateString;
	NSString *_theirDateString;
}

@end

@implementation HBAPProfileViewController

#pragma mark - Constants

+ (UIColor *)footerLabelColorDark {
	return [UIColor colorWithWhite:0.5f alpha:0.8f];
}

+ (UIColor *)footerLabelColorLight {
	return [UIColor colorWithWhite:0.25f alpha:0.8f];
}

#pragma mark - Implementation

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
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)_loadUserID:(NSString *)userID {
	_isLoading = YES;
	
	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	numberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
	numberFormatter.groupingSeparator = @",";
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	dateFormatter.dateStyle = NSDateFormatterMediumStyle;
	dateFormatter.timeStyle = NSDateFormatterShortStyle;
	
	[HBAPUser userWithUserID:userID callback:^(HBAPUser *user) {
		_user = [user retain];
		_isLoading = NO;
		_bioHeight = [HBAPProfileBioTableViewCell heightForUser:_user tableView:self.tableView];
		_backgroundIsDark = [HBAPDominantColor isDarkColor:_user.profileBackgroundColor];
		
		_tweetCount = [[numberFormatter stringFromNumber:@(_user.tweetCount)] retain];
		_followerCount = [[numberFormatter stringFromNumber:@(_user.followerCount)] retain];
		_followingCount = [[numberFormatter stringFromNumber:@(_user.followingCount)] retain];
		_favoriteCount = [[numberFormatter stringFromNumber:@(_user.favoriteCount)] retain];
		_listedCount = [[numberFormatter stringFromNumber:@(_user.listedCount)] retain];
		_userID = [[numberFormatter stringFromNumber:@(_user.userID.longLongValue)] retain];
		_creationDateString = [[dateFormatter stringFromDate:_user.creationDate] retain];
		
		if (_user.timezone) {
			dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:_user.timezoneOffset];
			dateFormatter.dateStyle = NSDateFormatterShortStyle;
			_theirDateString = [[dateFormatter stringFromDate:[NSDate date]] retain];
		}
		
		self.tableView.backgroundColor = _user.profileBackgroundColor ?: [UIColor whiteColor];
		[self.tableView reloadData];
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
		case 1:
		default:
			return 1;
			break;
		
		case 2:
			return 6;
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
			static NSString *CellIdentifier = @"TimelineCell";
			HBAPProfileDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (!cell) {
				cell = [[[HBAPProfileDataTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
			}
			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.tintColor = _user.profileLinkColor;
			
			switch (indexPath.row) {
				case 0:
					cell.titleLabel.text = L18N(@"location");
					cell.valueLabel.text = _user.location ?: L18N(@"Unknown");
					cell.valueLabel.textColor = [[HBAPThemeManager sharedInstance].textColor colorWithAlphaComponent:_user.location ? 1 : 0.7];
					cell.accessoryType = _user.location ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
					break;
				
				case 1:
					cell.titleLabel.text = L18N(@"url");
					cell.valueLabel.text = _user.url ? _user.displayURL : L18N(@"None");
					cell.valueLabel.textColor = [[HBAPThemeManager sharedInstance].textColor colorWithAlphaComponent:_user.url ? 1 : 0.7];
					cell.accessoryType = _user.url ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
					break;
				
				case 2:
					cell.titleLabel.text = L18N(@"tweets");
					cell.valueLabel.text = _tweetCount;
					break;
				
				case 3:
					cell.titleLabel.text = L18N(@"followers");
					cell.valueLabel.text = _followerCount;
					break;
				
				case 4:
					cell.titleLabel.text = L18N(@"following");
					cell.valueLabel.text = _followingCount;
					break;
				
				case 5:
					cell.titleLabel.text = L18N(@"favorites");
					cell.valueLabel.text = _favoriteCount;
					break;
				
				case 6:
					cell.titleLabel.text = L18N(@"listed");
					cell.valueLabel.text = _listedCount;
					break;
			}
			
			return cell;
			break;
		}
		
		case 3:
		{
			static NSString *CellIdentifier = @"FooterCell";
			HBAPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (!cell) {
				cell = [[[HBAPTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.backgroundColor = nil;
				cell.textLabel.font = [HBAPFontManager sharedInstance].footerFont;
				cell.textLabel.textAlignment = NSTextAlignmentCenter;
				cell.textLabel.numberOfLines = 0;
			}
			
			if (_user) {
				cell.textLabel.textColor = _backgroundIsDark ? [self.class footerLabelColorDark] : [self.class footerLabelColorLight];
				cell.textLabel.text = _user.timezone ? [NSString stringWithFormat:L18N(@"Time Zone: %@ (Currently %@)\nRegistered: %@\nUser ID: #%@"), _user.timezone, _theirDateString, _creationDateString, _userID] : [NSString stringWithFormat:L18N(@"Time Zone: Unknown\nRegistered: %@\nUser ID: #%@"), _creationDateString, _userID];
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
			return _bioHeight;
			break;
		
		case 2:
		default:
			return 44.f;
			break;
		
		case 3:
			return [@" \n \n " sizeWithAttributes:@{ NSFontAttributeName: [HBAPFontManager sharedInstance].footerFont }].height + 30.f;
			break;
	}
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
