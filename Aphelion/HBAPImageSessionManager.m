//
//  HBAPImageSessionManager.m
//  Aphelion
//
//  Created by Adam D on 24/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPImageSessionManager.h"

@implementation HBAPImageSessionManager

+ (instancetype)sharedInstance {
	static HBAPImageSessionManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	
	return sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
	self = [super initWithBaseURL:url];
	
	if (self) {
		self.responseSerializer = [[[AFImageResponseSerializer alloc] init] autorelease];
	}
	
	return self;
}

@end
