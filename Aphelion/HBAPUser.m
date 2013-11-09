//
//  HBAPUser.m
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterAPISessionManager.h"
#import "HBAPUser.h"
#import "HBAPTweetEntity.h"
#import "UIColor+HBAdditions.h"

@implementation HBAPUser

+ (void)usersWithUserIDs:(NSArray *)userIDs callback:(void (^)(NSDictionary *users))callback {
	if (!userIDs || !userIDs.count) {
		callback(@{});
		return;
	}
	
	[[HBAPTwitterAPISessionManager sharedInstance] GET:@"users/lookup.json" parameters:@{ @"user_id": [userIDs componentsJoinedByString:@","] } success:^(NSURLSessionTask *task, NSArray *responseObject) {
		NSMutableDictionary *newUsers = [NSMutableDictionary dictionary];
		
		for (NSDictionary *user in responseObject) {
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
		_realName = [user[@"name"] copy];
		_screenName = [user[@"screen_name"] copy];
		_userID = [user[@"id_str"] copy];
		
		_protected = ((NSNumber *)user[@"protected"]).boolValue;
		_verified = ((NSNumber *)user[@"verified"]).boolValue;
		
		_avatar = [[NSURL alloc] initWithString:user[@"profile_image_url_https"]];
		_banner = user[@"profile_banner_url"] && ((NSObject *)user[@"profile_banner_url"]).class != NSNull.class ?[[NSURL alloc] initWithString:user[@"profile_banner_url"]] : nil;
		
		_loadedFullProfile = NO;
		
		_bio = [user[@"description"] copy];
		_bioEntities = ((NSArray *)user[@"entities"][@"description"][@"urls"]).count ? [[HBAPTweetEntity entityArrayFromDictionary:user[@"entities"][@"description"] tweet:_bio] retain] : [[NSArray alloc] init];
		_location = [user[@"location"] copy];
		_url = user[@"url"] && ((NSObject *)user[@"url"]).class != NSNull.class ? [[NSURL alloc] initWithString:user[@"url"]] : nil;
		_displayURL = _url ? [user[@"entities"][@"url"][@"urls"][0][@"url"] copy] : nil;
		_profileBackgroundColor = [[UIColor alloc] initWithHexString:user[@"profile_background_color"]];
		_profileLinkColor = [[UIColor alloc] initWithHexString:user[@"profile_text_color"]];
		
		_creationDate = [[NSDate alloc] init]; // TODO: this
		_timezone = [user[@"time_zone"] copy];
		
		_tweetCount = ((NSNumber *)user[@"statuses_count"]).integerValue;
		_followerCount = ((NSNumber *)user[@"followers_count"]).integerValue;
		_followingCount = ((NSNumber *)user[@"friends_count"]).integerValue;
		_favoriteCount = ((NSNumber *)user[@"favourites_count"]).integerValue;
		_listedCount = ((NSNumber *)user[@"listed_count"]).integerValue;
	}
	
	return self;
}

- (instancetype)initWithIncompleteDictionary:(NSDictionary *)user {
	self = [self initWithDictionary:user];
	
	if (self) {
		_loadedFullProfile = NO;
	}
	
	return self;
}

- (instancetype)initWithUserID:(NSString *)userID {
	self = [super init];
	
	if (self) {
		_userID = [userID copy];
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
		_avatar = [[[NSBundle mainBundle] URLForResource:@"AppIcon" withExtension:@"png"] retain];
		_cachedAvatar = [[UIImage imageNamed:@"icon"] retain];
		_loadedFullProfile = YES;
		_bio = [@"Bacon ipsum dolor sit amet sed swine shankle, meatball officia pork aliqua. Boudin sunt shank, kevin short loin laboris culpa http://aphelionapp.com #bacon" retain];
		_bioEntities = [@[
			[[[HBAPTweetEntity alloc] initWithDictionary:@{
				@"display_text": @"aphelionapp.com",
				@"expanded_url": @"http://aphelionapp.com",
				@"indices": @[ @111, @22 ]
			} type:HBAPTweetEntityTypeURL] autorelease],
			[[[HBAPTweetEntity alloc] initWithDictionary:@{
				@"text": @"bacon",
				@"indices": @[ @134, @6 ]
			} type:HBAPTweetEntityTypeHashtag] autorelease]
		] retain];
		_profileBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0.5f alpha:1];
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

- (NSURL *)URLForBannerSize:(HBAPBannerSize)size {
	NSString *sizeString = @"_bigger";
	
	switch (size) {
		case HBAPBannerSizeWeb:
			sizeString = @"web";
			break;
		
		case HBAPBannerSizeWeb2x:
			sizeString = @"web_retina";
			break;
			
		case HBAPBannerSizeIPad:
			sizeString = @"ipad";
			break;
			
		case HBAPBannerSizeIPad2x:
			sizeString = @"ipad_retina";
			break;
			
		case HBAPBannerSizeMobile:
			sizeString = @"mobile";
			break;
			
		case HBAPBannerSizeMobile2x:
			sizeString = @"mobile_retina";
			break;
	}
	
	return [_banner URLByAppendingPathComponent:sizeString];
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
	[encoder encodeObject:_banner forKey:@"banner"];
	[encoder encodeBool:_loadedFullProfile forKey:@"loadedFullProfile"];
	[encoder encodeObject:_bio forKey:@"bio"];
	[encoder encodeObject:_bioEntities forKey:@"bioEntities"];
	[encoder encodeObject:_location forKey:@"location"];
	[encoder encodeObject:_url forKey:@"url"];
	[encoder encodeObject:_displayURL forKey:@"displayURL"];
	[encoder encodeObject:_profileBackgroundColor forKey:@"profileBackgroundColor"];
	[encoder encodeObject:_profileLinkColor forKey:@"profileLinkColor"];
	[encoder encodeObject:_creationDate forKey:@"creationDate"];
	[encoder encodeObject:_timezone forKey:@"timezone"];
	[encoder encodeInteger:_tweetCount forKey:@"tweetCount"];
	[encoder encodeInteger:_followerCount forKey:@"followerCount"];
	[encoder encodeInteger:_followingCount forKey:@"followingCount"];
	[encoder encodeInteger:_favoriteCount forKey:@"favoriteCount"];
	[encoder encodeInteger:_listedCount forKey:@"listedCount"];
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
		_banner = [[decoder decodeObjectForKey:@"banner"] copy];
		_loadedFullProfile = [decoder decodeBoolForKey:@"loadedFullProfile"];
		_bio = [[decoder decodeObjectForKey:@"bio"] copy];
		_bioEntities = [[decoder decodeObjectForKey:@"bioEntities"] copy];
		_location = [[decoder decodeObjectForKey:@"location"] copy];
		_url = [[decoder decodeObjectForKey:@"url"] copy];
		_displayURL = [[decoder decodeObjectForKey:@"displayURL"] copy];
		_profileBackgroundColor = [[decoder decodeObjectForKey:@"profileBackgroundColor"] copy];
		_profileLinkColor = [[decoder decodeObjectForKey:@"profileLinkColor"] copy];
		_creationDate = [[decoder decodeObjectForKey:@"creationDate"] copy];
		_timezone = [[decoder decodeObjectForKey:@"timezone"] copy];
		_tweetCount = [decoder decodeIntegerForKey:@"tweetCount"];
		_followerCount = [decoder decodeIntegerForKey:@"followerCount"];
		_followingCount = [decoder decodeIntegerForKey:@"followingCount"];
		_favoriteCount = [decoder decodeIntegerForKey:@"favoriteCount"];
		_listedCount = [decoder decodeIntegerForKey:@"listedCount"];
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
