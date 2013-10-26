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

- (void)avatarTapped {
	HBAPAccountSwitchViewController *viewController = [[[HBAPAccountSwitchViewController alloc] init] autorelease];
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	
	if (IS_IPAD) {
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
		[popoverController presentPopoverFromRect:CGRectMake(self.frame.origin.x - 10.f, self.frame.origin.y - 10.f, self.frame.size.width + 20.f, self.frame.size.height + 20.f) inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionLeft animated:YES];
	} else {
		[ROOT_VC presentViewController:navigationController animated:YES completion:NULL];
	}
}

@end
