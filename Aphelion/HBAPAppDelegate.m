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
#import <AFNetworking/AFNetworking.h>
#import <AFOAuth1Client/AFOAuth1Client.h>
#import <LUKeychainAccess/LUKeychainAccess.h>
#import "HBAPNavigationController.h"

@implementation HBAPAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	if (YES||![[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"]) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"firstRun"];
		[[LUKeychainAccess standardKeychainAccess] deleteAll];
	}
	
	NSString *timelinesPath = [GET_DIR(NSCachesDirectory) stringByAppendingPathComponent:@"timelines"];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:timelinesPath]) {
		NSError *error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:timelinesPath withIntermediateDirectories:YES attributes:nil error:&error];
		
		if (error) {
			NSLog(@"error creating timelines cache dir: %@", error);
		}
	}
	
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rootViewController = [[HBAPRootViewController alloc] init];
	_window.rootViewController = _rootViewController;
	[_window makeKeyAndVisible];
	
	if ([[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"] && ((NSDictionary *)[[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"]).count) {
		[_rootViewController initialSetup];
	} else {
		HBAPWelcomeViewController *welcomeViewController = [[[HBAPWelcomeViewController alloc] init] autorelease];
		
		if (IS_IPAD) {
			// TODO: this
		} else {
			HBAPNavigationController *navigationController = [[[HBAPNavigationController alloc] initWithRootViewController:welcomeViewController] autorelease];
			[_rootViewController presentViewController:navigationController animated:YES completion:NULL];
		}
	}
	
	return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	if ([url.scheme isEqualToString:@"ws.hbang.aphelion"] && [url.host isEqualToString:@"_oauthcallback"]) {
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:@{ kAFApplicationLaunchOptionsURLKey: url }]];
		return YES;
	}
		
	return NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	for (UINavigationController *navigationController in ROOT_VC.childViewControllers) {
		UIViewController *viewController = navigationController.viewControllers[0];
		
		if ([viewController respondsToSelector:@selector(saveState)]) {
			[(HBAPTimelineViewController *)viewController saveState];
		}
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[_window release];
	[_rootViewController release];
	
	[super dealloc];
}

@end
