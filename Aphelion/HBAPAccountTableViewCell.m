//
//  HBAPAccountTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAccountTableViewCell.h"
#import "HBAPAvatarView.h"
#import "HBAPUser.h"

@interface HBAPAccountTableViewCell () {
	HBAPUser *_user;
	
	HBAPAvatarView *_avatarView;
	UILabel *_realNameLabel;
	UILabel *_screenNameLabel;
}

@end

@implementation HBAPAccountTableViewCell

#pragma mark - Constants

+ (UIFont *)realNameLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

+ (UIFont *)screenNameLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

+ (UIColor *)screenNameLabelColor {
	return [UIColor colorWithWhite:0.6666666667f alpha:1];
}

#pragma mark - Implementation

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];

	if (self) {
		CGRect avatarFrame = [HBAPAvatarView frameForSize:HBAPAvatarSizeSmall];
		avatarFrame.origin = CGPointMake(15.f, 15.f);
		
		_avatarView = [[HBAPAvatarView alloc] initWithFrame:avatarFrame];
		_avatarView.layer.cornerRadius = avatarFrame.size.width / 2;
		[self.contentView addSubview:_avatarView];
		
		_realNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(avatarFrame.origin.x + avatarFrame.size.height, 15.f, 0, self.contentView.frame.size.height - 30.f)];
		_realNameLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_realNameLabel.font = [self.class realNameLabelFont];
		[self.contentView addSubview:_realNameLabel];
		
		_screenNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15.f, 0, self.contentView.frame.size.height - 30.f)];
		_screenNameLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_screenNameLabel.font = [self.class screenNameLabelFont];
		_screenNameLabel.textColor = [self.class screenNameLabelColor];
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
		[HBAPUser userWithUserID:_user.userID callback:^(HBAPUser *user) {
			self.user = user;
		}];
		
		return;
	}
	
	_avatarView.user = user;
	_realNameLabel.text = _user.realName;
	_screenNameLabel.text = _user.screenName ? [@"@" stringByAppendingString:_user.screenName] : nil;
	
	CGRect realNameFrame = _realNameLabel.frame;
	realNameFrame.size.width = [_realNameLabel.text sizeWithAttributes:@{ NSFontAttributeName: _realNameLabel.font }].width;
	_realNameLabel.frame = realNameFrame;
	
	CGRect screenNameFrame = _screenNameLabel.frame;
	screenNameFrame.origin.x = realNameFrame.origin.x + realNameFrame.size.width + 3.f;
	screenNameFrame.size.width = [_screenNameLabel.text sizeWithAttributes:@{ NSFontAttributeName: _screenNameLabel.font }].width;
	_screenNameLabel.frame = screenNameFrame;
}

@end
