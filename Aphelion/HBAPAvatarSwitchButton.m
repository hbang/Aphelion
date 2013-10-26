//
//  HBAPAvatarSwitchButton.m
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAvatarSwitchButton.h"
#import "HBAPRootViewController.h"
#import "HBAPAccountSwitchViewController.h"

@implementation HBAPAvatarSwitchButton

- (instancetype)init {
	self = [super initWithUser:nil size:HBAPAvatarSizeSmall];
	
	return self;
}

- (void)avatarTapped {
	HBAPAccountSwitchViewController *viewController = [[[HBAPAccountSwitchViewController alloc] init] autorelease];
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	
	if (IS_IPAD) {
		UIPopoverController *popoverController = [[[UIPopoverController alloc] initWithContentViewController:navigationController] autorelease];
		[popoverController presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionLeft animated:YES];
	} else {
		[ROOT_VC presentViewController:navigationController animated:YES completion:NULL];
	}
}

@end
