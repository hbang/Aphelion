//
//  HBAPTwitterOAuthSessionManager.m
//  Aphelion
//
//  Created by Adam D on 20/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterOAuthSessionManager.h"

@implementation HBAPTwitterOAuthSessionManager

- (instancetype)initWithBaseURL:(NSURL *)url {
	self = [super initWithBaseURL:url];
	
	if (self) {
		self.responseSerializer = [[[AFHTTPResponseSerializer alloc] init] autorelease];
	}
	
	return self;
}

@end
