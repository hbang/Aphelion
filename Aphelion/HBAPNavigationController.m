//
//  HBAPNavigationController.m
//  Aphelion
//
//  Created by Adam D on 6/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPNavigationController.h"
#import "HBAPThemeManager.h"

@interface HBAPNavigationController ()

@end

@implementation HBAPNavigationController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if (IS_IPAD) {
		self.toolbarHidden = NO;
		
		UIImageView *grabberImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grabber"]] autorelease];
		grabberImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
		grabberImageView.center = CGPointMake(self.toolbar.frame.size.width / 2, self.toolbar.frame.size.height / 2);
		[self.toolbar addSubview:grabberImageView];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (_toolbarGestureRecognizer) {
		[self.toolbar addGestureRecognizer:_toolbarGestureRecognizer];
	}
	
	self.navigationBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8f];
	self.toolbar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8f];
}

@end
