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
#ifdef THEOS
#import "../JSONKit/JSONKit.h"
#else
#import <JSONKit/JSONKit.h>
#endif
#endif

@interface HBAPHomeTimelineViewController ()

@end

@implementation HBAPHomeTimelineViewController

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Home");
	
#ifdef kHBAPKirbOfflineDebug
	[self _loadTweetsFromArray:[[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"timelinesample" ofType:@"json"]] objectFromJSONData]];
#else
	[self loadTweetsFromPath:@"statuses/home_timeline"];
#endif
}

@end
