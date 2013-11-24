//
//  HBAPAccount.m
//  Aphelion
//
//  Created by Adam D on 16/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAccount.h"
#import "HBAPUser.h"

@interface HBAPAccount () {
	HBAPUser *_user;
}

@end

@implementation HBAPAccount

#pragma mark - Constants

+ (NSString *)cachePathForUserID:(NSString *)userID {
	return [[[GET_DIR(NSCachesDirectory) stringByAppendingPathComponent:@"accounts"] stringByAppendingPathComponent:userID] stringByAppendingPathExtension:@"plist"];
}

#pragma mark - Implementation

- (instancetype)initWithUserID:(NSString *)userID token:(NSString *)accessToken secret:(NSString *)accessSecret {
	self = [super init];
	
	if (self) {
		_userID = [userID copy];
		_accessToken = [accessToken copy];
		_accessSecret = [accessSecret copy];
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:[self.class cachePathForUserID:_userID]]) {
			_user = [[NSKeyedUnarchiver unarchiveObjectWithFile:[self.class cachePathForUserID:_userID]] retain];
		} else {
			_user = [[HBAPUser alloc] initWithUserID:userID];
		}
	}
	
	return self;
}

- (HBAPUser *)user {
	return _user;
}

- (void)setUser:(HBAPUser *)user {
	if (_user == user) {
		return;
	}
	
	_user = [user copy];
	
	[NSKeyedArchiver archiveRootObject:_user toFile:[self.class cachePathForUserID:_user.userID]];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; userID = %@>", self.class, self, _userID];
}

#pragma mark - Memory managment

- (void)dealloc {
	[_userID release];
	[_accessToken release];
	[_accessSecret release];
	[_user release];
	
	[super dealloc];
}

@end
