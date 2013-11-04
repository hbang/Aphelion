//
//  HBAPUser.h
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HBAPAvatarSize) {
	HBAPAvatarSizeMini, // 24x24
	HBAPAvatarSizeNormal, // 48x48
	HBAPAvatarSizeBigger, // 73x73
	HBAPAvatarSizeOriginal
};

@interface HBAPUser : NSObject

+ (void)usersWithUserIDs:(NSArray *)userIDs callback:(void (^)(NSDictionary *users))callback;
+ (void)userWithUserID:(NSString *)userID callback:(void (^)(HBAPUser *user))callback;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithUserID:(NSString *)userID;
- (instancetype)initWithTestUser;

@property (nonatomic, retain, readonly) NSString *realName;
@property (nonatomic, retain, readonly) NSString *screenName;
@property (nonatomic, retain, readonly) NSString *userID;

@property (readonly) BOOL protected;
@property (readonly) BOOL verified;

@property (nonatomic, retain, readonly) NSURL *avatar;
@property (nonatomic, retain) UIImage *cachedAvatar;

@property (readonly) BOOL loadedFullProfile;

@property (nonatomic, retain, readonly) NSString *bio;
@property (nonatomic, retain, readonly) NSString *location;
@property (readonly) BOOL followingMe;
@property (readonly) BOOL following;

@end
