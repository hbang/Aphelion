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

/*
+ (UIColor *)normalColor {
	return [UIColor colorWithWhite:0.1607843137f alpha:1];
}

+ (UIColor *)selectedColor {
	return [UIColor whiteColor];
}

+ (UIColor *)normalTint {
	return [self normalColor];
}

+ (UIColor *)selectedTint {
	return [UIColor colorWithWhite:0.737254902f alpha:1];
}
*/

+ (CGFloat)iconSize {
	return 26.f;
}

+ (CGFloat)buttonHeight {
	return [self iconSize] + 38.f;
}

#pragma mark - General stuff

+ (instancetype)button {
	HBAPSidebarButton *button = [self.class buttonWithType:UIButtonTypeSystem];
	button.tintColor = [HBAPThemeManager sharedInstance].dimTextColor;//[self.class normalTint];
	button.titleLabel.textAlignment = NSTextAlignmentCenter;
	[button setTitleColor:[HBAPThemeManager sharedInstance].dimTextColor forState:UIControlStateNormal];
	[button setTitleColor:[HBAPThemeManager sharedInstance].tintColor forState:UIControlStateSelected];
	return button;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	
	self.tintColor = selected ? [HBAPThemeManager sharedInstance].tintColor : [HBAPThemeManager sharedInstance].dimTextColor;
}

- (CGRect)contentRectForBounds:(CGRect)bounds {
	return self.frame;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
	CGRect rect = [super imageRectForContentRect:contentRect];
	return CGRectMake((self.frame.size.width / 2) - (rect.size.width / 2), 8.f, rect.size.width, [self.class iconSize]);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
	CGRect rect = [super titleRectForContentRect:contentRect];
	return CGRectMake(0, 8.f + [self.class iconSize] + 4.f, self.frame.size.width, rect.size.height);
}

@end
