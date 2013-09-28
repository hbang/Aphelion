//
//  HBAPTweetAttributedStringFactory.h
//  Aphelion
//
//  Created by Adam D on 29/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBAPTweet, HBAPTweetEntity;

@interface HBAPTweetAttributedStringFactory : NSObject

+ (NSAttributedString *)attributedStringWithTweet:(HBAPTweet *)tweet font:(UIFont *)font;
+ (NSDictionary *)attributesForEntity:(HBAPTweetEntity *)entity inString:(NSString *)string;

@end
