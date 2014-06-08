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
	return 25.f;
}

+ (CGFloat)buttonHeight {
	return [self iconSize] + 39.f;
}

#pragma mark - General stuff

+ (instancetype)button {
	HBAPSidebarButton *button = [self.class buttonWithType:UIButtonTypeSystem];
	
	return button;
}

@end
