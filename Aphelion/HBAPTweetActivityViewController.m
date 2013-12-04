//
//  HBAPTweetActivityViewController.m
//  Aphelion
//
//  Created by Adam D on 4/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetActivityViewController.h"
#import "HBAPTweet.h"

@interface HBAPTweetActivityViewController () {
	HBAPTweet *_tweet;
}

@end

@implementation HBAPTweetActivityViewController

- (instancetype)initWithTweet:(HBAPTweet *)tweet {
	self = [super init];
	
	if (self) {
		_tweet = [tweet copy];
		
		self.items = [@[
			
		] retain];
	}
	
	return self;
}

@end
