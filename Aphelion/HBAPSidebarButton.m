//
//  HBAPSidebarButton.m
//  Aphelion
//
//  Created by Adam D on 22/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPSidebarButton.h"
#import "HBAPThemeManager.h"

@implementation HBAPSidebarButton

#pragma mark - Interface constants

+ (CGFloat)iconSize {
	return 26.f;
}

+ (CGFloat)buttonHeight {
	return [self iconSize] + 38.f;
}

#pragma mark - General stuff

+ (instancetype)button {
	HBAPSidebarButton *button = [self.class buttonWithType:UIButtonTypeSystem];
	button.titleLabel.textAlignment = NSTextAlignmentCenter;
	button.tintColor = [HBAPThemeManager sharedInstance].sidebarTextColor;
	[button setTitleColor:[HBAPThemeManager sharedInstance].sidebarTextColor forState:UIControlStateNormal];
	[button setTitleColor:[HBAPThemeManager sharedInstance].tintColor forState:UIControlStateSelected];
	return button;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	self.tintColor = selected ? [HBAPThemeManager sharedInstance].tintColor : [HBAPThemeManager sharedInstance].sidebarTextColor;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
	CGRect rect = [super imageRectForContentRect:contentRect];
	return CGRectMake((self.frame.size.width / 2) - (rect.size.width / 2), 8.f, rect.size.width, [self.class iconSize]);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
	return CGRectMake(7.f, 8.f + [self.class iconSize] + 6.f, self.frame.size.width - 14.f, 16.f);
}

@end
