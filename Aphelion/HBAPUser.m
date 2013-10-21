//
//  HBAPUser.m
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterAPIClient.h"
#import "HBAPUser.h"
#import "NSData+HBAdditions.h"

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
		HBLogWarn(@"%@",error);
		callback(nil);
	}];
}

+ (void)userWithUserID:(NSString *)userID callback:(void (^)(HBAPUser *users))callback {
	[[HBAPTwitterAPIClient sharedInstance] getPath:@"users/show" parameters:@{ @"user_id": userID } success:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
		callback([[HBAPUser alloc] initWithDictionary:responseObject.objectFromJSONData]);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		HBLogWarn(@"%@",error);
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

- (instancetype)initWithUser:(HBAPUser *)user {
	self = [super init];
	
	if (self) {
		_realName = [user.realName copy];
		_screenName = [user.screenName copy];
		_userID = [user.userID copy];
		_protected = user.protected;
		_verified = user.verified;
		_avatar = [user.avatar copy];
		_cachedAvatar = [user.cachedAvatar copy];
		_loadedFullProfile = user.loadedFullProfile;
		_bio = [user.bio copy];
		_location = [user.location copy];
		_followingMe = user.followingMe;
		_following = user.following;
	}
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; id = %@; screenName = %@; realName = %@>", NSStringFromClass(self.class), self, _userID, _screenName, _realName];
}

- (instancetype)copyWithZone:(NSZone *)zone {
	return [(HBAPUser *)[self.class alloc] initWithUser:self];
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
