//
//  HBAPProfileHeaderTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 9/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPProfileHeaderTableViewCell.h"
#import "HBAPUser.h"
#import "HBAPAvatarView.h"
#import "HBAPThemeManager.h"
#import <UIKit+AFNetworking/UIImageView+AFNetworking.h>

@interface HBAPProfileHeaderTableViewCell () {
	HBAPUser *_user;
	
	HBAPAvatarView *_avatarView;
	UIView *_labelContainerView;
	UILabel *_realNameLabel;
	UILabel *_screenNameLabel;
	UIImageView *_bannerImageView;
}

@end

@implementation HBAPProfileHeaderTableViewCell

#pragma mark - Constants

+ (UIFont *)realNameLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

+ (UIColor *)realNameLabelColor {
	return [UIColor blackColor];
}

+ (UIFont *)screenNameLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

+ (UIColor *)screenNameLabelColor {
	return [UIColor colorWithWhite:0.25f alpha:1];
}

+ (CGFloat)cellHeight {
	return 15.f + 73.f + 15.f + [@" " sizeWithAttributes:@{ NSFontAttributeName: [self.class realNameLabelFont] }].height + 15.f;
}

#pragma mark - Implementation

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	
	if (self) {
		_bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
		_bannerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_bannerImageView.alpha = 0;
		[self.contentView addSubview:_bannerImageView];
		
		UIToolbar *overlayToolbar = [[[UIToolbar alloc] initWithFrame:_bannerImageView.frame] autorelease];
		overlayToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		overlayToolbar.barTintColor = [UIColor colorWithWhite:0.3f alpha:1];
		overlayToolbar.alpha = 0.7f;
		[self.contentView addSubview:overlayToolbar];
		
		_avatarView = [[HBAPAvatarView alloc] initWithSize:HBAPAvatarSizeBigger];
		_avatarView.frame = CGRectMake(0, 15.f, 73.f, 73.f);
		_avatarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		_avatarView.center = CGPointMake(self.contentView.frame.size.width / 2, _avatarView.center.y);
		[self.contentView addSubview:_avatarView];
		
		_labelContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, _avatarView.frame.origin.y + _avatarView.frame.size.height + _avatarView.frame.origin.y, 0, 0)];
		_labelContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[self.contentView addSubview:_labelContainerView];
		
		_realNameLabel = [[UILabel alloc] init];
		_realNameLabel.font = [self.class realNameLabelFont];
		_realNameLabel.textColor = [self.class realNameLabelColor];
		[_labelContainerView addSubview:_realNameLabel];
		
		_screenNameLabel = [[UILabel alloc] init];
		_screenNameLabel.font = [self.class screenNameLabelFont];
		_screenNameLabel.textColor = [self.class screenNameLabelColor];
		[_labelContainerView addSubview:_screenNameLabel];
	}
	
	return self;
}

- (HBAPUser *)user {
	return _user;
}

- (void)setUser:(HBAPUser *)user {
	if (_user == user) {
		return;
	}
	
	_user = user;
	
	if (!_user) {
		HBLogWarn(@"setUser: nil user");
		return;
	}
	
	_avatarView.user = user;
	_realNameLabel.text = _user.realName;
	_screenNameLabel.text = _user.screenName ? [@"@" stringByAppendingString:_user.screenName] : nil;
	
	[_realNameLabel sizeToFit];
	[_screenNameLabel sizeToFit];
	
	CGRect screenNameFrame = _screenNameLabel.frame;
	screenNameFrame.origin.x = _realNameLabel.frame.size.width + 3.f;
	screenNameFrame.size.height = _realNameLabel.frame.size.height;
	_screenNameLabel.frame = screenNameFrame;
	
	CGRect containerFrame = _labelContainerView.frame;
	containerFrame.size.width = _screenNameLabel.frame.origin.x + _screenNameLabel.frame.size.width;
	containerFrame.size.height = _realNameLabel.frame.size.height;
	_labelContainerView.frame = containerFrame;
	
	_labelContainerView.center = CGPointMake(self.contentView.frame.size.width / 2, _labelContainerView.center.y);
	
	[_bannerImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[_user URLForBannerSize:HBAPBannerSizeMobile2x]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_bannerImageView.image = image;
		
		[UIView animateWithDuration:0.2f animations:^{
			_bannerImageView.alpha = 1;
		}];
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		// nothing
		HBLogWarn(@"failed to load banner: %@", error);
	}];
}

@end
