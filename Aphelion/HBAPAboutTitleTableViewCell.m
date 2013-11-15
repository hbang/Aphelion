//
//  HBAPAboutTitleTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 15/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAboutTitleTableViewCell.h"
#import "HBAPThemeManager.h"

@implementation HBAPAboutTitleTableViewCell

+ (CGFloat)cellHeight {
	return [@" " sizeWithAttributes:@{ NSFontAttributeName: [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:IS_IPAD ? 45.f : 30.f] }].height + 15.f + [@" " sizeWithAttributes:@{ NSFontAttributeName: [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontWithSize:IS_IPAD ? 20.f : 16.f] }].height;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];
	
	if (self) {
		self.backgroundView = nil;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UILabel *nameLabel = [[[UILabel alloc] init] autorelease];
		nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		nameLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:IS_IPAD ? 45.f : 30.f];
		nameLabel.textAlignment = NSTextAlignmentCenter;
		nameLabel.textColor = [HBAPThemeManager sharedInstance].textColor;
		nameLabel.text = @"Aphelion";
		[nameLabel sizeToFit];
		nameLabel.frame = CGRectMake(0, 0, self.contentView.frame.size.width, nameLabel.frame.size.height);
		[self.contentView addSubview:nameLabel];
		
		UILabel *versionLabel = [[[UILabel alloc] init] autorelease];
		versionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		versionLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontWithSize:IS_IPAD ? 20.f : 16.f];
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
