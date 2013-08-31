//
//  HBAPUser.m
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPUser.h"

@implementation HBAPUser
@synthesize realName = _realName, screenName = _screenName, userId = _userId, protected = _protected, verified = _verified, avatar = _avatar, cachedAvatar = _cachedAvatar, loadedFullProfile = _loadedFullProfile, bio = _bio, location = _location, followingMe = _followingMe, following = _following;

- (instancetype)initWithDictionary:(NSDictionary *)user {
	self = [super init];
	
	if (self) {
		_realName = [user objectForKey:@"name"];
		_screenName = [user objectForKey:@"screen_name"];
		
		_userId = [user objectForKey:@"id_str"];
		
		_protected = ((NSNumber *)[user objectForKey:@"protected"]).boolValue;
		_verified = ((NSNumber *)[user objectForKey:@"verified"]).boolValue;
		
		_avatar = [NSURL URLWithString:[user objectForKey:@"profile_image_url_https"]];
		
		_loadedFullProfile = NO;
	}
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; id = %@; screenName = %@; realName = %@>", NSStringFromClass(self.class), self, _userId, _screenName, _realName];
}

#pragma mark - Memory management

- (void)dealloc {
	[_realName release];
	[_screenName release];
	[_userId release];
	
	[_avatar release];
	[_cachedAvatar release];
	
	[_bio release];
	[_location release];
	
	[super dealloc];
}

@end
