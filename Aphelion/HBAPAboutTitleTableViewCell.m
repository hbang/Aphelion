//
//  HBAPAboutTitleTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 15/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAboutTitleTableViewCell.h"
#import "HBAPThemeManager.h"
#import "HBAPFontManager.h"

@implementation HBAPAboutTitleTableViewCell

#pragma mark - Constants

+ (CGFloat)cellHeight {
	return [@" " sizeWithAttributes:@{ NSFontAttributeName: [[HBAPFontManager sharedInstance].headingFont fontWithSize:IS_IPAD ? 45.f : 30.f] }].height + 15.f + [@" " sizeWithAttributes:@{ NSFontAttributeName: [[HBAPFontManager sharedInstance].bodyFont fontWithSize:IS_IPAD ? 20.f : 16.f] }].height;
}

+ (UIFont *)nameLabelFont {
	return [[HBAPFontManager sharedInstance].headingFont fontWithSize:IS_IPAD ? 45.f : 30.f];
}

+ (UIFont *)versionLabelFont {
	return [[HBAPFontManager sharedInstance].bodyFont fontWithSize:IS_IPAD ? 20.f : 16.f];
}

#pragma mark - Implementation

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];
	
	if (self) {
		self.backgroundView = nil;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UILabel *nameLabel = [[[UILabel alloc] init] autorelease];
		nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		nameLabel.font = [self.class nameLabelFont];
		nameLabel.textAlignment = NSTextAlignmentCenter;
		nameLabel.textColor = [HBAPThemeManager sharedInstance].textColor;
		nameLabel.text = @"Aphelion";
		[nameLabel sizeToFit];
		nameLabel.frame = CGRectMake(0, 0, self.contentView.frame.size.width, nameLabel.frame.size.height);
		[self.contentView addSubview:nameLabel];
		
		UILabel *versionLabel = [[[UILabel alloc] init] autorelease];
		versionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		versionLabel.font = [self.class versionLabelFont];
		versionLabel.textAlignment = NSTextAlignmentCenter;
		versionLabel.textColor = [HBAPThemeManager sharedInstance].dimTextColor;
		versionLabel.text = [NSString stringWithFormat:L18N(@"Version %@ (%@)"), [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"], [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]];
		[versionLabel sizeToFit];
		versionLabel.frame = CGRectMake(0, nameLabel.frame.origin.y + nameLabel.frame.size.height + 15.f, self.contentView.frame.size.width, versionLabel.frame.size.height);
		[self.contentView addSubview:versionLabel];
	}

	return self;
}

@end
