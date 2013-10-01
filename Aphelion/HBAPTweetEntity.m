//
//  HBAPTweetEntity.m
//  Aphelion
//
//  Created by Adam D on 26/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetEntity.h"
#import "HBAPUser.h"

@implementation HBAPTweetEntity

+ (NSArray *)entityArrayFromDictionary:(NSDictionary *)dictionary {
	NSMutableArray *entities = [NSMutableArray array];
	
	for (NSDictionary *entity in dictionary[@"hashtags"]) {
		[entities addObject:[[[HBAPTweetEntity alloc] initWithDictionary:entity type:TwitterTextEntityHashtag] autorelease]];
	}
	
	for (NSDictionary *entity in dictionary[@"symbols"]) {
		[entities addObject:[[[HBAPTweetEntity alloc] initWithDictionary:entity type:TwitterTextEntitySymbol] autorelease]];
	}
	
	for (NSDictionary *entity in dictionary[@"urls"]) {
		[entities addObject:[[[HBAPTweetEntity alloc] initWithDictionary:entity type:TwitterTextEntityURL] autorelease]];
	}
	
	for (NSDictionary *entity in dictionary[@"user_mentions"]) {
		[entities addObject:[[[HBAPTweetEntity alloc] initWithDictionary:entity type:TwitterTextEntityScreenName] autorelease]];
	}
	
	return [[entities copy] autorelease];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary type:(TwitterTextEntityType)type {
	self = [super init];
	
	if (self) {
		_range = NSMakeRange(((NSNumber *)dictionary[@"indices"][0]).intValue, ((NSNumber *)dictionary[@"indices"][1]).intValue - ((NSNumber *)dictionary[@"indices"][0]).intValue);
		_type = type;
		
		switch (type) {
			case TwitterTextEntityHashtag:
			case TwitterTextEntitySymbol:
				_replacement = [[type == TwitterTextEntitySymbol ? @"$" : @"#" stringByAppendingString:dictionary[@"text"]] retain];
				break;
			
			case TwitterTextEntityURL:
				_replacement = [dictionary[@"display_url"] copy];
				_url = [[NSURL alloc] initWithString:dictionary[@"expanded_url"]];
				break;
				
			case TwitterTextEntityScreenName:
				_replacement = [[@"@" stringByAppendingString:dictionary[@"screen_name"]] retain];
				_userID = [dictionary[@"id_str"] copy];
				break;
			
			case TwitterTextEntityListName:
				// meh
				break;
		}
	}
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; type = %i; range = %@; replacement = %@; url = %@; userID = %@>", NSStringFromClass(self.class), self, _type, NSStringFromRange(_range), _replacement, _url, _userID];
}

#pragma mark - Memory management

- (void)dealloc {
	[_replacement release];
	[_url release];
	[_userID release];
	
	[super dealloc];
}

@end
