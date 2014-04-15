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
#import "HBAPImageCache.h"

@interface HBAPAvatarView () {
	HBAPUser *_user;
	NSString *_userID;
	HBAPAvatarSize _size;
	
	UIImageView *_avatarImageView;
}

@end

@implementation HBAPAvatarView

#pragma mark - Constants

+ (CGSize)sizeForSize:(HBAPAvatarSize)size {
	switch (size) {
		case HBAPAvatarSizeMini:
			return CGSizeMake(24.f, 24.f);
			break;
			
		case HBAPAvatarSizeNavBar:
			return CGSizeMake(28.f, 28.f);
			break;
			
		case HBAPAvatarSizeNormal:
			return CGSizeMake(48.f, 48.f);
			break;
			
		case HBAPAvatarSizeBigger:
			return CGSizeMake(73.f, 73.f);
			break;
			
		case HBAPAvatarSizeReasonablySmall:
			return CGSizeMake(128.f, 128.f);
			break;
			
		case HBAPAvatarSizeOriginal:
			return CGSizeMake(500.f, 500.f);
			break;
	}
}

#pragma mark - Implementation

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
		self.userInteractionEnabled = NO;
		self.clipsToBounds = YES;
		
		_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		_avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_avatarImageView.alpha = 0;
		_avatarImageView.userInteractionEnabled = NO;
		[self addSubview:_avatarImageView];
	}
	
	return self;
}

- (instancetype)initWithSize:(HBAPAvatarSize)size {
	CGSize frameSize = [self.class sizeForSize:size];
	self = [self initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height)];
	
	if (self) {
		_size = size;
	}
	
	return self;
}

- (instancetype)initWithUser:(HBAPUser *)user size:(HBAPAvatarSize)size {
	self = [self initWithSize:size];
	
	if (self) {
		self.user = user;
	}
	
	return self;
}

- (instancetype)initWithUserID:(NSString *)userID size:(HBAPAvatarSize)size {
	self = [self initWithSize:size];
	
	if (self) {
		self.userID = userID;
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
	
	_user = user;
	
	if (!_user || !_user.avatar) {
		_avatarImageView.image = nil;
		_avatarImageView.alpha = 0;
		
		return;
	}
	
	UIImage *cachedImage = [[HBAPImageCache sharedInstance] avatarForUser:_user ofSize:_size];
	
	if (cachedImage) {
		_avatarImageView.image = cachedImage;
		_avatarImageView.alpha = 1;
	} else {
		_avatarImageView.image = nil;
		_avatarImageView.alpha = 0;
		
		[[HBAPImageCache sharedInstance] getAvatarForUser:_user size:_size completion:^(UIImage *image, NSError *error) {
			if (![_user.userID isEqualToString:user.userID]) {
				return;
			}
			
			if (error) {
				_avatarImageView.image = [UIImage imageNamed:@"avatar_failed_regular"];
				HBLogWarn(@"couldn't get avatar for %@: %@", _user, error);
			} else {
				_avatarImageView.image = image;
				
				[UIView animateWithDuration:0.15 animations:^{
					_avatarImageView.alpha = 1;
				}];
			}
		}];
	}
}

- (NSString *)userID {
	return _userID;
}

- (void)setUserID:(NSString *)userID {
	if ([_userID isEqualToString:userID]) {
		return;
	}
	
	_userID = userID;
	
	[HBAPUser userWithUserID:userID callback:^(HBAPUser *user) {
		self.user = user;
	}];
}

#pragma mark - Memory management

- (void)dealloc {
	[_userID release];
	[_avatarImageView release];
	
	[super dealloc];
}

@end
