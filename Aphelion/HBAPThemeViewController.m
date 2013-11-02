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
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
			
			cell.textLabel.text = _themeNames[indexPath.row];
			cell.detailTextLabel.text = _themes[_themeNames[indexPath.row]][@"comment"] ?: L18N(@"No Description");
			cell.accessoryType = _selectedIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

			return cell;
			break;
		}
		
		case 2:
		{
			static NSString *CellIdentifier = @"FakeTweetCell";
			HBAPTweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (!cell) {
				cell = [[[HBAPTweetTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
				cell.userInteractionEnabled = NO;
				cell.tweet = [[[HBAPTweet alloc] initWithTestTweet] autorelease];
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
	return indexPath.section == 2 ? 150.f : 48.f;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row == _selectedIndex) {
		return;
	}
	
	NSUInteger oldIndex = _selectedIndex;
	_selectedIndex = indexPath.row;
	
	[HBAPThemeManager sharedInstance].currentTheme = _themeNames[_selectedIndex];
	
	[self.tableView reloadRowsAtIndexPaths:@[
		[NSIndexPath indexPathForRow:oldIndex inSection:0],
		[NSIndexPath indexPathForRow:oldIndex inSection:1],
		[NSIndexPath indexPathForRow:_selectedIndex inSection:0],
		[NSIndexPath indexPathForRow:_selectedIndex inSection:1],
	] withRowAnimation:UITableViewRowAnimationFade];
}

@end
