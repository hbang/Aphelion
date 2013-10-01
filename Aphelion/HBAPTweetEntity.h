//
//  HBAPTweetEntity.h
//  Aphelion
//
//  Created by Adam D on 26/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <twitter-text-objc/TwitterTextEntity.h>

@class HBAPUser;

@interface HBAPTweetEntity : NSObject

+ (NSArray *)entityArrayFromDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary type:(TwitterTextEntityType)type;

@property TwitterTextEntityType type;
@property NSRange range;
@property (nonatomic, retain) NSString *replacement;

@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSURL *url;

@end
