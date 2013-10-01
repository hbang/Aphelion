//
//  HBAPHomeTimelineViewController.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPHomeTimelineViewController.h"

@interface HBAPHomeTimelineViewController ()

@end

@implementation HBAPHomeTimelineViewController

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Home");
	self.canCompose = YES;
	self.apiPath = @"statuses/home_timeline.json";
}

@end
