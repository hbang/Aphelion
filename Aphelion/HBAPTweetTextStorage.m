//
//  HBAPTweetTextStorage.m
//  Aphelion
//
//  Created by Adam D on 27/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetTextStorage.h"
#import "HBAPTweet.h"
#import "HBAPTweetEntity.h"
#import "HBAPTweetAttributedStringFactory.h"
#import "HBAPTwitterAPISessionManager.h"
#import "HBAPTwitterConfiguration.h"
#import "HBAPThemeManager.h"
#import "NSString+HBAdditions.h"
#import <twitter-text-objc/TwitterText.h>

@interface HBAPTweetTextStorage () {
	NSMutableAttributedString *_backingStore;
	NSDictionary *_defaultAttributes;
	BOOL _needsUpdate;
}

@end

@implementation HBAPTweetTextStorage

#pragma mark - Implementation

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
	self = [super init];
	
	if (self) {
		_backingStore = [[NSMutableAttributedString alloc] initWithString:@"" attributes:attributes];
		_defaultAttributes = [attributes copy];
		_needsUpdate = NO;
	}
	
	return self;
}

#pragma mark - NSAttributedString

- (NSString *)string {
	return _backingStore.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
	return [_backingStore attributesAtIndex:index effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string {
	[_backingStore replaceCharactersInRange:range withString:string];
	[self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes range:range changeInLength:string.length - range.length];
	_needsUpdate = YES;
}

- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)range {
	[_backingStore setAttributes:attributes range:range];
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

#pragma mark - NSTextStorage awesomeness

- (void)processEditing {
	if (_needsUpdate) {
		_needsUpdate = NO;
		[self performReplacementsForCharacterChangeInRange:self.editedRange];
	}
	
	[super processEditing];
}

- (void)performReplacementsForCharacterChangeInRange:(NSRange)changedRange {
	NSRange extendedRange = NSUnionRange(changedRange, [_backingStore.string lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
	[self applyTokenAttributesToRange:extendedRange];
}

- (void)applyTokenAttributesToRange:(NSRange)searchRange {
	[_backingStore.string enumerateSubstringsInRange:searchRange options:NSStringEnumerationBySentences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		NSArray *entities = [TwitterText entitiesInText:substring];
		
		[self setAttributes:_defaultAttributes range:enclosingRange];
		[self removeAttribute:NSLinkAttributeName range:enclosingRange];
		
		for (TwitterTextEntity *entity in entities) {
			NSRange entityRange = NSMakeRange(enclosingRange.location + entity.range.location, entity.range.length);
			
			if (entity.type == TwitterTextEntityScreenName && [[HBAPTwitterAPISessionManager sharedInstance].configuration.nonUsernamePaths containsObject:[substring substringWithRange:entityRange]]) {
				break;
			}
			
			[self addAttributes:[HBAPTweetAttributedStringFactory attributesForEntity:(HBAPTweetEntity *)entity inString:self.string] range:entityRange];
		}
	}];
}

@end
