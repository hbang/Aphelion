//
//  HBAPCacheManager.m
//  Aphelion
//
//  Created by Adam D on 24/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPCacheManager.h"

@implementation HBAPCacheManager

+ (BOOL)shouldInvalidateTimelineWithVersion:(NSInteger)version {
	return version < 235;
}

@end
