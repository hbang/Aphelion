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

@implementation HBAPTwitterAPISessionManager

+ (instancetype)sharedInstance {
	static HBAPTwitterAPISessionManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self.class alloc] initWithBaseURL:[NSURL URLWithString:kHBAPTwitterAPIRoot] key:kHBAPTwitterKey secret:kHBAPTwitterSecret];
	});
	
	return sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret {
	self = [super initWithBaseURL:url key:key secret:secret];
	
	if (self) {
		self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
		self.account = [HBAPAccountController sharedInstance].currentAccount;
		
		_configuration = [[HBAPTwitterConfiguration defaultConfiguration] retain];
	}
	
	return self;
}

@end
