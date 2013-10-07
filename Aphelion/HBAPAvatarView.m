//
//  HBAPAvatarView.m
//  Aphelion
//
//  Created by Adam D on 30/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAvatarView.h"
#import "HBAPUser.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "HBAPProfileViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface HBAPAvatarView () {
	NSURL *_url;
	NSString *_screenName;
	
	HBAPUser *_user;
}

@end

@implementation HBAPAvatarView

+ (CGRect)frameForSize:(HBAPAvatarSize)size {
	switch (size) {
		case HBAPAvatarSizeRegular:
			return CGRectMake(0, 9, 48.f, 48.f);
			break;
			
		case HBAPAvatarSizeBig:
			return CGRectMake(0, 0, 64.f, 64.f);
			break;
			
		case HBAPAvatarSizeOriginal:
			return CGRectMake(0, 0, 500.f, 500.f);
			break;
	}
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self addTarget:self action:@selector(avatarTapped) forControlEvents:UIControlEventTouchUpInside];
		[self addGestureRecognizer:[[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTouched:)] autorelease]];
		
		self.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
		
		_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		_avatarImageView.alpha = 0;
		_avatarImageView.userInteractionEnabled = NO;
		[self addSubview:_avatarImageView];
	}
	
	return self;
}

- (instancetype)initWithScreenName:(NSString *)screenName size:(HBAPAvatarSize)size {
	self = [self initWithFrame:[self.class frameForSize:size]];
	
	NOIMP
	
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
	
	_avatarImageView.image = nil;
	
	if (user.cachedAvatar) {
		_avatarImageView.image = user.cachedAvatar;
		_avatarImageView.alpha = 1;
	} else {
		_avatarImageView.alpha = 0;
		[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:_user.avatar] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			[self _setImage:image];
			user.cachedAvatar = image;
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
			[self _setImage:[UIImage imageNamed:@"avatar_failed_regular"]];
		}];
	}
}

- (void)_setImage:(UIImage *)image {
	_avatarImageView.image = image;
	
	[UIView animateWithDuration:0.15f animations:^{
		_avatarImageView.alpha = 1;
	}];
}

- (void)avatarTapped {
	if (!_navigationController) {
		NSLog(@"avatarTapped: navigation controller not set!");
	}
	
	HBAPProfileViewController *profileViewController = [[[HBAPProfileViewController alloc] init] autorelease];
	[_navigationController pushViewController:profileViewController animated:YES];
	
	self.alpha = 1;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	
	[UIView animateWithDuration:0.2f animations:^{
		self.alpha = 0.65f;
	}];
}

- (void)avatarTouched:(UITapGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
		[UIView animateWithDuration:0.2f animations:^{
			self.alpha = 1;
		}];
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[_url release];
	[_screenName release];
	
	[super dealloc];
}

@end
