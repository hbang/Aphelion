//
//  HBAPTwitterConfiguration.m
//  Aphelion
//
//  Created by Adam D on 29/10/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterConfiguration.h"
#import "HBAPTwitterAPISessionManager.h"
#import "NSData+HBAdditions.h"

static NSString *const HBAPTwitterConfigurationKey = @"twitterConfiguration";
static NSString *const HBAPTwitterConfigurationUpdatedKey = @"twitterConfigurationUpdatedDate";

@implementation HBAPTwitterConfiguration

+ (BOOL)hasCachedConfiguration {
	return !![[NSUserDefaults standardUserDefaults] objectForKey:HBAPTwitterConfigurationKey];
}

+ (instancetype)cachedConfigurationIfExists {
	return [self.class hasCachedConfiguration] ? [[[self.class alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:HBAPTwitterConfigurationKey]] autorelease] : nil;
}

+ (instancetype)defaultConfiguration {
	return [[[self.class alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"configuration" ofType:@"plist"]]] autorelease];
}

+ (NSDate *)lastUpdated {
	return [[NSUserDefaults standardUserDefaults] objectForKey:HBAPTwitterConfigurationUpdatedKey] ?: [NSDate dateWithTimeIntervalSince1970:0];
}

+ (BOOL)needsUpdating {
	return [self.class lastUpdated].timeIntervalSinceNow < -86400; // 1 day
}

+ (void)updateIfNeeded {
	if ([self.class needsUpdating]) {
		[[HBAPTwitterAPISessionManager sharedInstance] GET:@"help/configuration.json" parameters:nil success:^(NSURLSessionTask *task, NSData *responseObject) {
			NSDictionary *configuration = responseObject.objectFromJSONData;
			
			[HBAPTwitterAPISessionManager sharedInstance].configuration = [[[self.class alloc] initWithDictionary:configuration] autorelease];
			[[NSUserDefaults standardUserDefaults] setObject:configuration forKey:HBAPTwitterConfigurationKey];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:HBAPTwitterConfigurationUpdatedKey];
		} failure:^(NSURLSessionTask *task, NSError *error) {
			if ([self.class hasCachedConfiguration]) {
				HBLogWarn(@"couldn't get updated configuration from twitter. using previous configuration. (%@)", error);
			} else {
				HBLogError(@"couldn't get updated configuration from twitter. falling back to stored configuration. (%@)", error);
				
				[HBAPTwitterAPISessionManager sharedInstance].configuration = [self.class defaultConfiguration];
			}
		}];
	}
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	self = [super init];
	
	if (self) {
		_tcoHttpLength = ((NSNumber *)dictionary[@"short_url_length"]).intValue;
		_tcoHttpsLength = ((NSNumber *)dictionary[@"short_url_length_https"]).intValue;
		
		_twitterMediaURLLength = ((NSNumber *)dictionary[@"characters_reserved_per_media"]).intValue;
		_twitterMediaMax = ((NSNumber *)dictionary[@"max_media_per_upload"]).intValue;
		_twitterMediaSizeLimit = ((NSNumber *)dictionary[@"photo_size_limit"]).intValue;
		_twitterMediaSizes = [dictionary[@"photo_sizes"] copy];
		
		_nonUsernamePaths = [dictionary[@"non_username_paths"] copy];
	}
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; lastUpdated = %@; needsUpdating = %i>", NSStringFromClass(self.class), self, [self.class lastUpdated], [self.class needsUpdating]];
}

@end
