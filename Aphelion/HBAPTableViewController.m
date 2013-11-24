//
//  HBAPTableViewController.m
//  Aphelion
//
//  Created by Adam D on 3/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewController.h"
#import "HBAPThemeManager.h"

@implementation HBAPTableViewController

- (void)loadView {
	[super loadView];
	
	[self setupTheme];
	
	[[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:UIContentSizeCategoryDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTheme) name:HBAPThemeChanged object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return [HBAPThemeManager sharedInstance].isDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (BOOL)useThemeBackground {
	return YES;
}

- (void)setupTheme {
	if (self.useThemeBackground) {
		self.tableView.backgroundView = [[[UIView alloc] init] autorelease];
		self.tableView.backgroundView.backgroundColor = self.tableView.style == UITableViewStyleGrouped ? [HBAPThemeManager sharedInstance].groupedBackgroundColor : [HBAPThemeManager sharedInstance].backgroundColor;
	}
	
	self.tableView.separatorColor = [[HBAPThemeManager sharedInstance].dimTextColor colorWithAlphaComponent:0.5f];
	
	[self.tableView reloadData];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
	
	[super dealloc];
}

@end
