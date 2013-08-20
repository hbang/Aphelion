//
//  HBAPTweet.h
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBAPUser;

@interface HBAPTweet : NSObject {
	NSString *_tweetId;
	
	HBAPUser *_poster;
	
	BOOL _isRetweet;
	HBAPTweet *_originalTweet;
	
	NSString *_text;
	NSDictionary *_entities;
	NSDate *_sent;
	
	NSString *_viaName;
	NSURL *_viaURL;
	
	NSString *_geoType; // TODO: research and make an enum
	NSString *_geoLongitude;
	NSString *_geoLatitude;
}

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain, readonly) NSString *tweetId;

@property (nonatomic, retain, readonly) HBAPUser *poster;
@property (nonatomic, retain, readonly) HBAPUser *retweeter;

@property (assign, readonly) BOOL isRetweet;
@property (nonatomic, retain, readonly) HBAPTweet *originalTweet;

@property (nonatomic, retain, readonly) NSString *text;
@property (nonatomic, retain, readonly) NSDictionary *entities;
@property (nonatomic, retain, readonly) NSDate *sent;

@property (nonatomic, retain, readonly) NSString *viaName;
@property (nonatomic, retain, readonly) NSURL *viaURL;

@property (nonatomic, retain, readonly) NSString *geoType;
@property (nonatomic, retain, readonly) NSString *geoLongitude;
@property (nonatomic, retain, readonly) NSString *geoLatitude;

@end
