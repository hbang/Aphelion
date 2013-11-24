//
//  HBAPPreferencesTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 15/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPPreferencesTableViewCell.h"

@implementation HBAPPreferencesTableViewCell

+ (CGFloat)cellHeight {
	return 44.f;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];
	return self;
}

- (void)cellTapped {}

#pragma mark - Memory management

- (void)dealloc {
	[_specifier release];
	
	[super dealloc];
}

@end
