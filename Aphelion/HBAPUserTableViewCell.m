//
//  HBAPUserTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPUserTableViewCell.h"
#import "HBAPAvatarView.h"
#import "HBAPUser.h"
#import "HBAPThemeManager.h"
#import "HBAPFontManager.h"

@interface HBAPUserTableViewCell () {
	HBAPUser *_user;
	
	HBAPAvatarView *_avatarView;
	UILabel *_realNameLabel;
	UILabel *_screenNameLabel;
}

@end

@implementation HBAPUserTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];

	if (self) {
		_avatarView = [[HBAPAvatarView alloc] initWithSize:HBAPAvatarSizeNormal];
		_avatarView.frame = CGRectMake(15.f, 15.f, 32.f, 32.f);
		[self.contentView addSubview:_avatarView];
		
		_realNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarView.frame.origin.x + _avatarView.frame.size.width + 10.f, 0, 0, 0)];
		_realNameLabel.text = @" ";
		_realNameLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		_realNameLabel.font = [HBAPFontManager sharedInstance].headingFont;
		_realNameLabel.textColor = [HBAPThemeManager sharedInstance].textColor;
		[_realNameLabel sizeToFit];
		_realNameLabel.center = CGPointMake(_realNameLabel.center.x, self.contentView.frame.size.height / 2);
		[self.contentView addSubview:_realNameLabel];
		
		_screenNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, _realNameLabel.frame.size.height)];
		_screenNameLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		_screenNameLabel.font = [HBAPFontManager sharedInstance].subheadingFont;
		_screenNameLabel.textColor = [HBAPThemeManager sharedInstance].dimTextColor;
		_screenNameLabel.center = CGPointMake(_screenNameLabel.center.x, self.contentView.frame.size.height / 2);
		[self.contentView addSubview:_screenNameLabel];
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
	
	if (!_user.realName || !_user.screenName) {
		[HBAPUser userWithUserID:_user.userID callback:^(HBAPUser *user) {
			self.user = user;
		}];
		
		return;
	}
	
	_avatarView.user = user;
	_realNameLabel.text = _user.realName;
	_screenNameLabel.text = _user.screenName ? [@"@" stringByAppendingString:_user.screenName] : nil;
	
	[_realNameLabel sizeToFit];
	[self setNeedsLayout];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect screenNameFrame = _screenNameLabel.frame;
	screenNameFrame.origin.x = _realNameLabel.frame.origin.x + _realNameLabel.frame.size.width + 5.f;
	screenNameFrame.size.width = self.contentView.frame.size.width - _realNameLabel.frame.origin.x - _realNameLabel.frame.size.width - 5.f;
	_screenNameLabel.frame = screenNameFrame;
}

#pragma mark - Memory management

- (void)dealloc {
	[_user release];
	[_avatarView release];
	[_realNameLabel release];
	[_screenNameLabel release];
	
	[super dealloc];
}

@end
