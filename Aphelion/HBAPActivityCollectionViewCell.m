//
//  HBAPActivityCollectionViewCell.m
//  Aphelion
//
//  Created by Adam D on 15/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPActivityCollectionViewCell.h"
#import "HBAPActivity.h"
#import "HBAPThemeManager.h"
#import "HBAPFontManager.h"

@interface HBAPActivityCollectionViewCell () {
	HBAPActivity *_activity;
	
	UIButton *_button;
	UIImageView *_imageView;
	UILabel *_label;
}

@end

@implementation HBAPActivityCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self.tintColor = [HBAPThemeManager sharedInstance].dimTextColor;
		
		_button = [UIButton buttonWithType:UIButtonTypeCustom];
		_button.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.width);
		[self.contentView addSubview:_button];
		
		UIImageView *borderImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(8.f, 8.f, 60.f, 60.f)] autorelease];
		borderImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		borderImageView.image = [[UIImage imageNamed:@"activity_border"] resizableImageWithCapInsets:UIEdgeInsetsMake(14.f, 14.f, 14.f, 14.f)];
		[_button addSubview:borderImageView];
		
		_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, borderImageView.frame.size.width, borderImageView.frame.size.height)];
		_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_imageView.contentMode = UIViewContentModeCenter;
		[borderImageView addSubview:_imageView];
		
		_label = [[UILabel alloc] initWithFrame:CGRectMake(0, borderImageView.frame.origin.y + borderImageView.frame.size.height + 6.f, 0, 0)];
		_label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		_label.font = [UIFont fontWithName:[HBAPFontManager sharedInstance].footerFont.familyName size:11.f];
		_label.textColor = [HBAPThemeManager sharedInstance].textColor;
		_label.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_label];
	}

	return self;
}

- (HBAPActivity *)activity {
	return _activity;
}

- (void)setActivity:(HBAPActivity *)activity {
	if (_activity == activity) {
		return;
	}
	
	_activity = activity;
	
	_imageView.image = _activity.icon;
	_label.text = _activity.title;
	
	CGRect labelFrame = _label.frame;
	labelFrame.size.width = self.contentView.frame.size.width;
	labelFrame.size.height = self.contentView.frame.size.height - labelFrame.origin.y;
	_label.frame = labelFrame;
	
	[_label sizeToFit];
	_label.center = CGPointMake(self.contentView.frame.size.width / 2, _label.center.y);
}

@end
