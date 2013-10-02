//
//  HBAPUser.m
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterAPIClient.h"
#import "HBAPUser.h"
#import <JSONKit/JSONKit.h>

@implementation HBAPUser

+ (void)usersWithUserIDs:(NSArray *)userIDs callback:(void (^)(NSDictionary *users))callback {
	[[HBAPTwitterAPIClient sharedInstance] getPath:@"users/lookup" parameters:@{ @"user_id": [userIDs componentsJoinedByString:@","] } success:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
		NSArray *users = responseObject.objectFromJSONData;
		NSMutableArray *newUsers = [NSMutableArray array];
		
		for (NSDictionary *user in users) {
			[newUsers addObject:[[[HBAPUser alloc] initWithDictionary:user] autorelease]];
		}
		
		callback([[newUsers copy] autorelease]);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		callback(nil);
	}];
}

+ (void)userWithUserID:(NSString *)userID callback:(void (^)(HBAPUser *users))callback {
	[[HBAPTwitterAPIClient sharedInstance] getPath:@"users/show" parameters:@{ @"user_id": userID } success:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
		callback([[HBAPUser alloc] initWithDictionary:responseObject.objectFromJSONData]);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		callback(nil);
	}];
}

- (instancetype)initWithDictionary:(NSDictionary *)user {
	self = [super init];
	
	if (self) {
		_realName = [[user objectForKey:@"name"] copy];
		_screenName = [[user objectForKey:@"screen_name"] copy];
		
		_userID = [[user objectForKey:@"id_str"] copy];
		
		_protected = ((NSNumber *)[user objectForKey:@"protected"]).boolValue;
		_verified = ((NSNumber *)[user objectForKey:@"verified"]).boolValue;
		
		_avatar = [[NSURL alloc] initWithString:[user objectForKey:@"profile_image_url_https"]];
		
		_loadedFullProfile = NO;
	}
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; id = %@; screenName = %@; realName = %@>", NSStringFromClass(self.class), self, _userID, _screenName, _realName];
}

#pragma mark - Memory management

- (void)dealloc {
	[_realName release];
	[_screenName release];
	[_userID release];
	
	[_avatar release];
	[_cachedAvatar release];
	
	[_bio release];
	[_location release];
	
	[super dealloc];
}

@end
