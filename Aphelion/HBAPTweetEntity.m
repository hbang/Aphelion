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
		[entities addObject:[[[HBAPTweetEntity alloc] initWithDictionary:entity type:HBAPTweetEntityTypeHashtag] autorelease]];
	}
	
	for (NSDictionary *entity in dictionary[@"symbols"]) {
		[entities addObject:[[[HBAPTweetEntity alloc] initWithDictionary:entity type:HBAPTweetEntityTypeSymbol] autorelease]];
	}
	
	for (NSDictionary *entity in dictionary[@"urls"]) {
		[entities addObject:[[[HBAPTweetEntity alloc] initWithDictionary:entity type:HBAPTweetEntityTypeURL] autorelease]];
	}
	
	for (NSDictionary *entity in dictionary[@"user_mentions"]) {
		[entities addObject:[[[HBAPTweetEntity alloc] initWithDictionary:entity type:HBAPTweetEntityTypeUser] autorelease]];
	}
	
	return [[entities copy] autorelease];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary type:(HBAPTweetEntityType)type {
	self = [super init];
	
	if (self) {
		_range = NSMakeRange(((NSNumber *)dictionary[@"indices"][0]).intValue, ((NSNumber *)dictionary[@"indices"][1]).intValue - ((NSNumber *)dictionary[@"indices"][0]).intValue);
		
		switch (type) {
			case HBAPTweetEntityTypeHashtag:
			case HBAPTweetEntityTypeSymbol:
				_replacement = [[type == HBAPTweetEntityTypeSymbol ? @"$" : @"#" stringByAppendingString:dictionary[@"text"]] retain];
				_hashtag = _replacement;
				break;
			
			case HBAPTweetEntityTypeURL:
				_replacement = [dictionary[@"display_url"] copy];
				_url = [[NSURL alloc] initWithString:dictionary[@"expanded_url"]];
				break;
				
			case HBAPTweetEntityTypeUser:
				_replacement = [[@"@" stringByAppendingString:dictionary[@"screen_name"]] retain];
				_user = [[HBAPUser alloc] initWithUserID:dictionary[@"id_str"]];
				break;
		}
	}
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; range = %@; replacement = %@; hashtag = %@; url = %@; user = %@>", NSStringFromClass(self.class), self, NSStringFromRange(_range), _replacement, _hashtag, _url, _user];
}

#pragma mark - Memory management

- (void)dealloc {
	[_replacement release];
	[_url release];
	[_user release];
	
	[super dealloc];
}

@end
