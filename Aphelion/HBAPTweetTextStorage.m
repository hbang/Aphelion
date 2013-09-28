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
#import "HBAPTweetEntity.h"

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
	[_backingStore.string enumerateSubstringsInRange:searchRange options:NSStringEnumerationBySentences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		[self removeAttribute:NSForegroundColorAttributeName range:substringRange];
		[self removeAttribute:NSLinkAttributeName range:substringRange];
		
		NSArray *entities;
		if (_entities) {
			entities = _entities;
		} else {
			entities = [TwitterText entitiesInText:substring];
		}
		
		for (HBAPTweetEntity *entity in entities) {
			NSDictionary *attributes = @{};
			
			switch (entity.type) {
				case TwitterTextEntityURL:
					// nothing to do (yet)
					break;
					
				case TwitterTextEntityScreenName:
					attributes = @{
						NSLinkAttributeName: [NSURL URLWithString:[substring substringWithRange:entity.range] relativeToURL:[NSURL URLWithString:kHBAPTwitterRoot]]
					};
					break;
					
				case TwitterTextEntityHashtag:
					attributes = @{
						NSForegroundColorAttributeName: [self.class hashtagColor],
						NSLinkAttributeName: [NSURL URLWithString:[NSString stringWithFormat:@"search?q=%@", [substring substringWithRange:entity.range].URLEncodedString] relativeToURL:[NSURL URLWithString:kHBAPTwitterRoot]]
					};
					break;
					
				case TwitterTextEntityListName:
					attributes = @{
						NSLinkAttributeName: [NSURL URLWithString:[substring substringWithRange:entity.range] relativeToURL:[NSURL URLWithString:kHBAPTwitterRoot]]
					};
					break;
				
				case TwitterTextEntitySymbol:
					attributes = @{
						NSForegroundColorAttributeName: [self.class hashtagColor],
						NSLinkAttributeName: [NSURL URLWithString:[NSString stringWithFormat:@"search?q=%@", [substring substringWithRange:entity.range].URLEncodedString] relativeToURL:[NSURL URLWithString:kHBAPTwitterRoot]]
					};
					break;
			}
			
			[self addAttributes:attributes range:NSMakeRange(enclosingRange.location + entity.range.location, entity.range.length)];
		}
	}];
}

@end

