//
//  HBBMWelcomeViewController.m
//  Bromine
//
//  Created by Adam D on 24/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBBMWelcomeViewController.h"

@interface HBBMWelcomeViewController () {
	UIView *_containerView;
	UILabel *_welcomeLabel;
	UIButton *_signInButton;
}

@end

@implementation HBBMWelcomeViewController

- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
	_containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	_welcomeLabel = [[[UILabel alloc] init] autorelease];
	_welcomeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_welcomeLabel.text = L18N(@"Welcome to Bromine");
	_welcomeLabel.font = [UIFont systemFontOfSize:45.f];
	_welcomeLabel.textAlignment = NSTextAlignmentCenter;
	[_welcomeLabel sizeToFit];
	_welcomeLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, _welcomeLabel.frame.size.height);
	[_containerView addSubview:_welcomeLabel];
	
	_signInButton = [[[UIButton alloc] initWithFrame:CGRectMake(10.f, _welcomeLabel.frame.size.height + 20.f, self.view.frame.size.width - 20.f, _welcomeLabel.frame.size.height)] autorelease];
	_signInButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[_signInButton setTitle:L18N(@"Sign In") forState:UIControlStateNormal];
	_signInButton.titleLabel.font = [UIFont systemFontOfSize:35.f];
	[_signInButton setTitleColor:[UIColor colorWithRed:9.f / 255.f green:122.f / 255.f blue:1 alpha:1] forState:UIControlStateNormal];
	[_containerView addSubview:_signInButton];
	
	[self.view addSubview:_containerView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	CGRect frame = _containerView.frame;
	frame.size.height = _signInButton.frame.origin.y + _signInButton.frame.size.height;
	_containerView.frame = frame;
	
	_containerView.center = CGPointMake(_containerView.center.x, self.view.center.y);
}

@end
