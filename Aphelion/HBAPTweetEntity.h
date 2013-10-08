//
//  HBAPTweetEntity.h
//  Aphelion
//
//  Created by Adam D on 26/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <twitter-text-objc/TwitterTextEntity.h>

typedef NS_ENUM(NSUInteger, HBAPTweetEntityType) {
	HBAPTweetEntityTypeHashtag = TwitterTextEntityHashtag,
	HBAPTweetEntityTypeListName = TwitterTextEntityListName,
	HBAPTweetEntityTypeScreenName = TwitterTextEntityScreenName,
	HBAPTweetEntityTypeSymbol = TwitterTextEntitySymbol,
	HBAPTweetEntityTypeURL = TwitterTextEntityURL,
	HBAPTweetEntityTypeXMLEscape = NSUIntegerMax
};

@class HBAPUser;

@interface HBAPTweetEntity : NSObject

+ (NSArray *)entityArrayFromDictionary:(NSDictionary *)dictionary;
+ (NSArray *)entityArrayFromDictionary:(NSDictionary *)dictionary tweet:(NSString *)tweet;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary type:(HBAPTweetEntityType)type;

@property HBAPTweetEntityType type;
@property NSRange range;
@property (nonatomic, retain) NSString *replacement;

@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSURL *url;

@end
