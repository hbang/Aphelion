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

- (instancetype)initWithUserID:(NSString *)userID token:(NSString *)accessToken secret:(NSString *)accessSecret {
	self = [super init];
	
	if (self) {
		_userID = [userID copy];
		_accessToken = [accessToken copy];
		_accessSecret = [accessSecret copy];
		_user = [[HBAPUser alloc] initWithUserID:userID];
	}
	
	return self;
}

- (void)getUser:(void (^)(HBAPUser *user))callback {
	[HBAPUser userWithUserID:_userID callback:^(HBAPUser *user) {
		_user = user;
		callback(user);
	}];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; userID = %@>", self.class, self, _userID];
}

@end
