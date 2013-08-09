//
//  HBAPTweet.m
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweet.h"

static NSDateFormatter *dateFormatter;
static NSLocale *dateLocale;

@implementation HBAPTweet

@synthesize tweetId = _tweetId, poster = _poster, retweeter = _retweeter, isRetweet = _isRetweet, text = _text, entities = _entities, sent = _sent, viaName = _viaName, viaURL = _viaURL, geoType = _geoType, geoLongitude = _geoLongitude, geoLatitude = _geoLatitude;

- (id)initWithJSON:(NSDictionary *)json {
	self = [super init];
	
	if (self) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			dateLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
			
			dateFormatter = [[NSDateFormatter alloc] init];
			dateFormatter.locale = dateLocale;
			dateFormatter.dateFormat = @"eee MMM dd HH:mm:ss ZZZZ yyyy"; // "Tue Apr 30 07:36:58 +0000 2013"
		});
		
		_tweetId = json[@"id_str"];
		
		_isRetweet = !!json[@"retweeted_status"];;
		
		_poster = [[HBAPUser alloc] initWithJSON:_isRetweet ? json[@"retweeted_status"][@"user"] : json[@"user"]];
		_retweeter = _isRetweet ? [[HBAPUser alloc] initWithJSON:json[@"user"]] : nil;
		
		_text = json[@"text"];
		_entities = json[@"entities"];
		_sent = [dateFormatter dateFromString:_isRetweet ? json[@"retweeted_status"][@"created_at"] : json[@"created_at"]];
		
		NSString *via = json[@"source"];
		
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
