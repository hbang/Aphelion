//
//  HBAPAccountController.m
//  Aphelion
//
//  Created by Adam D on 6/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAccountController.h"

static HBAPAccountController *sharedInstance;

@interface HBAPAccountController () {
	ACAccountStore *_accountStore;
}

@end

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
		_accountStore = [[ACAccountStore alloc] init];
	}
	
	return self;
}

- (ACAccount *)accountWithUsername:(NSString *)username {
	return [_accountStore accountWithIdentifier:username];
}

@end
