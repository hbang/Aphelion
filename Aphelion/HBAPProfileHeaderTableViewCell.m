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
#import "HBAPTweetTextView.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface HBAPProfileHeaderTableViewCell () {
	HBAPUser *_user;
	
	HBAPAvatarView *_avatarView;
	UILabel *_nameLabel;
	UIImageView *_bannerImageView;
	UIVisualEffectView *_blurView;
	HBAPTweetTextView *_bioTextView;
	
	UIColor *_dominantColor;
}

@end

@implementation HBAPProfileHeaderTableViewCell

+ (CGFloat)heightForUser:(HBAPUser *)user tableView:(UITableView *)tableView {
	static CGFloat CellSpacingWidth = 118.f;
	static CGFloat CellSpacingHeight = 10.f;
	
	[user createAttributedStringIfNeeded];
	CGFloat bioHeight = ceilf([user.bioAttributedString boundingRectWithSize:CGSizeMake(tableView.frame.size.width - CellSpacingWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height) + CellSpacingHeight;
	CGFloat bioMinimum = [self.class defaultHeight] - [self.class bannerHeight];
	
	return [self.class bannerHeight] + (bioHeight < bioMinimum ? bioMinimum : bioHeight);
}

#pragma mark - Constants

+ (UIColor *)foregroundColorLight {
	return [UIColor whiteColor];
}

+ (UIColor *)foregroundColorDark {
	return [UIColor blackColor];
}

+ (UIColor *)screenNameLabelColorLight {
	return [UIColor colorWithWhite:0.9f alpha:1];
}

+ (UIColor *)screenNameLabelColorDark {
	return [UIColor colorWithWhite:0.1f alpha:1];
}

+ (CGFloat)defaultHeight {
	return 195.f;
}

+ (CGFloat)bannerHeight {
	return 160.f;
}

#pragma mark - Implementation

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];
	
	if (self) {
		self.backgroundColor = [[HBAPThemeManager sharedInstance].backgroundColor colorWithAlphaComponent:0.5f];
		
		_bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, [self.class bannerHeight])];
		_bannerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_bannerImageView.alpha = 0;
		_bannerImageView.contentMode = UIViewContentModeCenter;
		_bannerImageView.clipsToBounds = YES;
		[self.contentView addSubview:_bannerImageView];
		
		_blurView = [[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:[HBAPThemeManager sharedInstance].blurEffectStyle]] autorelease];
		_blurView.frame = _bannerImageView.frame;
		_blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_blurView.maskView = [[[UIView alloc] initWithFrame:_blurView.frame] autorelease];
		_blurView.maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_blurView.maskView.backgroundColor = [UIColor whiteColor];
		[_bannerImageView addSubview:_blurView];
		
		CAGradientLayer *gradientMask = [CAGradientLayer layer];
		gradientMask.locations = @[ @0, @0.5f, @1 ];
		gradientMask.colors = @[ (id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, (id)[UIColor whiteColor].CGColor ];
		_blurView.maskView.layer.mask = gradientMask;
		
		_avatarView = [[HBAPAvatarView alloc] initWithSize:HBAPAvatarSizeReasonablySmall];
		_avatarView.frame = CGRectMake(10.f, 100.f, 90.f, 90.f);
		_avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
		_avatarView.layer.borderWidth = 2.f;
		[self.contentView addSubview:_avatarView];
		
		_nameLabel = [[UILabel alloc] init];
		_nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		_nameLabel.numberOfLines = 0;
		[self.contentView addSubview:_nameLabel];
		
		_bioTextView = [[HBAPTweetTextView alloc] init];
		_bioTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:_bioTextView];
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
	
	[self updateUserLabelWithColor:nil];
	
	[_user createAttributedStringIfNeeded];
	_bioTextView.attributedString = _user.bioAttributedString;
	_bioTextView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05f];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		_bioTextView.backgroundColor = [UIColor clearColor];
	});
	
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
	
	[self setNeedsDisplay];
}

- (void)_setBannerImage:(UIImage *)image {
	_bannerImageView.image = image;
	[_blurView setNeedsDisplay];
	
	_dominantColor = [[HBAPDominantColor dominantColorForImage:_bannerImageView.image] retain];
	
	if (_gotHeaderCallback) {
		_gotHeaderCallback();
	}
	
	BOOL isDark = [HBAPDominantColor isDarkColor:_dominantColor];
	UIColor *color = isDark ? [self.class foregroundColorDark] : [self.class foregroundColorLight];
	_avatarView.layer.borderColor = color.CGColor;
	
	[UIView animateWithDuration:0.2 animations:^{
		_bannerImageView.alpha = 1;
		[self updateUserLabelWithColor:color];
	}];
	
	[self setNeedsDisplay];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	_blurView.maskView.layer.mask.frame = _bannerImageView.bounds;
	
	CGFloat origin = _avatarView.frame.origin.x + _avatarView.frame.size.width + 8.f;
	CGFloat height = [_nameLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].height;
	_nameLabel.frame = CGRectMake(origin, _bannerImageView.frame.size.height - height - 8.f, _bannerImageView.frame.size.width - origin - 10.f, height);
	_bioTextView.frame = CGRectMake(origin, _bannerImageView.frame.size.height + 4.f, _nameLabel.frame.size.width, ceilf([_bioTextView.attributedString boundingRectWithSize:CGSizeMake(_nameLabel.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height));
}

- (void)updateUserLabelWithColor:(UIColor *)color {
	if (!color) {
		color = [self.class foregroundColorLight];
	}
	
	NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	paragraphStyle.lineSpacing = 0.f;
	paragraphStyle.maximumLineHeight = 17.f;
	
	NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n@%@", _user.realName, _user.screenName]] autorelease];
	[attributedString addAttributes:@{
		NSFontAttributeName: [[HBAPFontManager sharedInstance].bodyFont fontWithSize:32.f],
		NSForegroundColorAttributeName: color
	} range:NSMakeRange(0, _user.realName.length)];
	[attributedString addAttributes:@{
		NSFontAttributeName: [[HBAPFontManager sharedInstance].footerFont fontWithSize:15.f],
		NSParagraphStyleAttributeName: paragraphStyle,
		NSForegroundColorAttributeName: color
	} range:NSMakeRange(_user.realName.length + 1, _user.screenName.length + 1)];
	_nameLabel.attributedText = attributedString;
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
