//
//  HBBMAppDelegate.m
//  Bromine
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBBMAppDelegate.h"
#import "HBBMHomeTimelineViewController.h"
#import "HBBMWelcomeViewController.h"

@implementation HBBMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rootViewController = [[HBBMRootViewController alloc] init];
	_window.rootViewController = _rootViewController;
	[_window makeKeyAndVisible];
	
	HBBMHomeTimelineViewController *homeViewController = [[[HBBMHomeTimelineViewController alloc] init] autorelease];
	[_rootViewController pushViewController:homeViewController];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"keys"]) {
		HBBMWelcomeViewController *welcomeViewController = [[[HBBMWelcomeViewController alloc] init] autorelease];
		welcomeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
		[_rootViewController presentViewController:welcomeViewController animated:YES completion:NULL];
	}
	
	return YES;
}

- (void)dealloc {
	[_window release];
	[_rootViewController release];
	[super dealloc];
}

@end
