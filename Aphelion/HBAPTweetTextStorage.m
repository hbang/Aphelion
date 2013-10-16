//
//  HBAPTweetTextStorage.m
//  Aphelion
//
//  Created by Adam D on 27/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetTextStorage.h"
#import <twitter-text-objc/TwitterText.h>
#import "NSString+HBAdditions.h"
#import "HBAPTweet.h"
#import "HBAPTweetEntity.h"
#import "HBAPTweetAttributedStringFactory.h"

@interface HBAPTweetTextStorage () {
	NSMutableAttributedString *_backingStore;
	BOOL _needsUpdate;
}

@end

@implementation HBAPTweetTextStorage

#pragma mark - Implementation

- (instancetype)initWithTweet:(HBAPTweet *)tweet font:(UIFont *)font {
	self = [super init];
	
	if (self) {
		_backingStore = [[NSMutableAttributedString alloc] init];
		_needsUpdate = NO;
	}
	
	return self;
}

- (NSString *)string {
	return _backingStore.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
	return [_backingStore attributesAtIndex:index effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string {
	[self beginEditing];
	
	[_backingStore replaceCharactersInRange:range withString:string];
	[self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes range:range changeInLength:string.length - range.length];
	_needsUpdate = YES;
	
	[self endEditing];
}

- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)range {
	[self beginEditing];
	
	[_backingStore setAttributes:attributes range:range];
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
	
	[self endEditing];
}

- (void)processEditing {
	if (_needsUpdate) {
		_needsUpdate = NO;
		[self applyTokenAttributesToRange:NSUnionRange(self.editedRange, [_backingStore.string lineRangeForRange:NSMakeRange(self.editedRange.location, 0)])];
	}
	
	[super processEditing];
}

- (void)applyTokenAttributesToRange:(NSRange)searchRange {
	[_backingStore.string enumerateSubstringsInRange:searchRange options:NSStringEnumerationBySentences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		NSArray *entities = [TwitterText entitiesInText:substring];
		
		for (TwitterTextEntity *entity in entities) {
			[self addAttributes:[HBAPTweetAttributedStringFactory attributesForEntity:(HBAPTweetEntity *)entity inString:self.string] range:NSMakeRange(enclosingRange.location + entity.range.location, entity.range.length)];
		}
	}];
}

@end

