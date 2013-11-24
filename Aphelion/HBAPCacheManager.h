//
//  HBAPCacheManager.h
//  Aphelion
//
//  Created by Adam D on 24/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBAPCacheManager : NSObject

+ (BOOL)shouldInvalidateTimelineWithVersion:(NSInteger)version;

@end
