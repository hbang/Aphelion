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
#import "HBAPTweetAttributedStringFactory.h"
#import "HBAPFontManager.h"
#import "UIColor+HBAdditions.h"

@implementation HBAPUser

#pragma mark - Constants

+ (UIFont *)defaultAttributedStringFont {
	return [HBAPFontManager sharedInstance].bodyFont;
}

+ (BOOL)supportsSecureCoding {
	return YES;
}

#pragma mark - User getters

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
		HBLogError(@"couldn't get users %@: %@", userIDs, error);
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

+ (void)usersWithScreenNames:(NSArray *)screenNames callback:(void (^)(NSDictionary *users))callback {
	if (!screenNames || !screenNames.count) {
		callback(@{});
		return;
	}
	
	[[HBAPTwitterAPISessionManager sharedInstance] GET:@"users/lookup.json" parameters:@{ @"screen_name": [screenNames componentsJoinedByString:@","] } success:^(NSURLSessionTask *task, NSArray *responseObject) {
		NSMutableDictionary *newUsers = [NSMutableDictionary dictionary];
		
		for (NSDictionary *user in responseObject) {
			[newUsers setObject:[[[HBAPUser alloc] initWithDictionary:user] autorelease] forKey:user[@"screen_name"]];
		}
		
		callback([[newUsers copy] autorelease]);
	} failure:^(NSURLSessionTask *task, NSError *error) {
		HBLogError(@"couldn't get users %@: %@", screenNames, error);
		callback(nil);
	}];
}

+ (void)userWithScreenName:(NSString *)screenName callback:(void (^)(HBAPUser *user))callback {
	if (!screenName) {
		callback(nil);
		return;
	}
	
	[self.class usersWithScreenNames:@[ screenName ] callback:^(NSDictionary *users) {
		callback(users[users.allKeys[0]]);
	}];
}

#pragma mark - Implementation

- (instancetype)initWithDictionary:(NSDictionary *)user {
	self = [super init];
	
	if (self) {
		static NSDateFormatter *dateFormatter;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			dateFormatter = [[NSDateFormatter alloc] init];
			dateFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
			dateFormatter.dateFormat = @"eee MMM dd HH:mm:ss ZZZZ yyyy"; // "Tue Apr 30 07:36:58 +0000 2013"
		});
		
		_realName = [user[@"name"] copy];
		_screenName = [user[@"screen_name"] copy];
		_userID = [user[@"id_str"] copy];
		
		_protected = ((NSNumber *)user[@"protected"]).boolValue;
		_verified = ((NSNumber *)user[@"verified"]).boolValue;
		
		_avatar = [[NSURL alloc] initWithString:user[@"profile_image_url_https"]];
		_banner = user[@"profile_banner_url"] && ((NSObject *)user[@"profile_banner_url"]).class != NSNull.class ? [[NSURL alloc] initWithString:user[@"profile_banner_url"]] : nil;
		
		_loadedFullProfile = NO;
		
		_bio = [user[@"description"] copy];
		_bioEntities = ((NSArray *)user[@"entities"][@"description"][@"urls"]).count ? [[HBAPTweetEntity entityArrayFromDictionary:user[@"entities"][@"description"] tweet:_bio] retain] : [[NSArray alloc] init];
		_location = [user[@"location"] copy];
		_url = user[@"url"] && ((NSObject *)user[@"url"]).class != NSNull.class ? [[NSURL alloc] initWithString:user[@"url"]] : nil;
		_displayURL = _url ? [user[@"entities"][@"url"][@"urls"][0][@"display_url"] copy] : nil;
		_profileBackgroundColor = [user[@"profile_background_color"] isEqualToString:@"C0DEED"] ? nil : [[UIColor alloc] initWithHexString:user[@"profile_background_color"]];
		_profileLinkColor = [[UIColor alloc] initWithHexString:user[@"profile_text_color"]];
		
		_creationDate = [[dateFormatter dateFromString:user[@"created_at"]] retain];
		_timezone = [user[@"time_zone"] isKindOfClass:NSNull.class] ? nil : [user[@"time_zone"] copy];
		_timezoneOffset = [user[@"utc_offset"] isKindOfClass:NSNull.class] ? 0 : ((NSNumber *)user[@"utc_offset"]).integerValue;
		
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
		_banner = [user.banner copy];
		_loadedFullProfile = user.loadedFullProfile;
		_bio = [user.bio copy];
		_bioEntities = [user.bioEntities copy];
		_location = [user.location copy];
		_url = [user.url copy];
		_displayURL = [user.displayURL copy];
		_profileBackgroundColor = [user.profileBackgroundColor copy];
		_profileLinkColor = [user.profileLinkColor copy];
		_creationDate = [user.creationDate copy];
		_timezone = [user.timezone copy];
		_timezoneOffset = user.timezoneOffset;
		_tweetCount = user.tweetCount;
		_followerCount = user.followerCount;
		_followingCount = user.followingCount;
		_favoriteCount = user.favoriteCount;
		_listedCount = user.listedCount;
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
		_avatar = [[NSURL alloc] initWithString:@"https://pbs.twimg.com/profile_images/378800000319811233/6a87e0a5b6a1cfe65b0da002c807d8ad_normal.jpeg"];
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
		_profileBackgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0.5f alpha:1];
	}
	
	return self;
}

- (instancetype)initStubWithUserID:(NSString *)userID screenName:(NSString *)screenName realName:(NSString *)realName {
	self = [super init];
	
	if (self) {
		_userID = [userID copy];
		_screenName = [screenName copy];
		_realName = [realName copy];
		_loadedFullProfile = NO;
	}
	
	return self;
}

