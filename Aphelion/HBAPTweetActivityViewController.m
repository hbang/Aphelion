//
//  HBAPTweetActivityViewController.m
//  Aphelion
//
//  Created by Adam D on 4/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetActivityViewController.h"
#import "HBAPTweet.h"
#import "HBAPFavoriteActivity.h"
#import "HBAPReplyActivity.h"
#import "HBAPRetweetActivity.h"
#import "HBAPFollowActivity.h"
#import "HBAPMessageActivity.h"
#import "HBAPCopyActivity.h"
#import "HBAPCopyURLActivity.h"
#import "HBAPReadLaterActivity.h"
#import "HBAPMuteActivity.h"

@interface HBAPTweetActivityViewController () {
	HBAPTweet *_tweet;
}

@end

@implementation HBAPTweetActivityViewController

- (instancetype)initWithTweet:(HBAPTweet *)tweet {
	self = [super init];
	
	if (self) {
		_tweet = [tweet copy];
		
		self.items = @{
			L18N(@"Tweet"): @[
				[[[HBAPReplyActivity alloc] init] autorelease],
				[[[HBAPRetweetActivity alloc] init] autorelease],
				[[[HBAPFavoriteActivity alloc] init] autorelease],
				[[[HBAPCopyActivity alloc] init] autorelease],
				[[[HBAPCopyURLActivity alloc] init] autorelease],
				[[[HBAPReadLaterActivity alloc] init] autorelease],
				[[[HBAPMuteActivity alloc] init] autorelease]
			],
			
			L18N(@"User"): @[
				[[[HBAPFollowActivity alloc] init] autorelease],
				[[[HBAPMessageActivity alloc] init] autorelease],
				[[[HBAPMuteActivity alloc] init] autorelease],
			]
		};
	}
	
	return self;
}

@end
