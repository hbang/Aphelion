//
//  HBAPUser.h
//  Aphelion
//
//  Created by Adam D on 27/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBAPUser : NSObject {
	NSString *_realName;
	NSString *_username;
	NSString *_userId;
	
	BOOL _protected;
	BOOL _verified;
	
	NSURL *_avatar;
	NSData *_cachedAvatar;
	
	BOOL _loadedFullProfile;
	
	NSString *_bio;
	NSString *_location;
	BOOL _followingMe;
	BOOL _following;
}

- (id)initWithJSON:(NSDictionary *)json;

@end
