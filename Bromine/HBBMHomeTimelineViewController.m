//
//  HBBMHomeTimelineViewController.m
//  Bromine
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBBMHomeTimelineViewController.h"

@interface HBBMHomeTimelineViewController ()

@end

@implementation HBBMHomeTimelineViewController

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Home");
	
	[self loadTweetsFromPath:@"statuses/home_timeline"];
}

@end