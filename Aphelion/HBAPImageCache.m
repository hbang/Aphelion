//
//  HBAPImageCache.m
//  Aphelion
//
//  Created by Adam D on 13/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPImageCache.h"

@implementation HBAPImageCache

+ (instancetype)sharedInstance {
	static HBAPImageCache *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self.class alloc] init];
	});
	
	return sharedInstance;
}

- (UIImage *)avatarForUser:(HBAPUser *)user ofSize:(HBAPAvatarSize)size {
	NOIMP
	return nil;
}

- (UIImage *)bannerForUser:(HBAPUser *)user ofSize:(HBAPAvatarSize)size {
	NOIMP
	return nil;
}

@end
