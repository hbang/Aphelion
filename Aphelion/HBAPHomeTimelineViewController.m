//
//  HBAPHomeTimelineViewController.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPHomeTimelineViewController.h"

#define kHBAPKirbOfflineDebug

#ifdef kHBAPKirbOfflineDebug
#import <JSONKit/JSONKit.h>
#endif

@interface HBAPHomeTimelineViewController ()

@end

@implementation HBAPHomeTimelineViewController

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Home");
	self.canCompose = YES;
	
#ifdef kHBAPKirbOfflineDebug
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadTweetsFromArray:[[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"timelinesample" ofType:@"json"]] objectFromJSONData]];
	});
#else
	self.apiPath = @"statuses/home_timeline.json";
#endif
}

@end
