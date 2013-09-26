//
//  HBAPTweetEntity.h
//  Aphelion
//
//  Created by Adam D on 26/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBAPUser;

typedef enum {
	HBAPTweetEntityTypeHashtag,
	HBAPTweetEntityTypeSymbol,
	HBAPTweetEntityTypeURL,
	HBAPTweetEntityTypeUser,
} HBAPTweetEntityType;

@interface HBAPTweetEntity : NSObject

+ (NSArray *)entityArrayFromDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary type:(HBAPTweetEntityType)type;

@property HBAPTweetEntityType type;
@property NSRange range;
@property (nonatomic, retain) NSString *replacement;

@property (nonatomic, retain) HBAPUser *user;
@property (nonatomic, retain) NSString *hashtag;
@property (nonatomic, retain) NSURL *url;

@end
