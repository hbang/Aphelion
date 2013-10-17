//
//  HBAPTweet.h
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBAPUser, HBAPTweetTextStorage;

@interface HBAPTweet : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (void)resetAttributedString;
- (void)createAttributedStringIfNeeded;

@property (nonatomic, retain, readonly) NSString *tweetID;
@property (nonatomic, retain, readonly) HBAPUser *poster;
@property (nonatomic, retain, readonly) NSDate *sent;

@property (readonly) BOOL isRetweet;
@property (nonatomic, retain, readonly) HBAPTweet *originalTweet;

@property (nonatomic, retain, readonly) NSString *text;
@property (nonatomic, retain) NSString *displayText;
@property (nonatomic, retain, readonly) NSArray *entities;
@property (nonatomic, retain) NSAttributedString *attributedString;

@property (nonatomic, retain, readonly) NSString *viaName;
@property (nonatomic, retain, readonly) NSURL *viaURL;

@property (nonatomic, retain, readonly) NSString *geoType;
@property (nonatomic, retain, readonly) NSString *geoLongitude;
@property (nonatomic, retain, readonly) NSString *geoLatitude;

@end
