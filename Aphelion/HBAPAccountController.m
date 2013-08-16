//
//  HBAPAccountController.m
//  Aphelion
//
//  Created by Adam D on 6/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAccountController.h"

static HBAPAccountController *sharedInstance;

@implementation HBAPAccountController

+ (instancetype)sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	
	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
		// ...
	}
	
	return self;
}

- (HBAPAccount *)accountWithUsername:(NSString *)username {
	return nil;
}

@end
