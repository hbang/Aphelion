//
//  HBAPHomeTimelineViewController.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPHomeTimelineViewController.h"
#import "HBAPAvatarSwitchButton.h"
#import "HBAPAccount.h"
#import "HBAPAccountController.h"

@implementation HBAPHomeTimelineViewController

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Home");
	self.canCompose = HBAPCanComposeYes;
	self.apiPath = @"statuses/home_timeline.json";
	
	if (!IS_IPAD) {
		[self _setupSwitchButton];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_setupSwitchButton) name:HBAPAccountControllerDidReloadUsers object:nil];
	}
}

- (void)_setupSwitchButton {
	HBAPAvatarSwitchButton *avatarButton = [[[HBAPAvatarSwitchButton alloc] initWithSize:HBAPAvatarSizeNavBar] autorelease];
	avatarButton.user = [HBAPAccountController sharedInstance].currentAccount.user;
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:avatarButton] autorelease];
}

#pragma mark - Memory management

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

@end
