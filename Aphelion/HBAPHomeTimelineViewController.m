//
//  HBAPHomeTimelineViewController.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPHomeTimelineViewController.h"
#import "HBAPAvatarSwitchButton.h"

@interface HBAPHomeTimelineViewController ()

@end

@implementation HBAPHomeTimelineViewController

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Home");
	self.canCompose = HBAPCanComposeYes;
	self.apiPath = @"statuses/home_timeline.json";
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:[[[HBAPAvatarSwitchButton alloc] init] autorelease]] autorelease];
}

@end
