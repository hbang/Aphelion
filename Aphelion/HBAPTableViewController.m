//
//  HBAPTableViewController.m
//  Aphelion
//
//  Created by Adam D on 3/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewController.h"
#import "HBAPThemeManager.h"

@interface HBAPTableViewController ()

@end

@implementation HBAPTableViewController

- (void)loadView {
	[super loadView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return [HBAPThemeManager sharedInstance].isDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self.tableView name:UIContentSizeCategoryDidChangeNotification object:nil];
	
	[super dealloc];
}

@end
