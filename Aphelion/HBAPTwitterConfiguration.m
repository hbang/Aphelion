//
//  HBAPTwitterConfiguration.m
//  Aphelion
//
//  Created by Adam D on 29/10/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterConfiguration.h"
#import "HBAPTwitterAPIClient.h"
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

+ (NSDate *)lastUpdated {
	return [[NSUserDefaults standardUserDefaults] objectForKey:HBAPTwitterConfigurationUpdatedKey] ?: [NSDate dateWithTimeIntervalSince1970:0];
}

+ (BOOL)needsUpdating {
	return [self.class lastUpdated].timeIntervalSinceNow < -86400; // 1 day
}

+ (void)updateIfNeeded {
	if ([self.class needsUpdating]) {
		[[HBAPTwitterAPIClient sharedInstance] getPath:@"help/configuration.json" parameters:nil success:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
			NSDictionary *configuration = responseObject.objectFromJSONData;
			
			[HBAPTwitterAPIClient sharedInstance].configuration = [[[self.class alloc] initWithDictionary:configuration] autorelease];
			[[NSUserDefaults standardUserDefaults] setObject:configuration forKey:HBAPTwitterConfigurationKey];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:HBAPTwitterConfigurationUpdatedKey];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			if ([self.class hasCachedConfiguration]) {
				HBLogWarn(@"couldn't get updated configuration from twitter. using previous configuration. (%@)", error);
			} else {
				HBLogError(@"couldn't get updated configuration from twitter. falling back to stored configuration. (%@)", error);
				
				[HBAPTwitterAPIClient sharedInstance].configuration = [[[self.class alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"configuration" ofType:@"plist"]]] autorelease];
			}
		}];
	}
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	self = [super init];
	
	if (self) {
		_tcoHttpLength = ((NSNumber *)dictionary[@"short_url_length"]).unsignedIntegerValue;
		_tcoHttpsLength = ((NSNumber *)dictionary[@"short_url_length_https"]).unsignedIntegerValue;
		
		_twitterMediaURLLength = ((NSNumber *)dictionary[@"characters_reserved_per_media"]).unsignedIntegerValue;
		_twitterMediaMax = ((NSNumber *)dictionary[@"max_media_per_upload"]).unsignedIntegerValue;
		_twitterMediaSizeLimit = ((NSNumber *)dictionary[@"photo_size_limit"]).unsignedIntegerValue;
		_twitterMediaSizes = [dictionary[@"photo_sizes"] copy];
		
		_nonUsernamePaths = [dictionary[@"non_username_paths"] copy];
	}
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; lastUpdated = %@; needsUpdating = %i>", NSStringFromClass(self.class), self, [self.class lastUpdated], [self.class needsUpdating]];
}

@end
