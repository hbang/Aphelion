//
//  HBAPLinkManager.m
//  Aphelion
//
//  Created by Adam D on 30/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPLinkManager.h"

@implementation HBAPLinkManager

+ (instancetype)sharedInstance {
	static HBAPLinkManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self.class alloc] init];
	});
	
	return sharedInstance;
}

- (void)openURL:(NSURL *)url navigationController:(UINavigationController *)navigationController {
	NOIMP
	[[UIApplication sharedApplication] openURL:url];
}

- (void)showActionSheetForURL:(NSURL *)url navigationController:(UINavigationController *)navigationController {
	NOIMP
}

@end