#pragma mark - URLs

- (NSURL *)URLForAvatarSize:(HBAPAvatarSize)size {
	if (!_avatar) {
		return nil;
	}
	
	NSString *sizeString = @"_bigger";
	
	switch (size) {
		case HBAPAvatarSizeMini:
			sizeString = @"_mini";
			break;
			
		case HBAPAvatarSizeNavBar:
			sizeString = @"_normal";
			break;
			
		case HBAPAvatarSizeNormal:
			sizeString = @"_normal";
			break;
		
		case HBAPAvatarSizeBigger:
			sizeString = @"_bigger";
			break;
			
		case HBAPAvatarSizeReasonablySmall:
			sizeString = @"_reasonably_small";
			break;
		
		case HBAPAvatarSizeOriginal:
			sizeString = @"";
			break;
	}
	
	// "_normal".length = 7
	NSString *newPath = _avatar.path.stringByDeletingPathExtension;
	newPath = [newPath stringByReplacingCharactersInRange:NSMakeRange(newPath.length - 7, 7) withString:sizeString];
	
	NSURLComponents *components = [NSURLComponents componentsWithURL:_avatar resolvingAgainstBaseURL:YES];
	components.path = _avatar.pathExtension && ![_avatar.pathExtension isEqualToString:@""] ? [newPath stringByAppendingPathExtension:_avatar.pathExtension] : newPath;
	return components.URL;
}

- (NSURL *)URLForBannerSize:(HBAPBannerSize)size {
	if (!_banner) {
		return nil;
	}
	
	NSString *sizeString = @"";
	
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

#pragma mark - Attributed string stuff

- (void)resetAttributedString {
	[_bioAttributedString release];
	_bioAttributedString = nil;
}

- (void)createAttributedStringIfNeeded {
	if (!_bioAttributedString || !_bioDisplayText) {
		_bioAttributedString = [[HBAPTweetAttributedStringFactory attributedStringWithUser:self font:[self.class defaultAttributedStringFont]] retain];
	}
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
	[encoder encodeObject:_bioDisplayText forKey:@"bioDisplayText"];
	[encoder encodeObject:_bioEntities forKey:@"bioEntities"];
	[encoder encodeObject:_bioAttributedString forKey:@"bioAttributedString"];
	[encoder encodeObject:_location forKey:@"location"];
	[encoder encodeObject:_url forKey:@"url"];
	[encoder encodeObject:_displayURL forKey:@"displayURL"];
	[encoder encodeObject:_profileBackgroundColor forKey:@"profileBackgroundColor"];
	[encoder encodeObject:_profileLinkColor forKey:@"profileLinkColor"];
	[encoder encodeObject:_creationDate forKey:@"creationDate"];
	[encoder encodeObject:_timezone forKey:@"timezone"];
	[encoder encodeInteger:_timezoneOffset forKey:@"timezoneOffset"];
	[encoder encodeInteger:_tweetCount forKey:@"tweetCount"];
	[encoder encodeInteger:_followerCount forKey:@"followerCount"];
	[encoder encodeInteger:_followingCount forKey:@"followingCount"];
	[encoder encodeInteger:_favoriteCount forKey:@"favoriteCount"];
	[encoder encodeInteger:_listedCount forKey:@"listedCount"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
	self = [self init];
	
	if (self) {
		_realName = [[decoder decodeObjectOfClass:NSString.class forKey:@"realName"] copy];
		_screenName = [[decoder decodeObjectOfClass:NSString.class forKey:@"screenName"] copy];
		_userID = [[decoder decodeObjectOfClass:NSString.class forKey:@"userID"] copy];
		_protected = [decoder decodeBoolForKey:@"protected"];
		_verified = [decoder decodeBoolForKey:@"verified"];
		_avatar = [[decoder decodeObjectOfClass:NSURL.class forKey:@"avatar"] copy];
		_banner = [[decoder decodeObjectOfClass:NSURL.class forKey:@"banner"] copy];
		_loadedFullProfile = [decoder decodeBoolForKey:@"loadedFullProfile"];
		_bio = [[decoder decodeObjectOfClass:NSString.class forKey:@"bio"] copy];
		_bioEntities = [[decoder decodeObjectOfClass:NSArray.class forKey:@"bioEntities"] copy];
		_location = [[decoder decodeObjectOfClass:NSString.class forKey:@"location"] copy];
		_url = [[decoder decodeObjectOfClass:NSURL.class forKey:@"url"] copy];
		_displayURL = [[decoder decodeObjectOfClass:NSString.class forKey:@"displayURL"] copy];
		_profileBackgroundColor = [[decoder decodeObjectOfClass:UIColor.class forKey:@"profileBackgroundColor"] copy];
		_profileLinkColor = [[decoder decodeObjectOfClass:UIColor.class forKey:@"profileLinkColor"] copy];
		_creationDate = [[decoder decodeObjectOfClass:NSDate.class forKey:@"creationDate"] copy];
		_timezone = [[decoder decodeObjectOfClass:NSString.class forKey:@"timezone"] copy];
		_timezoneOffset = [decoder decodeIntegerForKey:@"timezoneOffset"];
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
	[_banner release];
	[_bio release];
	[_bioEntities release];
	[_location release];
	[_url release];
	[_displayURL release];
	[_profileBackgroundColor release];
	[_profileLinkColor release];
	[_creationDate release];
	[_timezone release];
	
	[super dealloc];
}

@end
