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
#import "HBAPImageCache.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <FXBlurView/FXBlurView.h>

@interface HBAPProfileHeaderTableViewCell () {
	HBAPUser *_user;
	
	HBAPAvatarView *_avatarView;
	UILabel *_realNameLabel;
	UILabel *_screenNameLabel;
	UIImageView *_bannerImageView;
	FXBlurView *_blurView;
	UITextView *_bioTextView;
	
	UIColor *_dominantColor;
}

@end

@implementation HBAPProfileHeaderTableViewCell

+ (CGFloat)heightForUser:(HBAPUser *)user tableView:(UITableView *)tableView {
	static CGFloat CellSpacingWidth = 45.f;
	static CGFloat CellSpacingHeight = 38.f;
	
	CGFloat cellPaddingWidth = CellSpacingWidth + [HBAPAvatarView sizeForSize:HBAPAvatarSizeBigger].width;
	
	if (!user) {
		return [self.class defaultHeight];
	}
	
	[user createAttributedStringIfNeeded];
	
	CGFloat height = CellSpacingHeight + ceilf([@" " sizeWithAttributes:@{ NSFontAttributeName: [HBAPFontManager sharedInstance].headingFont }].height) + ceilf([user.bioAttributedString boundingRectWithSize:CGSizeMake(tableView.frame.size.width - cellPaddingWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height);
	
	return height < [self.class defaultHeight] ? [self.class defaultHeight] : height;
}

#pragma mark - Constants

+ (UIColor *)realNameLabelColorLight {
	return [UIColor whiteColor];
}

+ (UIColor *)realNameLabelColorDark {
	return [UIColor blackColor];
}

+ (UIColor *)screenNameLabelColorLight {
	return [UIColor colorWithWhite:0.9f alpha:1];
}

+ (UIColor *)screenNameLabelColorDark {
	return [UIColor colorWithWhite:0.1f alpha:1];
}

+ (CGFloat)defaultHeight {
	return 104.f;
}

#pragma mark - Implementation

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];
	
	if (self) {
		self.backgroundColor = [[HBAPThemeManager sharedInstance].backgroundColor colorWithAlphaComponent:0.5f];
		
		_bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
		_bannerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_bannerImageView.alpha = 0;
		_bannerImageView.contentMode = UIViewContentModeCenter;
		_bannerImageView.clipsToBounds = YES;
		[self.contentView addSubview:_bannerImageView];
		
		_blurView = [[[FXBlurView alloc] initWithFrame:_bannerImageView.frame] autorelease];
		_blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_blurView.dynamic = NO;
		_blurView.tintColor = [UIColor colorWithWhite:0.3f alpha:1];
		_blurView.alpha = 0.9f;
		[_bannerImageView addSubview:_blurView];
		
		_avatarView = [[HBAPAvatarView alloc] initWithSize:HBAPAvatarSizeBigger];
		_avatarView.frame = CGRectMake(15.f, 15.f, 73.f, 73.f);
		[self.contentView addSubview:_avatarView];
		
		_realNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarView.frame.origin.x + _avatarView.frame.size.width + 15.f, 15.f, 0, 0)];
		_realNameLabel.font = [HBAPFontManager sharedInstance].headingFont;
		_realNameLabel.textColor = [self.class realNameLabelColorLight];
		[self.contentView addSubview:_realNameLabel];
		
		_screenNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15.f, 0, 0)];
		_screenNameLabel.font = [HBAPFontManager sharedInstance].subheadingFont;
		_screenNameLabel.textColor = [self.class screenNameLabelColorLight];
		[self.contentView addSubview:_screenNameLabel];
		
		CGFloat bioY = _realNameLabel.frame.origin.y + [@" " sizeWithAttributes:@{ NSFontAttributeName: _realNameLabel.font }].height + 2.f;
		_bioTextView = [[UITextView alloc] initWithFrame:CGRectMake(_realNameLabel.frame.origin.x, bioY, self.contentView.frame.size.width - _realNameLabel.frame.origin.x - 15.f, 0)];
		_bioTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_bioTextView.backgroundColor = nil;
		_bioTextView.textContainerInset = UIEdgeInsetsZero;
		_bioTextView.textContainer.lineFragmentPadding = 0;
		_bioTextView.dataDetectorTypes = UIDataDetectorTypeAddress | UIDataDetectorTypeCalendarEvent | UIDataDetectorTypePhoneNumber;
		_bioTextView.linkTextAttributes = @{};
		_bioTextView.scrollEnabled = NO;
		_bioTextView.editable = NO;
		[self.contentView addSubview:_bioTextView];
		
		[_user createAttributedStringIfNeeded];
		_bioTextView.attributedText = _user.bioAttributedString;
	}
	
	return self;
}

- (BOOL)useThemeBackground {
	return NO;
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
	
	CGFloat maxWidth = self.contentView.frame.size.width - _realNameLabel.frame.size.width - 3.f - 15.f;
	
	CGRect screenNameFrame = _screenNameLabel.frame;
	screenNameFrame.origin.x = _realNameLabel.frame.origin.x + _realNameLabel.frame.size.width + 3.f;
	screenNameFrame.size.height = _realNameLabel.frame.size.height;
	
	if (screenNameFrame.size.width > maxWidth) {
		screenNameFrame.size.width = maxWidth;
	}
	
	_screenNameLabel.frame = screenNameFrame;
	
	[_user createAttributedStringIfNeeded];
	_bioTextView.attributedText = _user.bioAttributedString;
	
	UIImage *banner = [[HBAPImageCache sharedInstance] bannerForUser:_user ofSize:HBAPBannerSizeMobile2x];
	
	if (banner) {
		[self _setBannerImage:banner];
	} else {
		[[HBAPImageCache sharedInstance] getBannerForUser:_user size:HBAPBannerSizeMobile2x completion:^(UIImage *image, NSError *error) {
			if (error) {
				HBLogWarn(@"couldn't get banner for %@: %@", _user, error);
			} else {
				[self _setBannerImage:image];
			}
		}];
	}
}

- (void)_setBannerImage:(UIImage *)image {
	_bannerImageView.image = image;
	[_blurView setNeedsDisplay];
	
	_dominantColor = [[HBAPDominantColor dominantColorForImage:_bannerImageView.image] retain];
	
	if (_gotHeaderCallback) {
		_gotHeaderCallback();
	}
	
	BOOL isDark = [HBAPDominantColor isDarkColor:_dominantColor];
	CGFloat hue, saturation, brightness;
	[_dominantColor getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
	
	_blurView.backgroundColor = [UIColor colorWithHue:hue saturation:saturation + (isDark ? -0.2f : 0.2f) brightness:brightness alpha:1];
	_bioTextView.tintColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness + (isDark ? 0.2f : -0.2f) alpha:1];
	_realNameLabel.textColor = isDark ? [self.class realNameLabelColorDark] : [self.class realNameLabelColorLight];
	_screenNameLabel.textColor = isDark ? [self.class screenNameLabelColorDark] : [self.class screenNameLabelColorLight];
	
	[UIView animateWithDuration:0.2 animations:^{
		_bannerImageView.alpha = 1;
	}];
}

#pragma mark - Memory management

/*- (void)dealloc {
	[_avatarView release];
	[_realNameLabel release];
	[_screenNameLabel release];
	[_bannerImageView release];
	[_blurView release];
	//[_bioTextView release];
	[_dominantColor release];
	
	[super dealloc];
}*/

@end
