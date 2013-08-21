//
//  HBAPAppDelegate.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAppDelegate.h"
#import "HBAPRootViewController.h"
#import "HBAPHomeTimelineViewController.h"
#import "HBAPWelcomeViewController.h"

@implementation HBAPAppDelegate
@synthesize rootViewController = _rootViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rootViewController = [[HBAPRootViewController alloc] init];
	_window.rootViewController = _rootViewController;
	[_window makeKeyAndVisible];
	
	if (YES || GET_KEY(@"accounts")) { // TODO: DON'T FORGET TO REMOVE THIS YES
		HBAPHomeTimelineViewController *homeViewController = [[[HBAPHomeTimelineViewController alloc] init] autorelease];
		[_rootViewController pushViewController:homeViewController animated:YES];
	} else {
		HBAPWelcomeViewController *welcomeViewController = [[[HBAPWelcomeViewController alloc] init] autorelease];
		UINavigationController *welcomeNavigationController = [[[UINavigationController alloc] initWithRootViewController:welcomeViewController] autorelease];
		welcomeNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
		[_rootViewController presentViewController:welcomeNavigationController animated:YES completion:NULL];
	}
	
	return YES;
}

#pragma mark - Memory management

- (void)dealloc {
	[_window release];
	[_rootViewController release];
	
	[super dealloc];
}

@end
