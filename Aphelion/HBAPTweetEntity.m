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
	NSMutableArray *entities = [[self entityArrayFromDictionary:dictionary].mutableCopy autorelease];
	
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
	
	[self.class _sortEntities:entities];
	
	return entities;
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
	
	for (NSDictionary *entity in dictionary[@"media"]) {
		[entities addObject:[[[HBAPTweetEntity alloc] initWithDictionary:entity type:HBAPTweetEntityTypeMedia] autorelease]];
	}
	
	[self.class _sortEntities:entities];
	
	return entities;
}

+ (void)_sortEntities:(NSMutableArray *)entities {
	[entities sortWithOptions:kNilOptions usingComparator:^NSComparisonResult(HBAPTweetEntity *entity1, HBAPTweetEntity *entity2) {
		if (entity1.range.location < entity2.range.location) {
			return NSOrderedAscending;
		} else if (entity1.range.location > entity2.range.location) {
			return NSOrderedDescending;
		}
		
		return NSOrderedSame;
	}];
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
			case HBAPTweetEntityTypeMedia:
				_replacement = [dictionary[@"display_url"] copy];
				_url = [[NSURL alloc] initWithString:dictionary[@"expanded_url"]];
				
				if (dictionary[@"media_url_https"]) {
					_mediaURL = [[NSURL alloc] initWithString:dictionary[@"media_url_https"]];
				}
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

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeInteger:_type forKey:@"type"];
	[encoder encodeObject:[NSValue valueWithRange:_range] forKey:@"range"];
	[encoder encodeObject:_replacement forKey:@"replacement"];
	[encoder encodeObject:_userID forKey:@"userID"];
	[encoder encodeObject:_url forKey:@"url"];
	[encoder encodeObject:_mediaURL forKey:@"mediaURL"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
	self = [self init];
	
	if (self) {
		_type = [decoder decodeIntegerForKey:@"type"];
		_range = ((NSValue *)[decoder decodeObjectForKey:@"range"]).rangeValue;
		_replacement = [[decoder decodeObjectForKey:@"replacement"] copy];
		_userID = [[decoder decodeObjectForKey:@"userID"] copy];
		_url = [[decoder decodeObjectForKey:@"url"] copy];
		_mediaURL = [[decoder decodeObjectForKey:@"mediaURL"] copy];
	}
	
	return self;
}

#pragma mark - Memory management

- (void)dealloc {
	[_replacement release];
	[_url release];
	[_userID release];
	
	[super dealloc];
}

@end
