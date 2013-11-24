//
//  HBAPUser.h
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HBAPAvatarSize) {
	HBAPAvatarSizeMini, // 24x24,
	HBAPAvatarSizeNavBar, // 32x32
	HBAPAvatarSizeNormal, // 48x48
	HBAPAvatarSizeBigger, // 73x73
	HBAPAvatarSizeReasonablySmall, // 128x128
	HBAPAvatarSizeOriginal
};

typedef NS_ENUM(NSUInteger, HBAPBannerSize) {
	HBAPBannerSizeWeb, // 520x260
	HBAPBannerSizeWeb2x, // 1040x520
	HBAPBannerSizeIPad, // 626x313
	HBAPBannerSizeIPad2x, // 1252x626
	HBAPBannerSizeMobile, // 320x160
	HBAPBannerSizeMobile2x // 640x320
};

@interface HBAPUser : NSObject

+ (void)usersWithUserIDs:(NSArray *)userIDs callback:(void (^)(NSDictionary *users))callback;
+ (void)userWithUserID:(NSString *)userID callback:(void (^)(HBAPUser *user))callback;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithIncompleteDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithUserID:(NSString *)userID;
- (instancetype)initWithTestUser;
- (instancetype)initStubWithUserID:(NSString *)userID screenName:(NSString *)screenName realName:(NSString *)realName;

- (NSURL *)URLForAvatarSize:(HBAPAvatarSize)size;
- (NSURL *)URLForBannerSize:(HBAPBannerSize)size;

- (void)resetAttributedString;
- (void)createAttributedStringIfNeeded;

@property (nonatomic, retain, readonly) NSString *realName;
@property (nonatomic, retain, readonly) NSString *screenName;
@property (nonatomic, retain, readonly) NSString *userID;

@property (readonly) BOOL protected;
@property (readonly) BOOL verified;

@property (nonatomic, retain, readonly) NSURL *avatar;
@property (nonatomic, retain, readonly) NSURL *banner;

@property (readonly) BOOL loadedFullProfile;

@property (nonatomic, retain, readonly) NSString *bio;
@property (nonatomic, retain) NSString *bioDisplayText;
@property (nonatomic, retain, readonly) NSArray *bioEntities;
@property (nonatomic, retain, readonly) NSAttributedString *bioAttributedString;

@property (nonatomic, retain, readonly) NSString *location;
@property (nonatomic, retain, readonly) NSURL *url;
@property (nonatomic, retain, readonly) NSString *displayURL;
@property (nonatomic, retain, readonly) UIColor *profileBackgroundColor;
@property (nonatomic, retain, readonly) UIColor *profileLinkColor;

@property (nonatomic, retain, readonly) NSDate *creationDate;
@property (nonatomic, retain, readonly) NSString *timezone;
@property (readonly) NSInteger timezoneOffset;

@property (readonly) NSInteger tweetCount;
@property (readonly) NSInteger followerCount;
@property (readonly) NSInteger followingCount;
@property (readonly) NSInteger favoriteCount;
@property (readonly) NSInteger listedCount;

@end
