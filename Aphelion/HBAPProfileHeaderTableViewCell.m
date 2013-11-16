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
#import "HBAPDominantColor.h"
#import "HBAPFontManager.h"
#import <UIKit+AFNetworking/UIImageView+AFNetworking.h>
#import <FXBlurView/FXBlurView.h>

@interface HBAPProfileHeaderTableViewCell () {
	HBAPUser *_user;
	
	HBAPAvatarView *_avatarView;
	UIView *_labelContainerView;
	UILabel *_realNameLabel;
	UILabel *_screenNameLabel;
	UIImageView *_bannerImageView;
	
	UIColor *_dominantColor;
}

@end

@implementation HBAPProfileHeaderTableViewCell

#pragma mark - Constants

+ (UIColor *)realNameLabelColorDark {
	return [UIColor whiteColor];
}

+ (UIColor *)realNameLabelColorLight {
	return [UIColor blackColor];
}

+ (UIColor *)screenNameLabelColorDark {
	return [UIColor colorWithWhite:0.85f alpha:1];
}

+ (UIColor *)screenNameLabelColorLight {
	return [UIColor colorWithWhite:0.25f alpha:1];
}

+ (CGFloat)cellHeight {
	return 15.f + 73.f + 15.f + [@" " sizeWithAttributes:@{ NSFontAttributeName: [HBAPFontManager sharedInstance].headingFont }].height + 15.f;
}

#pragma mark - Implementation

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	
	if (self) {
		self.backgroundColor = [[HBAPThemeManager sharedInstance].backgroundColor colorWithAlphaComponent:0.5f];
		
		_bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
		_bannerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_bannerImageView.alpha = 0;
		[self.contentView addSubview:_bannerImageView];
		
		FXBlurView *blurView = [[[FXBlurView alloc] initWithFrame:_bannerImageView.frame] autorelease];
		blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		blurView.dynamic = NO;
		blurView.tintColor = [UIColor colorWithWhite:0.3f alpha:1];
		blurView.alpha = 0.8f;
		[_bannerImageView addSubview:blurView];
		
		_avatarView = [[HBAPAvatarView alloc] initWithSize:HBAPAvatarSizeBigger];
		_avatarView.frame = CGRectMake(0, 15.f, 73.f, 73.f);
		_avatarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		_avatarView.center = CGPointMake(self.contentView.frame.size.width / 2, _avatarView.center.y);
		[self.contentView addSubview:_avatarView];
		
		_labelContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, _avatarView.frame.origin.y + _avatarView.frame.size.height + _avatarView.frame.origin.y, 0, 0)];
		_labelContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[self.contentView addSubview:_labelContainerView];
		
		_realNameLabel = [[UILabel alloc] init];
		_realNameLabel.font = [HBAPFontManager sharedInstance].headingFont;
		_realNameLabel.textColor = [self.class realNameLabelColorDark];
		[_labelContainerView addSubview:_realNameLabel];
		
		_screenNameLabel = [[UILabel alloc] init];
		_screenNameLabel.font = [HBAPFontManager sharedInstance].subheadingFont;
		_screenNameLabel.textColor = [self.class screenNameLabelColorDark];
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
			[self _setLabelColors];
		}];
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		HBLogWarn(@"failed to load banner: %@", error);
	}];
}

#pragma mark - Dominiant color

- (void)_setLabelColors {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		BOOL isDark = [HBAPDominantColor isDarkColor:[HBAPDominantColor dominantColorForImage:_bannerImageView.image]];
		
		_realNameLabel.textColor = isDark ? [self.class realNameLabelColorDark] : [self.class realNameLabelColorLight];
		_screenNameLabel.textColor = isDark ? [self.class screenNameLabelColorDark] : [self.class screenNameLabelColorLight];
	});
}

@end
