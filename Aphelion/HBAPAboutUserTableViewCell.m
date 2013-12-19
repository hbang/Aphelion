//
//  HBAPAboutUserTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 15/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAboutUserTableViewCell.h"
#import "HBAPUser.h"
#import "HBAPProfileViewController.h"

@interface HBAPAboutUserTableViewCell () {
	NSDictionary *_specifier;
}

@end

@implementation HBAPAboutUserTableViewCell

+ (CGFloat)cellHeight {
	return 62.f;
}

- (NSDictionary *)specifier {
	return _specifier;
}

- (void)setSpecifier:(NSDictionary *)specifier {
	if (_specifier == specifier) {
		return;
	}
	
	_specifier = specifier;
	
	self.user = [[[HBAPUser alloc] initStubWithUserID:specifier[@"userID"] screenName:specifier[@"screenName"] realName:specifier[@"realName"]] autorelease];
}

- (void)cellTapped {
	if (_navigationController) {
		HBAPProfileViewController *viewController = [[[HBAPProfileViewController alloc] initWithUser:self.user] autorelease];
		[_navigationController pushViewController:viewController animated:YES];
	} else {
		HBLogError(@"cellTapped: navigationController not set");
	}
}

@end
