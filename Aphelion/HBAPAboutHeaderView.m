//
//  HBAPAboutHeaderView.m
//  Aphelion
//
//  Created by Adam D on 15/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAboutHeaderView.h"
#import "HBAPFontManager.h"
#import "HBAPThemeManager.h"

@implementation HBAPAboutHeaderView

#pragma mark - Constants

+ (CGFloat)cellHeight {
	return (IS_IPAD ? 300.f : 200.f) + 20.f + [@" " sizeWithAttributes:@{ NSFontAttributeName: [[HBAPFontManager sharedInstance].headingFont fontWithSize:IS_IPAD ? 45.f : 30.f] }].height + 5.f + [@" " sizeWithAttributes:@{ NSFontAttributeName: [[HBAPFontManager sharedInstance].bodyFont fontWithSize:IS_IPAD ? 20.f : 16.f] }].height;
}

+ (UIFont *)nameLabelFont {
	return [[HBAPFontManager sharedInstance].headingFont fontWithSize:IS_IPAD ? 45.f : 30.f];
}

+ (UIFont *)versionLabelFont {
	return [[HBAPFontManager sharedInstance].bodyFont fontWithSize:IS_IPAD ? 20.f : 16.f];
}

#pragma mark - Implementation

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		UIImageView *iconImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bigicon"]] autorelease];
		iconImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		iconImageView.center = CGPointMake(self.frame.size.width / 2, iconImageView.center.y);
		[self addSubview:iconImageView];
		
		UILabel *nameLabel = [[[UILabel alloc] init] autorelease];
		nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		nameLabel.font = [self.class nameLabelFont];
		nameLabel.textAlignment = NSTextAlignmentCenter;
		nameLabel.textColor = [HBAPThemeManager sharedInstance].textColor;
		nameLabel.text = @"Aphelion";
		nameLabel.frame = CGRectMake(0, iconImageView.frame.size.height + 20.f, self.frame.size.width, [nameLabel sizeThatFits:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)].height);
		[self addSubview:nameLabel];
		
		UILabel *versionLabel = [[[UILabel alloc] init] autorelease];
		versionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		versionLabel.font = [self.class versionLabelFont];
		versionLabel.textAlignment = NSTextAlignmentCenter;
		versionLabel.textColor = [HBAPThemeManager sharedInstance].dimTextColor;
		versionLabel.text = [NSString stringWithFormat:L18N(@"Version %@ (%@)"), [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"], [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]];
		versionLabel.frame = CGRectMake(0, nameLabel.frame.origin.y + nameLabel.frame.size.height + 5.f, self.frame.size.width, [versionLabel sizeThatFits:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)].height);
		[self addSubview:versionLabel];
	}
	
	return self;
}

@end
