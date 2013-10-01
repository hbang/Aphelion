//
//  HBAPUser.h
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBAPUser : NSObject

+ (void)usersWithUserIDs:(NSArray *)userIDs callback:(void (^)(NSDictionary *users))callback;
+ (void)userWithUserID:(NSString *)userID callback:(void (^)(HBAPUser *user))callback;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSString *realName;
@property (nonatomic, retain) NSString *screenName;
@property (nonatomic, retain) NSString *userID;

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
