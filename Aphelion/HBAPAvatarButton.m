//
//  HBAPAvatarButton.m
//  Aphelion
//
//  Created by Adam D on 30/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAvatarButton.h"
#import "HBAPAvatarView.h"
#import "HBAPProfileViewController.h"

@interface HBAPAvatarButton () {
	HBAPAvatarView *_avatarView;
}

@end

@implementation HBAPAvatarButton

- (instancetype)_initWithSize:(HBAPAvatarSize)size {
	CGSize frameSize = [HBAPAvatarView sizeForSize:size];
	self = [self initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height)];
	return self;
}

- (instancetype)initWithSize:(HBAPAvatarSize)size {
	self = [self _initWithSize:size];
	
	if (self) {
		_avatarView = [[HBAPAvatarView alloc] initWithSize:size];
		[self addSubview:_avatarView];
	}
	
	return self;
}

- (instancetype)initWithUser:(HBAPUser *)user size:(HBAPAvatarSize)size {
	self = [self _initWithSize:size];
	
	if (self) {
		_avatarView = [[HBAPAvatarView alloc] initWithUser:user size:size];
		[self addSubview:_avatarView];
	}
	
	return self;
}

- (instancetype)initWithUserID:(NSString *)userID size:(HBAPAvatarSize)size {
	self = [self _initWithSize:size];
	
	if (self) {
		_avatarView = [[HBAPAvatarView alloc] initWithUserID:userID size:size];
		[self addSubview:_avatarView];
	}
	
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.clipsToBounds = YES;
		
		[self addTarget:self action:@selector(_avatarTapped) forControlEvents:UIControlEventTouchUpInside];
		[self addGestureRecognizer:[[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTouched:)] autorelease]];
	}
	
	return self;
}

- (HBAPUser *)user {
	return _avatarView.user;
}

- (void)setUser:(HBAPUser *)user {
	_avatarView.user = user;
}

- (NSString *)userID {
	return _avatarView.userID;
}

- (void)setUserID:(NSString *)userID {
	_avatarView.userID = userID;
}

#pragma mark - Gestures

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	
	[UIView animateWithDuration:0.2 animations:^{
		self.alpha = 0.65f;
	}];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	
	self.alpha = 1;
}

- (void)avatarTouched:(UITapGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
		[UIView animateWithDuration:0.2 animations:^{
			self.alpha = 1;
		}];
	}
}

- (void)_avatarTapped {
	[UIView animateWithDuration:0.2 animations:^{
		self.alpha = 1;
	}];
	
	[self avatarTapped];
}

- (void)avatarTapped {
	if (!_navigationController) {
		HBLogWarn(@"avatarTapped: navigation controller not set!");
	}
	
	HBAPProfileViewController *profileViewController = [[[HBAPProfileViewController alloc] initWithUser:_avatarView.user] autorelease];
	[_navigationController pushViewController:profileViewController animated:YES];
	
	self.alpha = 1;
}

#pragma mark - Memory management

- (void)dealloc {
	[_navigationController release];
	[_avatarView release];
	
	[super dealloc];
}

@end
