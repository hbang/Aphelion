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

- (instancetype)initWithTweet:(HBAPTweet *)tweet {
	self = [super init];
	
	if (self) {
		_tweet = [tweet copy];
	}
	
	return self;
}

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"Tweet");
	self.canCompose = HBAPCanComposeReply;
	self.composeInReplyToTweet = _tweet;
}

#pragma mark - Memory management

- (void)dealloc {
	[_tweet release];
	
	[super dealloc];
}

@end
