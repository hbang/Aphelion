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

+ (NSArray *)entityArrayFromDictionary:(NSDictionary *)dictionary tweet:(NSString *)tweet {
	NSMutableArray *entities = [self entityArrayFromDictionary:dictionary].mutableCopy;
	
	if ([tweet rangeOfString:@"&" options:NSLiteralSearch].location != NSNotFound) {
		NSScanner *scanner = [NSScanner scannerWithString:tweet];
		scanner.charactersToBeSkipped = nil;
				
		while (!scanner.isAtEnd) {
			[scanner scanUpToString:@"&" intoString:NULL];
			
			if ([scanner scanString:@"&amp;" intoString:NULL]) {
				[entities addObject:[[[HBAPTweetEntity alloc] initWithRange:NSMakeRange(scanner.scanLocation - 5, 5) replacement:@"&" type:HBAPTweetEntityTypeXMLEscape] autorelease]];
			} else if ([scanner scanString:@"&lt;" intoString:NULL]) {
				[entities addObject:[[[HBAPTweetEntity alloc] initWithRange:NSMakeRange(scanner.scanLocation - 4, 4) replacement:@"<" type:HBAPTweetEntityTypeXMLEscape] autorelease]];
			} else if ([scanner scanString:@"&gt;" intoString:NULL]) {
				[entities addObject:[[[HBAPTweetEntity alloc] initWithRange:NSMakeRange(scanner.scanLocation - 4, 4) replacement:@">" type:HBAPTweetEntityTypeXMLEscape] autorelease]];
			}
		}
	}
	
	NSLog(@"%@",entities);
	
	return [[entities copy] autorelease];
}

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
		[entities addObject:[[[HBAPTweetEntity alloc] initWithDictionary:entity type:HBAPTweetEntityTypeScreenName] autorelease]];
	}
	
	return [[entities copy] autorelease];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary type:(HBAPTweetEntityType)type {
	self = [super init];
	
	if (self) {
		_range = NSMakeRange(((NSNumber *)dictionary[@"indices"][0]).intValue, ((NSNumber *)dictionary[@"indices"][1]).intValue - ((NSNumber *)dictionary[@"indices"][0]).intValue);
		_type = type;
		
		switch (type) {
			case HBAPTweetEntityTypeXMLEscape:
				// not handled here
				break;
			
			case HBAPTweetEntityTypeHashtag:
			case HBAPTweetEntityTypeSymbol:
				_replacement = [[type == TwitterTextEntitySymbol ? @"$" : @"#" stringByAppendingString:dictionary[@"text"]] retain];
				break;
			
			case HBAPTweetEntityTypeURL:
				_replacement = [dictionary[@"display_url"] copy];
				_url = [[NSURL alloc] initWithString:dictionary[@"expanded_url"]];
				break;
				
			case HBAPTweetEntityTypeScreenName:
				_replacement = [[@"@" stringByAppendingString:dictionary[@"screen_name"]] retain];
				_userID = [dictionary[@"id_str"] copy];
				break;
			
			case HBAPTweetEntityTypeListName:
				// meh
				break;
		}
	}
	
	return self;
}

- (instancetype)initWithRange:(NSRange)range replacement:(NSString *)replacement type:(HBAPTweetEntityType)type {
	self = [super init];
	
	if (self) {
		NSAssert(type == HBAPTweetEntityTypeXMLEscape, @"not an xml escape");
		
		_type = type;
		_range = range;
		_replacement = [replacement copy];
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
