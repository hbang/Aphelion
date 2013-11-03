//
//  HBAPBlurView.m
//  Aphelion
//
//  Created by Adam D on 3/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPBlurView.h"

@interface HBAPBlurView () {
	UIToolbar *_toolbar;
	UIView *_blurView;
	BOOL _isStatic;
}

@end

@implementation HBAPBlurView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self.isStatic = NO;
	}

	return self;
}

- (BOOL)isStatic {
	return _isStatic;
}

- (void)setIsStatic:(BOOL)isStatic {
	if (_isStatic == isStatic) {
		return;
	}
	
	_isStatic = isStatic;
	
	[_toolbar removeFromSuperview];
	[_toolbar release];
	_toolbar = nil;
	
	[_blurView removeFromSuperview];
	[_blurView release];
	_blurView = nil;
	
	_toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_toolbar.translucent = YES;
	_toolbar.barTintColor = self.tintColor;
	[self addSubview:_toolbar];
	
	if (_isStatic) {
		_blurView = [_toolbar resizableSnapshotViewFromRect:_toolbar.frame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
		[self addSubview:_blurView];
		
		[_toolbar removeFromSuperview];
		[_toolbar release];
		_toolbar = nil;
	}
}

- (void)setTintColor:(UIColor *)tintColor {
	[super setTintColor:tintColor];
	_toolbar.barTintColor = [tintColor colorWithAlphaComponent:0.9f];
}

@end
