//
//  HBAPTweetTextStorage.m
//  Aphelion
//
//  Created by Adam D on 27/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetTextStorage.h"
#import <twitter-text-objc/TwitterText.h>

@interface HBAPTweetTextStorage () {
	NSMutableAttributedString *_backingStore;
	BOOL _needsUpdate;
}

@end

@implementation HBAPTweetTextStorage

#pragma mark - Constants

+ (UIColor *)urlAndUsernameColor {
	return [UIApplication sharedApplication].delegate.window.tintColor;
}

+ (UIColor *)hashtagAndSymbolColor {
	return [UIColor colorWithWhite:0.6666666667f alpha:1];
}

#pragma mark - Implementation

- (instancetype)init {
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

- (void)performReplacementsForCharacterChangeInRange:(NSRange)changedRange {
	NSRange extendedRange = NSUnionRange(changedRange, [_backingStore.string lineRangeForRange:NSMakeRange(changedRange.location, 0)]);
	extendedRange = NSUnionRange(changedRange, [_backingStore.string lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
	
	[self applyTokenAttributesToRange:extendedRange];
}

- (void)processEditing {
	if (_needsUpdate) {
		_needsUpdate = NO;
		[self performReplacementsForCharacterChangeInRange:self.editedRange];
	}
	
	[super processEditing];
}

- (void)applyTokenAttributesToRange:(NSRange)searchRange {
	static NSDictionary *attributeMap;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		attributeMap = [@{
			@"hashtag": @{ NSForegroundColorAttributeName: [self.class hashtagAndSymbolColor] },
			@"symbol": @{ NSForegroundColorAttributeName: [self.class hashtagAndSymbolColor] },
			@"username": @{ NSForegroundColorAttributeName: [self.class urlAndUsernameColor] },
			@"url": @{ NSForegroundColorAttributeName: [self.class urlAndUsernameColor] },
			@"default": @{ NSForegroundColorAttributeName: [UIColor blackColor] },
		} retain];
	});
	
	[_backingStore.string enumerateSubstringsInRange:searchRange options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		for (TwitterTextEntity *entity in [TwitterText entitiesInText:substring]) {
			NSString *attributeType = @"default";
			
			switch (entity.type) {
				case TwitterTextEntityHashtag:
					attributeType = @"hashtag";
					break;
					
				case TwitterTextEntityListName:
					attributeType = @"list";
					break;
					
				case TwitterTextEntityScreenName:
					attributeType = @"screenname";
					break;
				
				case TwitterTextEntitySymbol:
					attributeType = @"symbol";
					break;
					
				case TwitterTextEntityURL:
					attributeType = @"url";
					break;
			}
			
			[self addAttributes:attributeMap[attributeType] range:substringRange];
		}
	}];
}

@end

