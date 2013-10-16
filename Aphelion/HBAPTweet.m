//
//  HBAPTweet.m
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweet.h"
#import "HBAPUser.h"
#import "HBAPTweetEntity.h"

@implementation HBAPTweet

- (instancetype)initWithDictionary:(NSDictionary *)tweet {
	self = [super init];
	
	if (self) {
		static NSDateFormatter *dateFormatter;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			dateFormatter = [[NSDateFormatter alloc] init];
			dateFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
			dateFormatter.dateFormat = @"eee MMM dd HH:mm:ss ZZZZ yyyy"; // "Tue Apr 30 07:36:58 +0000 2013"
		});
		
		_tweetID = [tweet[@"id_str"] copy];
		_poster = [[HBAPUser alloc] initWithDictionary:tweet[@"user"]];
		_sent = [[dateFormatter dateFromString:tweet[@"created_at"]] retain];
		
		_isRetweet = !!tweet[@"retweeted_status"];
		
		if (_isRetweet) {
			_originalTweet = [[HBAPTweet alloc] initWithDictionary:tweet[@"retweeted_status"]];
		}
		
		_text = [tweet[@"text"] copy];
		_entities = [[HBAPTweetEntity entityArrayFromDictionary:tweet[@"entities"] tweet:_text] retain];
		
		NSString *via = tweet[@"source"];
		
		/*
		 Lengths:
		 <a href="			9
		 " rel="nofollow">	17
		 </a>				4
		*/
		
		if ([via rangeOfString:@"<a href=\""].location == 0 && [via rangeOfString:@"</a>"].location == via.length - 4) {
			NSString *url = [via substringWithRange:NSMakeRange(9, [via rangeOfString:@"\" rel=\"nofollow\">"].location - 9)];
			_viaName = [[via substringWithRange:NSMakeRange(9 + url.length + 17, via.length - 9 - url.length - 18 - 3)] retain];
			_viaURL = [[NSURL alloc] initWithString:url];
		} else {
			_viaName = [via copy];
			_viaURL = nil;
		}
		
		_geoType = nil; // TODO: this
		_geoLongitude = nil;
		_geoLatitude = nil;
	}
	
	return self;
}

- (instancetype)initWithTweet:(HBAPTweet *)tweet {
	self = [super init];
	
	if (self) {
		_tweetID = [tweet.tweetID copy];
		_poster = [tweet.poster copy];
		_isRetweet = tweet.isRetweet;
		_originalTweet = [tweet.originalTweet copy];
		_text = [tweet.text copy];
		_displayText = [tweet.displayText copy];
		_entities = [tweet.entities copy];
		_sent = [tweet.sent copy];
		_viaName = [tweet.viaName copy];
		_viaURL = [tweet.viaURL copy];
		_geoType = [tweet.geoType copy];
		_geoLongitude = [tweet.geoLongitude copy];
		_geoLatitude = [tweet.geoLatitude copy];
	}
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; poster = %@; text = %@; original = %@>", NSStringFromClass(self.class), self, _poster, _text, _originalTweet];
}

- (instancetype)copyWithZone:(NSZone *)zone {
	return [(HBAPTweet *)[self.class alloc] initWithTweet:self];
}

- (void)resetAttributedString {
	[_attributedString release];
	_attributedString = nil;
}

#pragma mark - Memory management

- (void)dealloc {
	[_tweetID release];
	[_poster release];
	[_originalTweet release];
	[_text release];
	[_displayText release];
	[_entities release];
	[_sent release];
	[_viaName release];
	[_viaURL release];
	[_geoType release];
	[_geoLongitude release];
	[_geoLatitude release];
	
	[super dealloc];
}

@end
