//
//  HBAPFontViewController.m
//  Aphelion
//
//  Created by Adam D on 16/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPFontViewController.h"
#import "HBAPFontManager.h"
#import "HBAPTweet.h"
#import "HBAPTweetTableViewCell.h"
#import "HBAPNavigationController.h"

@interface HBAPFontViewController () {
	NSDictionary *_fonts;
	NSArray *_fontNames;
	NSUInteger _selectedIndex;
	
	HBAPTweet *_testTweet;
}

@end

@implementation HBAPFontViewController

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Font");
	
	HBAPFontManager *fontManager = [HBAPFontManager sharedInstance];
	_fonts = fontManager.fonts;
	_fontNames = fontManager.fontNames;
	_selectedIndex = [_fontNames indexOfObject:fontManager.currentFont];
	_testTweet = [[HBAPTweet alloc] initWithTestTweet];
}

- (void)_askToDownloadFont {
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:L18N(@"This font may require a download.") message:nil delegate:self cancelButtonTitle:L18N(@"Cancel") otherButtonTitles:L18N(@"Download"), nil] autorelease];
	[alertView show];
}

- (void)_downloadFont {
	[[HBAPFontManager sharedInstance] downloadFont:_fontNames[_selectedIndex] withProgressCallback:^(CTFontDescriptorMatchingState state, double progress) {
		/*switch (state) {
			case kCTFontDescriptorMatchingDownloading:
				self.navigationController.progress = 0.01f;
				break;
			
			default:
				break;
		}*/
		NSLog(@"state = %i, progress = %f",state,progress);
	}];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[HBAPFontManager sharedInstance].currentFont = @"Helvetica Neue";
			break;
			
		case 1:
			[self _downloadFont];
			break;
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section == 1 ? 1 : _fonts.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
		{
			static NSString *CellIdentifier = @"Cell";
			HBAPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (!cell) {
				cell = [[[HBAPTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
			}
			
			cell.textLabel.text = _fontNames[indexPath.row];
			cell.accessoryType = _selectedIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			
			return cell;
			break;
		}
			
		case 1:
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
			return L18N(@"Font");
			break;
			
		case 1:
			return L18N(@"Sample");
			break;
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section == 1 ? [HBAPTweetTableViewCell heightForTweet:_testTweet tableView:self.tableView] : 44.f;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row == _selectedIndex) {
		return;
	}
	
	_selectedIndex = indexPath.row;
	
	
	if ([[HBAPFontManager sharedInstance] fontNeedsDownloading:_fontNames[_selectedIndex]]) {
		[self _askToDownloadFont];
	} else {
		[HBAPFontManager sharedInstance].currentFont = _fontNames[_selectedIndex];
		[self.tableView reloadData];
	}
}

@end
