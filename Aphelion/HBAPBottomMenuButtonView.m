//
//  HBAPBottomMenuButtonView.m
//  Aphelion
//
//  Created by Adam D on 11/05/2014.
//  Copyright (c) 2014 HASHBANG Productions. All rights reserved.
//

#import "HBAPBottomMenuButtonView.h"
#import "HBAPThemeManager.h"
#import <FXBlurView/FXBlurView.h>

@interface HBAPBottomMenuButtonView () {
	UIImageView *_imageView;
	FXBlurView *_blurView;
	BOOL _selected;
}

@end

@implementation HBAPBottomMenuButtonView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.layer.masksToBounds = YES;
		self.layer.borderWidth = 1.5f;
		
		_selected = NO;
		
		_blurView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		_blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_blurView.userInteractionEnabled = NO;
		[self addSubview:_blurView];
		
		_imageView = [[UIImageView alloc] initWithFrame:_blurView.frame];
		_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_imageView.contentMode = UIViewContentModeCenter;
		[self addSubview:_imageView];
		
		[self setupTheme];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTheme) name:HBAPThemeChanged object:nil];
	}
	
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	self.layer.cornerRadius = self.frame.size.width / 2;
}

- (UIImage *)image {
	return _imageView.image;
}

- (void)setImage:(UIImage *)image {
	_imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (UIView *)underlyingView {
	return _blurView.underlyingView;
}

- (void)setUnderlyingView:(UIView *)underlyingView {
	_blurView.underlyingView = underlyingView;
}

- (BOOL)selected {
	return _selected;
}

- (void)setSelected:(BOOL)selected {
	_selected = selected;
	// self.tintColor = selected ? [HBAPThemeManager sharedInstance].tintColor : [HBAPThemeManager sharedInstance].dimTextColor; // TODO: this
}

- (void)setupTheme {
	self.tintColor = [HBAPThemeManager sharedInstance].tintColor;
	self.layer.borderColor = [HBAPThemeManager sharedInstance].dimTextColor.CGColor;
	_blurView.tintColor = [HBAPThemeManager sharedInstance].backgroundColor;
}

@end
