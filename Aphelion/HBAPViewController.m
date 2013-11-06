//
//  HBAPViewController.m
//  Aphelion
//
//  Created by Adam D on 3/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPViewController.h"
#import "HBAPThemeManager.h"

@interface HBAPViewController ()

@end

@implementation HBAPViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
	return [HBAPThemeManager sharedInstance].isDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

@end
