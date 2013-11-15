//
//  HBAPAboutUserTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 15/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAboutUserTableViewCell.h"
#import "HBAPUser.h"

@implementation HBAPAboutUserTableViewCell

+ (CGFloat)cellHeight {
	return 62.f;
}

- (void)setSpecifier:(NSDictionary *)specifier {
	self.user = [[[HBAPUser alloc] initStubWithUserID:specifier[@"userID"] screenName:specifier[@"screenName"] realName:specifier[@"realName"]] autorelease];
}

@end
