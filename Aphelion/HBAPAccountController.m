//
//  HBAPAccountController.m
//  Aphelion
//
//  Created by Adam D on 6/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAccountController.h"
#import "HBAPAccount.h"
#import "AFOAuth1Client.h"
#import "LUKeychainAccess/LUKeychainAccess.h"

@interface HBAPAccountController () {
	NSMutableDictionary *_tokenCache;
}

@end

@implementation HBAPAccountController

+ (instancetype)sharedInstance {
	static HBAPAccountController *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	
	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
		_tokenCache = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (HBAPAccount *)accountForCurrentUser {
	NSDictionary *accounts = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"];
	if (!accounts || !accounts.count) {
		return nil;
	}
	
	return [self accountForUserID:accounts.allKeys[0]]; // TODO: actually get the right user
}

- (HBAPAccount *)accountForUserID:(NSString *)userID {
	NSDictionary *tokens = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"];
	
	if (!tokens[userID]) {
		return nil;
	}
	
	return [[[HBAPAccount alloc] initWithUserID:userID token:tokens[userID][@"token"] secret:tokens[userID][@"secret"]] autorelease];
}

- (AFOAuth1Token *)accessTokenForAccount:(HBAPAccount *)account {
	if (account.accessToken && account.accessSecret && !_tokenCache[account.userID]) {
		_tokenCache[account.userID] = [[[AFOAuth1Token alloc] initWithKey:account.accessToken secret:account.accessSecret session:nil expiration:nil renewable:NO] autorelease];
	}
	
	return _tokenCache[account.userID];
}

@end
