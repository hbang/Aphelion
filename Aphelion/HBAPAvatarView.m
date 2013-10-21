//
//  HBAPAvatarView.m
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAvatarView.h"
#import "HBAPUser.h"
#import "HBAPAccountController.h"
#import "HBAPAccount.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface HBAPAvatarView () {
	HBAPUser *_user;
	
	UIImageView *_avatarImageView;
}

@end

@implementation HBAPAvatarView

#pragma mark - Constants

+ (CGRect)frameForSize:(HBAPAvatarSize)size {
	switch (size) {
		case HBAPAvatarSizeSmall:
			return CGRectMake(0, 0, 32.f, 32.f);
			break;
			
		case HBAPAvatarSizeRegular:
			return CGRectMake(0, 0, 48.f, 48.f);
			break;
			
		case HBAPAvatarSizeBig:
			return CGRectMake(0, 0, 64.f, 64.f);
			break;
			
		case HBAPAvatarSizeOriginal:
			return CGRectMake(0, 0, 500.f, 500.f);
			break;
	}
}

#pragma mark - Implementation

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
		self.userInteractionEnabled = NO;
		
		_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		_avatarImageView.alpha = 0;
		_avatarImageView.userInteractionEnabled = NO;
		[self addSubview:_avatarImageView];
	}
	
	return self;
}

- (instancetype)initWithUser:(HBAPUser *)user size:(HBAPAvatarSize)size {
	self = [self initWithFrame:[self.class frameForSize:size]];
	
	if (self) {
		self.user = user;
		self.clipsToBounds = YES;
	}
	
	return self;
}

- (instancetype)initWithUserID:(NSString *)userID size:(HBAPAvatarSize)size {
	self = [self initWithFrame:[self.class frameForSize:size]];
	
	if (self) {
		[HBAPUser userWithUserID:userID callback:^(HBAPUser *user) {
			self.user = user;
		}];
	}
	
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	
	self.layer.cornerRadius = frame.size.width / 2;
}

- (HBAPUser *)user {
	return _user;
}

- (void)setUser:(HBAPUser *)user {
	if (user == _user) {
		return;
	}
	
	if (!user) {
		// assume it's the app user for now
		[[HBAPAccountController sharedInstance].accountForCurrentUser getUser:^(HBAPUser *user) {
			HBLogInfo(@"A USER %@", user);
			self.user = user;
		}];
	}
	
	_user = user;
	
	_avatarImageView.image = user.cachedAvatar ?: nil;
	_avatarImageView.alpha = user.cachedAvatar ? 1 : 0;
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:_user.avatar] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		if (image != user.cachedAvatar) {
			[self _setImage:image];
			user.cachedAvatar = image;
		}
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		[self _setImage:[UIImage imageNamed:@"avatar_failed_regular"]];
	}];
}

- (void)_setImage:(UIImage *)image {
	_avatarImageView.image = image;
	
	[UIView animateWithDuration:0.15f animations:^{
		_avatarImageView.alpha = 1;
	}];
}

@end
