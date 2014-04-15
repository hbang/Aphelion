//
//  HBAPMessageActivity.m
//  Aphelion
//
//  Created by Adam D on 16/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPMessageActivity.h"

@implementation HBAPMessageActivity

- (NSString *)title {
	return L18N(@"Message");
}

- (UIImage *)icon {
	return [UIImage imageNamed:@"activity_message"];
}

@end
