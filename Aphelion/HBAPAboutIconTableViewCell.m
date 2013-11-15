//
//  HBAPAboutIconTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 15/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAboutIconTableViewCell.h"

@implementation HBAPAboutIconTableViewCell

+ (CGFloat)cellHeight {
	return [UIImage imageNamed:@"bigicon"].size.height;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];

	if (self) {
		self.backgroundView = nil;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UIImageView *iconImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bigicon"]] autorelease];
		iconImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		iconImageView.center = CGPointMake(self.contentView.frame.size.width / 2, iconImageView.center.y);
		[self.contentView addSubview:iconImageView];
	}

	return self;
}

@end
