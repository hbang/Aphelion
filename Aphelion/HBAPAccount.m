//
//  HBAPAccount.m
//  Aphelion
//
//  Created by Adam D on 16/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAccount.h"
#import "HBAPUser.h"

@implementation HBAPAccount

@synthesize userID = _userID, accessToken = _accessToken, accessSecret = _accessSecret, user = _user;

- (instancetype)initWithUserID:(NSString *)userID token:(NSString *)accessToken secret:(NSString *)accessSecret {
	self = [super init];
	
	if (self) {
		_userID = userID;
		_accessToken = accessToken;
		_accessSecret = accessSecret;
		_user = [[HBAPUser alloc] init]; // TODO: sort this out
	}
	
	return self;
}

@end
