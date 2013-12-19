//
//  HBAPAboutViewController.m
//  Aphelion
//
//  Created by Adam D on 20/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAboutViewController.h"
#import "HBAPUser.h"
#import "HBAPAboutUserTableViewCell.h"

static NSString *const kHBAPAboutKirbUserID = @"103767197";
static NSString *const kHBAPAboutInsanjUserID = @"19558701";
static NSString *const kHBAPAboutChickyUserID = @"327671060";
static NSString *const kHBAPAboutRokUserID = @"461419441";

@interface HBAPAboutViewController ()

@end

@implementation HBAPAboutViewController

#pragma mark - Constants

+ (NSString *)specifierPlist {
	return @"PrefsAbout";
}

#pragma mark - Implementation

- (void)loadView {
	[super loadView];
	
	NSArray *userIDs = @[
		kHBAPAboutKirbUserID,
		kHBAPAboutInsanjUserID,
		kHBAPAboutChickyUserID,
		kHBAPAboutRokUserID
	];
	
	[HBAPUser usersWithUserIDs:userIDs callback:^(NSDictionary *users) {
		NSUInteger i = 3;
		
		for (NSString *userID in userIDs) {
			HBAPAboutUserTableViewCell *cell = (HBAPAboutUserTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
			cell.user = users[userID];
			
			i++;
		}
	}];
}

#pragma mark - UITableViewDataSource 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HBAPAboutUserTableViewCell *cell = (HBAPAboutUserTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	if (cell.class == HBAPAboutUserTableViewCell.class) {
		cell.navigationController = self.navigationController;
	}
	
	return cell;
}

@end
