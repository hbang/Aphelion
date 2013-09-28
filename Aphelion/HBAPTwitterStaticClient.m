//
//  HBAPTwitterStaticClient.m
//  Aphelion
//
//  Created by Adam D on 22/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterStaticClient.h"

@implementation HBAPTwitterStaticClient

+ (instancetype)sharedInstance {
	static HBAPTwitterStaticClient *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self.class alloc] init];
	});
	
	return sharedInstance;
}


@end
