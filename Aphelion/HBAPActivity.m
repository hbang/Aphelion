//
//  HBAPActivity.m
//  Aphelion
//
//  Created by Adam D on 4/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPActivity.h"

@implementation HBAPActivity

- (BOOL)shouldShow {
	return YES;
}

- (void)activityTapped {
	HBLogError(@"activityTapped not implemented for %@", self.class);
}

- (NSString *)title {
	HBLogError(@"title not implemented for %@", self.class);
	return @"";
}

- (UIImage *)icon {
	HBLogError(@"icon not implemented for %@", self.class);
	return nil;
}

@end
