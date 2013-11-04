//
//  HBAPBackgroundView.m
//  Aphelion
//
//  Created by Adam D on 1/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPBackgroundView.h"
#import "HBAPThemeManager.h"

@interface HBAPBackgroundView () {
	UIImageView *_imageView;
}

@end

@implementation HBAPBackgroundView

#pragma mark - Constants

+ (UIImage *)defaultBackgroundImage {
	return [UIImage imageNamed:@"background"];
}

#pragma mark - Implementation

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self.backgroundColor = [HBAPThemeManager sharedInstance].backgroundColor;
		
		_imageView = [[UIImageView alloc] initWithImage:[self.class defaultBackgroundImage]];
		_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_imageView.alpha = 0.7f;
		[self addSubview:_imageView];
	}

	return self;
}

@end
