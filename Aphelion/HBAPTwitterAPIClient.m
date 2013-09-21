//
//  HBAPTwitterAPIClient.m
//  Aphelion
//
//  Created by Adam D on 21/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterAPIClient.h"
#import "AFOAuth1Client/AFOAuth1Client.h"

@implementation HBAPTwitterAPIClient

@synthesize OAuthClient = _OAuthClient;

+ (instancetype)sharedInstance {
	static HBAPTwitterAPIClient *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kHBAPTwitterAPIRoot]];
	});
	
	return sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
	self = [super initWithBaseURL:url];
	
	if (self) {
		_OAuthClient = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:kHBAPTwitterOAuthRoot] key:kHBAPTwitterKey secret:kHBAPTwitterSecret];
	}
	
	return self;
}



@end
