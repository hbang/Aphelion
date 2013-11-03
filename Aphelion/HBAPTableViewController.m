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

- (UIStatusBarStyle)preferredStatusBarStyle {
	return [HBAPThemeManager sharedInstance].isDark ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

@end
