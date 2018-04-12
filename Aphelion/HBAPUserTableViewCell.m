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

@interface HBAPUserTableViewCell () {
	HBAPUser *_user;
	
	HBAPAvatarView *_avatarView;
	UILabel *_realNameLabel;
	UILabel *_screenNameLabel;
}

@end

@implementation HBAPUserTableViewCell

#pragma mark - Constants

+ (UIFont *)realNameLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

+ (UIFont *)screenNameLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

#pragma mark - Implementation

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];

	if (self) {
		_avatarView = [[HBAPAvatarView alloc] initWithSize:HBAPAvatarSizeNormal];
		_avatarView.frame = CGRectMake(15.f, 15.f, 32.f, 32.f);
		[self.contentView addSubview:_avatarView];
		
		_realNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarView.frame.origin.x + _avatarView.frame.size.width + 15.f, 0, 0, 0)];
		_realNameLabel.font = [self.class realNameLabelFont];
		_realNameLabel.textColor = [HBAPThemeManager sharedInstance].textColor;
		[self.contentView addSubview:_realNameLabel];
		
		_screenNameLabel = [[UILabel alloc] init];
		_screenNameLabel.font = [self.class screenNameLabelFont];
		_screenNameLabel.textColor = [HBAPThemeManager sharedInstance].dimTextColor;
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
	
	_screenNameLabel.frame = CGRectMake(_realNameLabel.frame.origin.x + _realNameLabel.frame.size.width + 3.f, 0, self.contentView.frame.size.width - _realNameLabel.frame.origin.x - _realNameLabel.frame.size.width - 3.f - 45.f, _realNameLabel.frame.size.height);
	_realNameLabel.center = CGPointMake(_realNameLabel.center.x, self.contentView.frame.size.height / 2);
	_screenNameLabel.center = CGPointMake(_screenNameLabel.center.x, self.contentView.frame.size.height / 2);
}

@end
