//
//  HBAPTweetActivityViewController.m
//  Aphelion
//
//  Created by Adam D on 4/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetActivityViewController.h"
#import "HBAPTweet.h"
#import "HBAPCopyActivity.h"
#import "HBAPFavoriteActivity.h"
#import "HBAPReplyActivity.h"
#import "HBAPRetweetActivity.h"
#import "HBAPRetweetAsActivity.h"

@interface HBAPTweetActivityViewController () {
	HBAPTweet *_tweet;
}

@end

@implementation HBAPTweetActivityViewController

- (instancetype)initWithTweet:(HBAPTweet *)tweet {
	self = [super init];
	
	if (self) {
		_tweet = [tweet copy];
		
		self.items = @[
			[[[HBAPReplyActivity alloc] init] autorelease],
			[[[HBAPRetweetActivity alloc] init] autorelease],
			[[[HBAPRetweetAsActivity alloc] init] autorelease],
			[[[HBAPCopyActivity alloc] init] autorelease],
			[[[HBAPFavoriteActivity alloc] init] autorelease]
		];
	}
	
	return self;
}

@end
