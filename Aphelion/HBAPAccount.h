//
//  HBAPAccount.h
//  Aphelion
//
//  Created by Adam D on 16/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBAPUser;

@interface HBAPAccount : NSObject {
	NSString *_userID;
	NSString *_accessToken;
	NSString *_accessSecret;
	HBAPUser *_user;
}

- (instancetype)initWithUserID:(NSString *)userID token:(NSString *)accessToken secret:(NSString *)accessSecret;

@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *accessSecret;
@property (nonatomic, retain) HBAPUser *user;

@end
