//
//  HBAPAvatarImageView.m
//  Aphelion
//
//  Created by Adam D on 30/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAvatarImageView.h"
#import "HBAPUser.h"
#import <QuartzCore/QuartzCore.h>

@implementation HBAPAvatarImageView

+ (CGRect)frameForSize:(HBAPAvatarSize)size {
	switch (size) {
		case HBAPAvatarSizeSmall:
			return CGRectMake(0, 9, 50.f, 50.f);
			break;
		
		case HBAPAvatarSizeRegular:
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
		self.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
	}
	
	return self;
}

- (instancetype)initWithScreenName:(NSString *)screenName size:(HBAPAvatarSize)size {
	self = [self initWithFrame:[self.class frameForSize:size]];
	
	NSLog(@"initWithScreenName:size: not implemented");
	
	return self;
}

- (instancetype)initWithUser:(HBAPUser *)user size:(HBAPAvatarSize)size {
	self = [self initWithFrame:[self.class frameForSize:size]];
	
	if (self) {
		self.user = user;
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
	user = _user;
	
	NSLog(@"setUser: not implemented");
}

#pragma mark - Memory management

- (void)dealloc {
	[_url release];
	[_screenName release];
	
	[super dealloc];
}

@end
