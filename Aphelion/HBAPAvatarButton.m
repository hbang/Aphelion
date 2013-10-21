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

- (instancetype)initWithUser:(HBAPUser *)user size:(HBAPAvatarSize)size {
	self = [self initWithFrame:[HBAPAvatarView frameForSize:size]];
	
	if (self) {
		_avatarView = [[HBAPAvatarView alloc] initWithUser:user size:size];
		[self addSubview:_avatarView];
	}
	
	return self;
}

- (instancetype)initWithUserID:(NSString *)userID size:(HBAPAvatarSize)size {
	self = [self initWithFrame:[HBAPAvatarView frameForSize:size]];
	
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
		
		[self addTarget:self action:@selector(avatarTapped) forControlEvents:UIControlEventTouchUpInside];
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

#pragma mark - Gestures

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

- (void)avatarTapped {
	if (!_navigationController) {
		HBLogWarn(@"avatarTapped: navigation controller not set!");
	}
	
	HBAPProfileViewController *profileViewController = [[[HBAPProfileViewController alloc] init] autorelease];
	[_navigationController pushViewController:profileViewController animated:YES];
	
	self.alpha = 1;
}

@end
