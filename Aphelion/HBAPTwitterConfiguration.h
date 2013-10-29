//
//  HBAPTwitterConfiguration.h
//  Aphelion
//
//  Created by Adam D on 29/10/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBAPTwitterConfiguration : NSObject

+ (instancetype)cachedConfigurationIfExists;
+ (instancetype)defaultConfiguration;
+ (void)updateIfNeeded;
+ (NSDate *)lastUpdated;
+ (BOOL)needsUpdating;

@property (nonatomic, retain) NSDate *lastUpdated;

@property NSUInteger tcoHttpLength;
@property NSUInteger tcoHttpsLength;

@property NSUInteger twitterMediaURLLength;
@property NSUInteger twitterMediaMax;
@property NSUInteger twitterMediaSizeLimit;
@property (nonatomic, retain) NSArray *twitterMediaSizes;

@property (nonatomic, retain) NSArray *nonUsernamePaths;

@end
