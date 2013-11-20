//
//  HBAPAccountController.m
//  Aphelion
//
//  Created by Adam D on 6/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAccountController.h"
#import "HBAPAccount.h"
#import "HBAPUser.h"
#import <LUKeychainAccess/LUKeychainAccess.h>

@interface HBAPAccountController () {
	NSDictionary *_accounts;
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
		[self updateAccounts];
	}
	
	return self;
}

- (void)updateAccounts {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[_accounts release];
		
		NSDictionary *accounts = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"];
		
		if (!accounts || !accounts.count) {
			_accounts = [[NSMutableDictionary alloc] init];
			return;
		}
		
		NSMutableDictionary *newAccounts = [NSMutableDictionary dictionary];
		
		for (NSString *userID in accounts.allKeys) {
			newAccounts[userID] = [[[HBAPAccount alloc] initWithUserID:userID token:accounts[userID][@"token"] secret:accounts[userID][@"secret"]] autorelease];
		}
		
		_accounts = [newAccounts copy];
		
		[self _updateUsers];
	});
}

- (void)_updateUsers {
	[HBAPUser usersWithUserIDs:_accounts.allKeys callback:^(NSDictionary *users) {
		for (NSString *key in users.allKeys) {
			((HBAPAccount *)_accounts[key]).user = users[key];
		}
		
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBAPAccountControllerDidReloadUsers object:nil]];
	}];
}

- (HBAPAccount *)currentAccount {
	if (_accounts.allKeys.count == 0) {
		return nil;
	}
	
	return _accounts[_accounts.allKeys[0]]; // TODO: actually get the right user
}

@end
