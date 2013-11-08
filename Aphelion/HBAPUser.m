//
//  HBAPUser.m
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterAPISessionManager.h"
#import "HBAPUser.h"
#import "NSData+HBAdditions.h"

@implementation HBAPUser

+ (void)usersWithUserIDs:(NSArray *)userIDs callback:(void (^)(NSDictionary *users))callback {
	if (!userIDs || !userIDs.count) {
		callback(@{});
		return;
	}
	
	[[HBAPTwitterAPISessionManager sharedInstance] GET:@"users/lookup.json" parameters:@{ @"user_id": [userIDs componentsJoinedByString:@","] } success:^(NSURLSessionTask *task, NSData *responseObject) {
		NSArray *users = responseObject.objectFromJSONData;
		NSMutableDictionary *newUsers = [NSMutableDictionary dictionary];
		
		for (NSDictionary *user in users) {
			[newUsers setObject:[[[HBAPUser alloc] initWithDictionary:user] autorelease] forKey:user[@"id_str"]];
		}
		
		callback([[newUsers copy] autorelease]);
	} failure:^(NSURLSessionTask *task, NSError *error) {
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

- (NSURL *)URLForAvatarSize:(HBAPAvatarSize)size {
	NSString *sizeString = @"_bigger";
	
	switch (size) {
		case HBAPAvatarSizeMini:
			sizeString = @"_mini";
			break;
		
		case HBAPAvatarSizeNormal:
			sizeString = @"_normal";
			break;
		
		case HBAPAvatarSizeBigger:
			sizeString = @"_bigger";
			break;
		
		case HBAPAvatarSizeOriginal:
			sizeString = @"";
			break;
	}
	
	// "_normal".length = 7
	NSString *newPath = _avatar.path.stringByDeletingPathExtension;
	newPath = [newPath stringByReplacingCharactersInRange:NSMakeRange(newPath.length - 7, 7) withString:sizeString];
	
	NSURLComponents *components = [NSURLComponents componentsWithURL:_avatar resolvingAgainstBaseURL:YES];
	components.path = [newPath stringByAppendingPathExtension:_avatar.pathExtension];
	return components.URL;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; id = %@; screenName = %@; realName = %@>", NSStringFromClass(self.class), self, _userID, _screenName, _realName];
}

#pragma mark - NSCopying/NSCoding

- (instancetype)copyWithZone:(NSZone *)zone {
	return [(HBAPUser *)[self.class alloc] initWithUser:self];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:_realName forKey:@"realName"];
	[encoder encodeObject:_screenName forKey:@"screenName"];
	[encoder encodeObject:_userID forKey:@"userID"];
	[encoder encodeBool:_protected forKey:@"protected"];
	[encoder encodeBool:_verified forKey:@"verified"];
	[encoder encodeObject:_avatar forKey:@"avatar"];
	[encoder encodeObject:_cachedAvatar forKey:@"cachedAvatar"];
	[encoder encodeBool:_loadedFullProfile forKey:@"loadedFullProfile"];
	[encoder encodeObject:_bio forKey:@"bio"];
	[encoder encodeObject:_location forKey:@"location"];
	[encoder encodeBool:_followingMe forKey:@"followingMe"];
	[encoder encodeBool:_following forKey:@"following"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
	self = [self init];
	
	if (self) {
		_realName = [[decoder decodeObjectForKey:@"realName"] copy];
		_screenName = [[decoder decodeObjectForKey:@"screenName"] copy];
		_userID = [[decoder decodeObjectForKey:@"userID"] copy];
		_protected = [decoder decodeBoolForKey:@"protected"];
		_verified = [decoder decodeBoolForKey:@"verified"];
		_avatar = [[decoder decodeObjectForKey:@"avatar"] copy];
		_cachedAvatar = [[decoder decodeObjectForKey:@"cachedAvatar"] copy];
		_loadedFullProfile = [decoder decodeBoolForKey:@"loadedFullProfile"];
		_bio = [[decoder decodeObjectForKey:@"bio"] copy];
		_location = [[decoder decodeObjectForKey:@"location"] copy];
		_followingMe = [decoder decodeBoolForKey:@"followingMe"];
		_following = [decoder decodeBoolForKey:@"following"];
	}
	
	return self;
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
