//
//  HBAPAppDelegate.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAppDelegate.h"
#import "HBAPHomeTimelineViewController.h"
#import "HBAPWelcomeViewController.h"

@implementation HBAPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rootViewController = [[HBAPRootViewController alloc] init];
	_window.rootViewController = _rootViewController;
	[_window makeKeyAndVisible];
	
	HBAPHomeTimelineViewController *homeViewController = [[[HBAPHomeTimelineViewController alloc] init] autorelease];
	[_rootViewController pushViewController:homeViewController];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"]) {
		HBAPWelcomeViewController *welcomeViewController = [[[HBAPWelcomeViewController alloc] init] autorelease];
		welcomeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
		[_rootViewController presentViewController:welcomeViewController animated:YES completion:NULL];
	}
	
	return YES;
}

- (void)performFirstRunTutorial {
	NSLog(@"performFirstRunTutorial not implemented");
}

#pragma mark - Memory management

- (void)dealloc {
	[_window release];
	[_rootViewController release];
	
	[super dealloc];
}

@end
