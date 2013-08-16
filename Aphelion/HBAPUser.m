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

- (id)initWithDictionary:(NSDictionary *)user {
	// TODO: this
	return nil;
}

@end
