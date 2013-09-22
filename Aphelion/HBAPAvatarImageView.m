//
//  HBAPAvatarImageView.m
//  Aphelion
//
//  Created by Adam D on 30/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAvatarImageView.h"
#import "HBAPUser.h"
#import "AFNetworking/UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@implementation HBAPAvatarImageView

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
	_user = user;
	
	[self setImageWithURLRequest:[NSURLRequest requestWithURL:_user.avatar] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		NSLog(@"avatar loaded");
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		NSLog(@"failed to load avatar - %@", error);
		
		UIImageView *errorImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_failed"]] autorelease];
		errorImageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
		[self addSubview:errorImageView];
	}];
}

#pragma mark - Memory management

- (void)dealloc {
	[_url release];
	[_screenName release];
	
	[super dealloc];
}

@end
