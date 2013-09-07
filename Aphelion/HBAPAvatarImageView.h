//
//  HBAPAvatarImageView.h
//  Aphelion
//
//  Created by Adam D on 30/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

@class HBAPUser;

typedef enum {
	HBAPAvatarSizeSmall,
	HBAPAvatarSizeRegular,
	HBAPAvatarSizeOriginal,
} HBAPAvatarSize;

@interface HBAPAvatarImageView : UIImageView {
	HBAPUser *_user;
	NSURL *_url;
	NSString *_screenName;
}

- (instancetype)initWithScreenName:(NSString *)screenName size:(HBAPAvatarSize)size;
- (instancetype)initWithUser:(HBAPUser *)user size:(HBAPAvatarSize)size;

@property (nonatomic, retain) HBAPUser *user;

@end
