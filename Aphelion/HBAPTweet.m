//
//  HBAPTweet.m
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweet.h"
#import "HBAPUser.h"

@implementation HBAPTweet

@synthesize tweetId = _tweetId, poster = _poster, retweeter = _retweeter, isRetweet = _isRetweet, text = _text, entities = _entities, sent = _sent, viaName = _viaName, viaURL = _viaURL, geoType = _geoType, geoLongitude = _geoLongitude, geoLatitude = _geoLatitude;

- (instancetype)initWithDictionary:(NSDictionary *)tweet {
	self = [super init];
	
	if (self) {
		static NSDateFormatter *dateFormatter;
		static NSLocale *dateLocale; // TODO: does this have to be static?
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			dateLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
			
			dateFormatter = [[NSDateFormatter alloc] init];
			dateFormatter.locale = dateLocale;
			dateFormatter.dateFormat = @"eee MMM dd HH:mm:ss ZZZZ yyyy"; // "Tue Apr 30 07:36:58 +0000 2013"
		});
		
		_tweetId = [tweet objectForKey:@"id_str"];
		
		_isRetweet = !![tweet objectForKey:@"retweeted_status"];
		
		if (_isRetweet) {
			_originalTweet = [[HBAPTweet alloc] initWithDictionary:[tweet objectForKey:@"retweeted_status"]];
		}
		
		_poster = [[HBAPUser alloc] initWithDictionary:[tweet objectForKey:@"user"]];
		
		_text = [tweet objectForKey:@"text"];
		_entities = [tweet objectForKey:@"entities"];
		_sent = [dateFormatter dateFromString:[tweet objectForKey:@"created_at"]];
		
		NSString *via = [tweet objectForKey:@"source"];
		
		/*
		 Lengths:
		 <a href="			9
		 " rel="nofollow">	17
		 </a>				4
		*/
		
		if ([via rangeOfString:@"<a href=\""].location == 0 && [via rangeOfString:@"</a>"].location == via.length - 4) {
			NSString *url = [via substringWithRange:NSMakeRange(9, [via rangeOfString:@"\" rel=\"nofollow\">"].location - 9)];
			_viaName = [via substringWithRange:NSMakeRange(9 + url.length + 18, via.length - 9 - url.length - 18 - 4)];
			_viaURL = [NSURL URLWithString:url];
		} else {
			_viaName = via;
			_viaURL = nil;
		}
		
		_geoType = nil; // TODO: this
		_geoLongitude = nil;
		_geoLatitude = nil;
	}
	
	return self;
}

@end
