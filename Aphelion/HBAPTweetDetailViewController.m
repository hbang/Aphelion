//
//  HBAPTweetDetailViewController.m
//  Aphelion
//
//  Created by Adam D on 20/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetDetailViewController.h"
#import "HBAPTweet.h"

@implementation HBAPTweetDetailViewController
@synthesize tweet = _tweet;

- (instancetype)initWithTweet:(HBAPTweet *)tweet {
	self = [super init];
	
	if (self) {
		_tweet = tweet;
	}
	
	return self;
}

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Tweet");
}

@end
