//
//  HBAPUser.h
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBAPUser : NSObject {
	NSString *_realName;
	NSString *_screenName;
	NSString *_userId;
	
	BOOL _protected;
	BOOL _verified;
	
	NSURL *_avatar;
	NSData *_cachedAvatar;
	
	BOOL _loadedFullProfile;
	
	NSString *_bio;
	NSString *_location;
	BOOL _followingMe;
	BOOL _following;
}

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSString *realName;
@property (nonatomic, retain) NSString *screenName;
@property (nonatomic, retain) NSString *userId;

@property (assign) BOOL protected;
@property (assign) BOOL verified;

@property (nonatomic, retain) NSURL *avatar;
@property (nonatomic, retain) NSData *cachedAvatar;

@property (assign) BOOL loadedFullProfile;

@property (nonatomic, retain) NSString *bio;
@property (nonatomic, retain) NSString *location;
@property (assign) BOOL followingMe;
@property (assign) BOOL following;

@end
