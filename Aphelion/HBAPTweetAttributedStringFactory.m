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
#import "HBAPThemeManager.h"
#import "NSString+HBAdditions.h"

@interface HBAPTweetAttributedStringFactory () {
	NSMutableAttributedString *_attributedString;
}

@property (nonatomic, retain, readonly) NSAttributedString *attributedString;

@end

@implementation HBAPTweetAttributedStringFactory

#pragma mark - Implementation

+ (NSAttributedString *)attributedStringWithTweet:(HBAPTweet *)tweet font:(UIFont *)font {
	if (tweet.attributedString && [tweet.attributedString isKindOfClass:NSAttributedString.class]) {
		NSRange whyPointersWhy = NSMakeRange(0, 1);
		if ([(UIFont *)[tweet.attributedString attribute:NSFontAttributeName atIndex:0 effectiveRange:&whyPointersWhy] isEqual:font]) {
			return tweet.attributedString;
		}
		
		[tweet resetAttributedString];
	}
			  
	NSString *originalTweet = tweet.isRetweet ? tweet.originalTweet.text : tweet.text;
	NSArray *entities = tweet.isRetweet ? tweet.originalTweet.entities : tweet.entities;
	NSMutableArray *entityAttributes = [NSMutableArray array];
	
	if (!tweet.displayText) {
		NSMutableString *newText = [originalTweet.mutableCopy autorelease];
		int extra = 0;
		
		for (HBAPTweetEntity *entity in entities) {
			if (entity.replacement) {
				NSRange range = NSMakeRange(entity.range.location - extra, entity.range.length);
				[newText replaceCharactersInRange:range withString:entity.replacement];
				
				[entityAttributes addObject:@{
					@"attributes": [self.class attributesForEntity:entity inString:originalTweet],
					@"range": [NSValue valueWithRange:NSMakeRange(range.location, entity.replacement.length)],
				}];
				
				extra += entity.range.length - entity.replacement.length;
			} else {
				[entityAttributes addObject:@{
					@"attributes": [self.class attributesForEntity:entity inString:originalTweet],
					@"range": [NSValue valueWithRange:NSMakeRange(entity.range.location, entity.range.length)],
				}];
			}
		}
		
		tweet.displayText = newText;
	}
	
	NSString *text = tweet.displayText;
	NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:text attributes:@{
		NSFontAttributeName: font,
		NSForegroundColorAttributeName: [HBAPThemeManager sharedInstance].textColor
	}] autorelease];
	
	for (NSDictionary *data in entityAttributes) {
		[attributedString addAttributes:data[@"attributes"] range:((NSValue *)data[@"range"]).rangeValue];
	}
	
	tweet.attributedString = attributedString;
	return tweet.attributedString;
}

+ (NSDictionary *)attributesForEntity:(HBAPTweetEntity *)entity inString:(NSString *)string {
	NSDictionary *attributes = @{};
	
	switch (entity.type) {
		case HBAPTweetEntityTypeXMLEscape:
		{
			break;
		}
			
		case TwitterTextEntityURL:
		case HBAPTweetEntityTypeMedia:
		{
			NSURL *url = [entity respondsToSelector:@selector(url)] && entity.url ? entity.url : [NSURL URLWithString:[string substringWithRange:entity.range]];
			
			if (url) {
				attributes = @{
					NSForegroundColorAttributeName: [HBAPThemeManager sharedInstance].tintColor,
					NSLinkAttributeName: url
				};
			}
			break;
		}
			
		case TwitterTextEntityScreenName:
		{
			NSURL *url = ((NSURL *)[NSURL URLWithString:[string substringWithRange:NSMakeRange(entity.range.location + 1, entity.range.length - 1)] relativeToURL:[NSURL URLWithString:kHBAPTwitterRoot]]).absoluteURL;
			
			if (url) {
				attributes = @{
					NSForegroundColorAttributeName: [HBAPThemeManager sharedInstance].tintColor,
					NSLinkAttributeName: url
				};
			}
			break;
		}
			
		case TwitterTextEntityHashtag:
		{
			NSURL *url = ((NSURL *)[NSURL URLWithString:[NSString stringWithFormat:@"search?q=%@", [string substringWithRange:entity.range].URLEncodedString] relativeToURL:[NSURL URLWithString:kHBAPTwitterRoot]]).absoluteURL;
			
			if (url) {
				attributes = @{
					NSForegroundColorAttributeName: [HBAPThemeManager sharedInstance].hashtagColor,
					NSLinkAttributeName: url
				};
			}
			break;
		}
			
		case TwitterTextEntityListName:
		{
			NSURL *url = ((NSURL *)[NSURL URLWithString:[string substringWithRange:entity.range] relativeToURL:[NSURL URLWithString:kHBAPTwitterRoot]]).absoluteURL;
			
			if (url) {
				attributes = @{
					NSForegroundColorAttributeName: [HBAPThemeManager sharedInstance].hashtagColor,
					NSLinkAttributeName: url
				};
			}
			break;
		}
			
		case TwitterTextEntitySymbol:
		{
			NSURL *url = ((NSURL *)[NSURL URLWithString:[NSString stringWithFormat:@"search?q=%@", [string substringWithRange:entity.range].URLEncodedString] relativeToURL:[NSURL URLWithString:kHBAPTwitterRoot]]).absoluteURL;
			
			if (url) {
				attributes = @{
					NSForegroundColorAttributeName: [HBAPThemeManager sharedInstance].hashtagColor,
					NSLinkAttributeName: url
				};
			}
			break;
		}
	}
	
	return attributes;
}

@end
