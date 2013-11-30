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
#import "HBAPProfileDataTableViewCell.h"
#import "HBAPProfileFooterTableViewCell.h"
#import "HBAPThemeManager.h"
#import "HBAPDominantColor.h"
#import "HBAPFontManager.h"

@interface HBAPProfileViewController () {
	HBAPUser *_user;
	BOOL _isLoading;
	BOOL _hasLoaded;
	CGFloat _bioHeight;
	BOOL _backgroundIsDark;
	NSString *_screenName;
	
	NSString *_tweetCount;
	NSString *_followerCount;
	NSString *_followingCount;
	NSString *_favoriteCount;
	NSString *_listedCount;
	NSString *_userID;
	NSString *_creationDateString;
	NSString *_theirDateString;
	
	UIView *_offscrollView;
	UIColor *_cellBackgroundColor;
}

@end

@implementation HBAPProfileViewController

#pragma mark - Constants

+ (UIColor *)footerLabelColorLight {
	return [UIColor colorWithWhite:0.5f alpha:0.8f];
}

+ (UIColor *)footerLabelColorDark {
	return [UIColor colorWithWhite:0.25f alpha:0.8f];
}

#pragma mark - Implementation

- (instancetype)initWithUser:(HBAPUser *)user {
	self = [super init];
	
	if (self) {
		if (user.loadedFullProfile) {
			_user = [user retain];
		} else {
			_userID = [user.userID retain];
		}
	}
	
	return self;
}

- (instancetype)initWithUserID:(NSString *)userID {
	self = [super init];
	
	if (self) {
		_userID = [userID copy];
	}
	
	return self;
}

- (instancetype)initWithScreenName:(NSString *)screenName {
	self = [super init];
	
	if (self) {
		_screenName = [screenName copy];
	}
	
	return self;
}

- (void)loadView {
	[super loadView];
	
	if (!_user && !_userID && !_screenName) {
		HBLogError(@"no user provided");
	}
	
	self.title = L18N(@"Profile");
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	_offscrollView = [[UIView alloc] initWithFrame:CGRectMake(0, -800.f, self.view.frame.size.width, 800.f)];
	_offscrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.tableView addSubview:_offscrollView];
	
	_cellBackgroundColor = [[UIColor alloc] initWithWhite:0.5f alpha:0.5f];
}

- (BOOL)useThemeBackground {
	return NO;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!_hasLoaded) {
		[self _loadProfile];
	}
}

- (void)_loadProfile {
	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	numberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
	numberFormatter.groupingSeparator = @",";
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	dateFormatter.dateStyle = NSDateFormatterMediumStyle;
	dateFormatter.timeStyle = NSDateFormatterShortStyle;
	
	void (^callback)(HBAPUser *user) = ^(HBAPUser *user) {
		_user = [user retain];
		_isLoading = NO;
		_backgroundIsDark = [HBAPDominantColor isDarkColor:_user.profileBackgroundColor];
		
		if (_user.profileBackgroundColor) {
			CGFloat hue, saturation, brightness;
			[_user.profileBackgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
			
			[_cellBackgroundColor release];
			_cellBackgroundColor = [[UIColor alloc] initWithHue:hue saturation:saturation brightness:brightness + (_backgroundIsDark ? -0.15f : 0.15f) alpha:1];
		}
		
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
		
		[self setupTheme];
		[self.tableView reloadData];
		
		_hasLoaded = YES;
	};
	
	if (_screenName) {
		[HBAPUser userWithScreenName:_screenName callback:callback];
	} else {
		[HBAPUser userWithUserID:_user ? _user.userID : _userID callback:callback];
	}
}

- (void)setupTheme {
	[super setupTheme];
	
	self.tableView.backgroundView = [[[UIView alloc] init] autorelease];
	self.tableView.backgroundView.backgroundColor = _user && _user.profileBackgroundColor ? _user.profileBackgroundColor : [HBAPThemeManager sharedInstance].backgroundColor;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
		default:
			return 1;
			break;
		
		case 1:
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
				cell.gotHeaderCallback = ^{
					_offscrollView.backgroundColor = cell.dominantColor;
				};
			}
			
			if (_user && cell.user != _user) {
				cell.user = _user;
			}
			
			return cell;
			break;
		}
		
		case 1:
		{
			static NSString *CellIdentifier = @"TimelineCell";
			HBAPProfileDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (!cell) {
				cell = [[[HBAPProfileDataTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
			}
			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.backgroundColor = _cellBackgroundColor;
			
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
		
		case 2:
		{
			static NSString *CellIdentifier = @"FooterCell";
			HBAPProfileFooterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (!cell) {
				cell = [[[HBAPProfileFooterTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
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
			return _user ? [HBAPProfileHeaderTableViewCell heightForUser:_user tableView:self.tableView] : [HBAPProfileHeaderTableViewCell defaultHeight];
			break;
		
		case 1:
		default:
			return 44.f;
			break;
		
		case 2:
			return [@" \n \n " sizeWithAttributes:@{ NSFontAttributeName: [HBAPFontManager sharedInstance].footerFont }].height + 30.f;
			break;
	}
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Memory management

- (void)dealloc {
	[_user release];
	[_screenName release];
	[_tweetCount release];
	[_followerCount release];
	[_followingCount release];
	[_favoriteCount release];
	[_listedCount release];
	[_userID release];
	[_creationDateString release];
	[_theirDateString release];
	
	[super dealloc];
}

@end
