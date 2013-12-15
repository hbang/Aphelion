//
//  HBAPTwitterOAuthSessionManager.m
//  Aphelion
//
//  Created by Adam D on 20/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterOAuthSessionManager.h"

@implementation HBAPTwitterOAuthSessionManager

+ (instancetype)sharedInstance {
	static HBAPTwitterOAuthSessionManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kHBAPTwitterOAuthRoot]];
	});
	
	return sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
	self = [super initWithBaseURL:url];
	
	if (self) {
		self.responseSerializer = [[[AFHTTPResponseSerializer alloc] init] autorelease];
	}
	
	return self;
}

@end
