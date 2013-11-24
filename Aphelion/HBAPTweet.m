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
#import "HBAPTweetAttributedStringFactory.h"
#import "HBAPFontManager.h"

@implementation HBAPTweet

#pragma mark - Constants

+ (UIFont *)defaultAttributedStringFont {
	return [HBAPFontManager sharedInstance].bodyFont;
}

#pragma mark - Implementation

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

- (instancetype)initWithTestTweet {
	self = [super init];
	
	if (self) {
		_tweetID = [@"0" retain];
		_poster = [[HBAPUser alloc] initWithTestUser];
		_isRetweet = NO;
		_text = [@"Bacon ipsum dolor sit amet drumstick frankfurter filet mignon, ribeye brisket venison biltong chicken tri-tip. http://aphelionapp.com #bacon" retain];
		_displayText = [@"Bacon ipsum dolor sit amet drumstick frankfurter filet mignon, ribeye brisket venison biltong chicken tri-tip. aphelionapp.com #bacon" retain];
		_entities = [@[
			[[[HBAPTweetEntity alloc] initWithDictionary:@{
				@"display_text": @"aphelionapp.com",
				@"expanded_url": @"http://aphelionapp.com",
				@"indices": @[ @111, @22 ]
			} type:HBAPTweetEntityTypeURL] autorelease],
			[[[HBAPTweetEntity alloc] initWithDictionary:@{
				@"text": @"bacon",
				@"indices": @[ @134, @6 ]
			} type:HBAPTweetEntityTypeHashtag] autorelease]
		] retain];
		_sent = [[NSDate alloc] init];
		_viaName = [@"Aphelion for iOS" retain];
		_viaURL = [[NSURL alloc] initWithString:@"http://aphelionapp.com"];
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
		_attributedString = [tweet.attributedString copy];
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

#pragma mark - NSCopying/NSCoding

- (instancetype)copyWithZone:(NSZone *)zone {
	return [(HBAPTweet *)[self.class alloc] initWithTweet:self];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:_tweetID forKey:@"tweetID"];
	[encoder encodeObject:_poster forKey:@"poster"];
	[encoder encodeBool:_isRetweet forKey:@"isRetweet"];
	[encoder encodeObject:_originalTweet forKey:@"originalTweet"];
	[encoder encodeObject:_text forKey:@"text"];
	[encoder encodeObject:_displayText forKey:@"displayText"];
	[encoder encodeObject:_entities forKey:@"entities"];
	[encoder encodeObject:_attributedString forKey:@"attributedString"];
	[encoder encodeObject:_sent forKey:@"sent"];
	[encoder encodeObject:_viaName forKey:@"viaName"];
	[encoder encodeObject:_viaURL forKey:@"viaURL"];
	[encoder encodeObject:_geoType forKey:@"geoType"];
	[encoder encodeObject:_geoLongitude forKey:@"geoLongitude"];
	[encoder encodeObject:_geoLatitude forKey:@"geoLatitude"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
	self = [self init];
	
	if (self) {
		_tweetID = [[decoder decodeObjectForKey:@"tweetID"] copy];
		_poster = [[decoder decodeObjectForKey:@"poster"] copy];
		_isRetweet = [decoder decodeBoolForKey:@"isRetweet"];
		_originalTweet = [[decoder decodeObjectForKey:@"originalTweet"] copy];
		_text = [[decoder decodeObjectForKey:@"text"] copy];
		_displayText = [[decoder decodeObjectForKey:@"displayText"] copy];
		_entities = [[decoder decodeObjectForKey:@"entities"] copy];
		_attributedString = [[decoder decodeObjectForKey:@"attributedString"] copy];
		_sent = [[decoder decodeObjectForKey:@"sent"] copy];
		_viaName = [[decoder decodeObjectForKey:@"viaName"] copy];
		_viaURL = [[decoder decodeObjectForKey:@"viaURL"] copy];
		_geoType = [[decoder decodeObjectForKey:@"geoType"] copy];
		_geoLongitude = [[decoder decodeObjectForKey:@"geoLongitude"] copy];
		_geoLatitude = [[decoder decodeObjectForKey:@"geoLatitude"] copy];
	}
	
	return self;
}

#pragma mark - Attributed string stuff

- (void)resetAttributedString {
	if (_isRetweet) {
		[_originalTweet resetAttributedString];
	} else {
		[_attributedString release];
		_attributedString = nil;
	}
}

- (void)createAttributedStringIfNeeded {
	if (_isRetweet) {
		[_originalTweet createAttributedStringIfNeeded];
	} else if (!_attributedString || !_displayText) {
		_attributedString = [[HBAPTweetAttributedStringFactory attributedStringWithTweet:self font:[self.class defaultAttributedStringFont]] retain];
	}
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
