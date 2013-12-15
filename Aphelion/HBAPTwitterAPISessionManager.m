//
//  HBAPTwitterAPISessionManager.m
//  Aphelion
//
//  Created by Adam D on 21/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterAPISessionManager.h"
#import "HBAPAccountController.h"
#import "HBAPAccount.h"
#import "HBAPTwitterConfiguration.h"

static NSString *const kHBAPTwitterSecret = @"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";

@implementation HBAPTwitterAPISessionManager

+ (instancetype)sharedInstance {
	static HBAPTwitterAPISessionManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kHBAPTwitterAPIRoot]];
	});
	
	return sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
	self = [super initWithBaseURL:url key:kHBAPTwitterKey secret:kHBAPTwitterSecret];
	
	if (self) {
		// self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeRootCA]; // http://i.imgur.com/KBNcZ.gif
		self.account = [HBAPAccountController sharedInstance].currentAccount;
		
		_configuration = [[HBAPTwitterConfiguration cachedConfigurationIfExists] retain];
	}
	
	return self;
}

#pragma mark - Memory management

- (void)dealloc {
	[_configuration release];
	
	[super dealloc];
}

@end
