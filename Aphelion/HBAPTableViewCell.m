//
//  HBAPTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 24/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewCell.h"
#import "HBAPThemeManager.h"

@implementation HBAPTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self) {
		[self setupTheme];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTheme) name:HBAPThemeChanged object:nil];
	}
	
	return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	return self;
}

- (void)setupTheme {
	self.backgroundColor = nil;
	
	self.backgroundView = [[[UIView alloc] init] autorelease];
	self.backgroundView.backgroundColor = [HBAPThemeManager sharedInstance].backgroundColor;
	
	self.selectedBackgroundView = [[[UIView alloc] init] autorelease];
	self.selectedBackgroundView.backgroundColor = [HBAPThemeManager sharedInstance].highlightColor;
	
	self.textLabel.textColor = [HBAPThemeManager sharedInstance].textColor;
	self.detailTextLabel.textColor = [HBAPThemeManager sharedInstance].dimTextColor;
}

@end
