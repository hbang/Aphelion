//
//  HBAPThemeViewController.m
//  Aphelion
//
//  Created by Adam D on 3/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPThemeViewController.h"
#import "HBAPThemeManager.h"
#import "HBAPTweetTableViewCell.h"
#import "HBAPTweet.h"

@interface HBAPThemeViewController () {
	NSDictionary *_themes;
	NSArray *_themeNames;
	NSUInteger _selectedIndex;
	
	HBAPTweet *_testTweet;
}

@end

@implementation HBAPThemeViewController

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Theme");
	
	HBAPThemeManager *themeManager = [HBAPThemeManager sharedInstance];
	_themes = themeManager.themes;
	_themeNames = themeManager.themeNames;
	_selectedIndex = [_themeNames indexOfObject:themeManager.currentTheme];
	_testTweet = [[HBAPTweet alloc] initWithTestTweet];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section == 2 ? 1 : _themes.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
		case 1:
		{
			static NSString *CellIdentifier = @"Cell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

			if (!cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
				cell.detailTextLabel.numberOfLines = 0;
			}
			
			cell.textLabel.text = _themeNames[indexPath.row];
			cell.detailTextLabel.text = _themes[_themeNames[indexPath.row]][@"comment"];
			cell.accessoryType = _selectedIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

			return cell;
			break;
		}
		
		case 2:
		{
			static NSString *CellIdentifier = @"FakeTweetCell";
			HBAPTweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (!cell) {
				cell = [[[HBAPTweetTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
				cell.userInteractionEnabled = NO;
				cell.tweet = _testTweet;
			}
			
			return cell;
			break;
		}
	}

	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return L18N(@"Day Theme");
			break;
		
		case 1:
			return L18N(@"Night Theme");
			break;
		
		case 2:
			return L18N(@"Sample");
			break;
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
		case 1:
			return _themes[_themeNames[indexPath.row]][@"comment"] ? 64.f : 48.f;
			break;
		
		case 2:
			return [HBAPTweetTableViewCell heightForTweet:_testTweet tableView:self.tableView];
			break;
		
		default:
			return 44.f;
			break;
	}
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row == _selectedIndex) {
		return;
	}
	
	_selectedIndex = indexPath.row;
	
	[HBAPThemeManager sharedInstance].currentTheme = _themeNames[_selectedIndex];
	
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:L18N(@"Theme Applied") message:L18N(@"Restart Aphelion to fully apply the theme.") delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
	[alertView show];
	
	[self.tableView reloadData];
}

@end
