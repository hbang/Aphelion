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
	if (!userIDs || !userIDs.count) {
		callback(@{});
		return;
	}
	
	[[HBAPTwitterAPIClient sharedInstance] getPath:@"users/lookup.json" parameters:@{ @"user_id": [userIDs componentsJoinedByString:@","] } success:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
		NSArray *users = responseObject.objectFromJSONData;
		NSMutableDictionary *newUsers = [NSMutableDictionary dictionary];
		
		for (NSDictionary *user in users) {
			[newUsers setObject:[[[HBAPUser alloc] initWithDictionary:user] autorelease] forKey:user[@"id_str"]];
		}
		
		callback([[newUsers copy] autorelease]);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		HBLogWarn(@"%@",error);
		callback(nil);
	}];
}

+ (void)userWithUserID:(NSString *)userID callback:(void (^)(HBAPUser *user))callback {
	if (!userID) {
		callback(nil);
		return;
	}
	
	[self.class usersWithUserIDs:@[ userID ] callback:^(NSDictionary *users) {
		callback(users[users.allKeys[0]]);
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

- (instancetype)initWithUserID:(NSString *)userID {
	self = [super init];
	
	if (self) {
		_userID = [userID copy];
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

- (instancetype)initWithTestUser {
	self = [super init];
	
	if (self) {
		_realName = [@"Aphelion" retain];
		_screenName = [@"AphelionApp" retain];
		_userID = [@"1657105129" retain];
		_protected = NO;
		_verified = NO;
		_avatar = [[[NSBundle mainBundle] URLForResource:@"icon" withExtension:@"png"] retain];
		_cachedAvatar = [[UIImage imageNamed:@"icon"] retain];
		_loadedFullProfile = YES;
		_bio = [@"Bacon ipsum dolor sit amet sed swine shankle, meatball officia pork aliqua. Boudin sunt shank, kevin short loin laboris culpa http://aphelionapp.com #bacon" retain];
		_followingMe = YES;
		_following = YES;
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
