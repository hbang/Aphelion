//
//  HBAPAccountController.m
//  Aphelion
//
//  Created by Adam D on 6/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAccountController.h"
#import "HBAPAccount.h"
#import <LUKeychainAccess/LUKeychainAccess.h>

@implementation HBAPAccountController

+ (instancetype)sharedInstance {
	static HBAPAccountController *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	
	return sharedInstance;
}

- (NSArray *)allAccounts {
	NSDictionary *accounts = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"];
	if (!accounts || !accounts.count) {
		return nil;
	}
	
	NSMutableArray *newAccounts = [NSMutableArray array];
	
	for (NSString *userID in accounts.allKeys) {
		[newAccounts addObject:[self accountForUserID:userID]];
	}
	
	return [[newAccounts copy] autorelease];
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

@end
