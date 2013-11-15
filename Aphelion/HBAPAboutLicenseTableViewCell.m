//
//  HBAPAboutLicenseTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 15/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAboutLicenseTableViewCell.h"

@implementation HBAPAboutLicenseTableViewCell

+ (CGFloat)cellHeight {
	return 80.f;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
	
	if (self) {
		self.detailTextLabel.numberOfLines = 0;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return self;
}

- (void)setSpecifier:(NSDictionary *)specifier {
	[super setSpecifier:specifier];
	
	self.textLabel.text = specifier[@"label"];
	self.detailTextLabel.text = specifier[@"license"];
}

- (void)cellTapped {
	[super cellTapped];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.specifier[@"url"]]];
}

@end
