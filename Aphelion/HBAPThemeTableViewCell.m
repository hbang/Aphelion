//
//  HBAPThemeTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 24/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPThemeTableViewCell.h"

@interface HBAPThemeTableViewCell () {
	UIColor *_themeColor;
	UIView *_themeColorView;
}

@end

@implementation HBAPThemeTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];
	
	if (self) {
		_themeColorView = [[UIView alloc] initWithFrame:CGRectMake(15.f, 8.f, self.contentView.frame.size.height - 16.f, self.contentView.frame.size.height - 16.f)];
		_themeColorView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_themeColorView.layer.cornerRadius = 6.f;
		_themeColorView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.5f].CGColor;
		_themeColorView.layer.borderWidth = 1.f;
		[self.contentView addSubview:_themeColorView];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect labelFrame = self.textLabel.frame;
	labelFrame.origin.x = _themeColorView.frame.origin.x + _themeColorView.frame.size.width + 15.f;
	self.textLabel.frame = labelFrame;
}

- (UIColor *)themeColor {
	return _themeColor;
}

- (void)setThemeColor:(UIColor *)themeColor {
	if (_themeColor == themeColor) {
		return;
	}
	
	_themeColor = themeColor;
	_themeColorView.backgroundColor = themeColor;
}

#pragma mark - Memory management

- (void)dealloc {
	// [_themeColor release];
	[_themeColorView release];
	
	[super dealloc];
}

@end
