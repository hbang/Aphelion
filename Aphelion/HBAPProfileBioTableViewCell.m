//
//  HBAPProfileBioTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 10/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPProfileBioTableViewCell.h"
#import "HBAPUser.h"
#import "HBAPTweetTableViewCell.h"
#import "HBAPTweetAttributedStringFactory.h"
#import "HBAPThemeManager.h"

@interface HBAPProfileBioTableViewCell () {
	HBAPUser *_user;
	UITextView *_textView;
	NSAttributedString *_attributedString;
}

@end

@implementation HBAPProfileBioTableViewCell

+ (CGFloat)heightForUser:(HBAPUser *)user tableView:(UITableView *)tableView {
	CGFloat height = 0.f;
	
	if (!user.bio || [user.bio isEqualToString:@""]) {
		return height;
	}
	
	[user createAttributedStringIfNeeded];
	height = ceilf([user.bioAttributedString boundingRectWithSize:CGSizeMake(tableView.frame.size.width - 30.f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height) + 31.f;
	
	return height == 60.f ? 0 : height;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];

	if (self) {
		self.backgroundColor = [[HBAPThemeManager sharedInstance].backgroundColor colorWithAlphaComponent:0.3f];
		
		_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
		_textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_textView.backgroundColor = nil;
		_textView.textContainerInset = UIEdgeInsetsMake(15.f, 15.f, 15.f, 15.f);
		_textView.textContainer.lineFragmentPadding = 0;
		_textView.dataDetectorTypes = UIDataDetectorTypeAddress | UIDataDetectorTypeCalendarEvent | UIDataDetectorTypePhoneNumber;
		_textView.linkTextAttributes = @{};
		_textView.scrollEnabled = NO;
		_textView.editable = NO;
		[self.contentView addSubview:_textView];
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
	
	[_user createAttributedStringIfNeeded];
	_textView.attributedText = _user.bioAttributedString;
}

@end
