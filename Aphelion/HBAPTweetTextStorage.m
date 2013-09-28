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

@interface HBAPTweetTextStorage () {
	NSMutableAttributedString *_backingStore;
	BOOL _needsUpdate;
}

@end

@implementation HBAPTweetTextStorage

#pragma mark - Constants

+ (UIColor *)hashtagColor {
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

- (void)processEditing {
	if (_needsUpdate) {
		_needsUpdate = NO;
		[self performReplacementsForCharacterChangeInRange:self.editedRange];
	}
	
	[super processEditing];
}

- (void)performReplacementsForCharacterChangeInRange:(NSRange)changedRange {
	NSRange extendedRange = NSUnionRange(changedRange, [_backingStore.string lineRangeForRange:NSMakeRange(changedRange.location, 0)]);
	[self applyTokenAttributesToRange:extendedRange];
}

- (void)applyTokenAttributesToRange:(NSRange)searchRange {
	static NSDictionary *attributeMap;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		attributeMap = [@{
			@"default": @{ NSForegroundColorAttributeName: [UIColor blackColor] },
			@"hashtag": @{ NSForegroundColorAttributeName: [self.class hashtagColor] },
			@"symbol": @{ NSForegroundColorAttributeName: [self.class hashtagColor] },
		} retain];
	});
	
	[_backingStore.string enumerateSubstringsInRange:searchRange options:NSStringEnumerationBySentences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		NSLog(@"a");
		[self removeAttribute:NSForegroundColorAttributeName range:substringRange];
		NSLog(@"s");
		[self removeAttribute:NSLinkAttributeName range:substringRange];
		NSLog(@"d");
		
		for (TwitterTextEntity *entity in [TwitterText entitiesInText:substring]) {
			NSDictionary *attributes = @{};
			
			switch (entity.type) {
				case TwitterTextEntityURL:
					// nothing to do (yet)
					break;
					
				case TwitterTextEntityScreenName:
					attributes = @{
						NSLinkAttributeName: [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", [substring substringWithRange:entity.range]]]
					};
					break;
					
				case TwitterTextEntityHashtag:
					attributes = @{
						NSForegroundColorAttributeName: [self.class hashtagColor],
						NSLinkAttributeName: [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/search?q=%@", [substring substringWithRange:entity.range].URLEncodedString]]
					};
					break;
					
				case TwitterTextEntityListName:
					attributes = @{
						NSLinkAttributeName: [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", [substring substringWithRange:entity.range]]]
					};
					break;
				
				case TwitterTextEntitySymbol:
					attributes = @{
						NSForegroundColorAttributeName: [self.class hashtagColor],
						NSLinkAttributeName: [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/search?q=%@", [substring substringWithRange:entity.range].URLEncodedString]]
					};
					break;
			}
			
			[self addAttributes:attributes range:NSMakeRange(enclosingRange.location + entity.range.location, entity.range.length)];
		}
	}];
}

@end

