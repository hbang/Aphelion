//
//  HBAPTweetAttributedStringFactory.m
//  Aphelion
//
//  Created by Adam D on 29/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetAttributedStringFactory.h"
#import "HBAPTweet.h"
#import "HBAPTweetEntity.h"
#import "NSString+HBAdditions.h"

@implementation HBAPTweetAttributedStringFactory

#pragma mark - Constants

+ (UIColor *)hashtagColor {
	return [UIColor colorWithWhite:0.6666666667f alpha:1];
}

#pragma mark - Implementation

+ (NSAttributedString *)attributedStringWithTweet:(HBAPTweet *)tweet font:(UIFont *)font {
	NSMutableString *text = [[tweet.isRetweet ? tweet.originalTweet.text.stringByDecodingXMLEntities : tweet.text.stringByDecodingXMLEntities mutableCopy] autorelease];
	
	NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:text] mutableCopy];
	[attributedString addAttributes:@{ NSFontAttributeName: font } range:NSMakeRange(0, text.length)];
	
	for (HBAPTweetEntity *entity in tweet.isRetweet ? tweet.originalTweet.entities : tweet.entities) {
		if (entity.range.location + entity.range.length > text.length) {
			continue;
		}
		
		if (entity.replacement) {
			[text replaceCharactersInRange:entity.range withString:entity.replacement];
		}
		
		[attributedString addAttributes:[self.class attributesForEntity:entity inString:text] range:entity.range];
	}
		
	return attributedString;
}

+ (NSDictionary *)attributesForEntity:(HBAPTweetEntity *)entity inString:(NSString *)string {
	NSDictionary *attributes = @{};
	
	switch (entity.type) {
		case TwitterTextEntityURL:
			attributes = @{
				NSLinkAttributeName: [entity respondsToSelector:@selector(url)] && entity.url ? entity.url : [NSURL URLWithString:[string substringWithRange:entity.range]]
			};
			break;
			
		case TwitterTextEntityScreenName:
			attributes = @{
				NSLinkAttributeName: ((NSURL *)[NSURL URLWithString:[string substringWithRange:NSMakeRange(entity.range.location + 1, entity.range.length - 1)] relativeToURL:[NSURL URLWithString:kHBAPTwitterRoot]]).absoluteURL
			};
			break;
			
		case TwitterTextEntityHashtag:
			attributes = @{
				NSForegroundColorAttributeName: [self.class hashtagColor],
				NSLinkAttributeName: ((NSURL *)[NSURL URLWithString:[NSString stringWithFormat:@"search?q=%@", [string substringWithRange:entity.range].URLEncodedString] relativeToURL:[NSURL URLWithString:kHBAPTwitterRoot]]).absoluteURL
			};
			break;
			
		case TwitterTextEntityListName:
			attributes = @{
				NSLinkAttributeName: ((NSURL *)[NSURL URLWithString:[string substringWithRange:entity.range] relativeToURL:[NSURL URLWithString:kHBAPTwitterRoot]]).absoluteURL
			};
			break;
			
		case TwitterTextEntitySymbol:
			attributes = @{
				NSForegroundColorAttributeName: [self.class hashtagColor],
				NSLinkAttributeName: ((NSURL *)[NSURL URLWithString:[NSString stringWithFormat:@"search?q=%@", [string substringWithRange:entity.range].URLEncodedString] relativeToURL:[NSURL URLWithString:kHBAPTwitterRoot]]).absoluteURL
			};
			break;
	}
	
	return attributes;
}

@end
