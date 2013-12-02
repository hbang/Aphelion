//
//  HBAPMentionsTimelineViewController.m
//  Aphelion
//
//  Created by Adam D on 1/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPMentionsTimelineViewController.h"

@interface HBAPMentionsTimelineViewController ()

@end

@implementation HBAPMentionsTimelineViewController

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Mentions");
	self.canCompose = !IS_IPAD;
	self.apiPath = @"statuses/mentions_timeline.json";
}

@end
