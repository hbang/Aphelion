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
#import "HBAPNavigationController.h"
#import "HBAPTwitterConfiguration.h"
#import "HBAPThemeManager.h"
#import <AFNetworking/AFNetworking.h>
#import <UIKit+AFNetworking/UIKit+AFNetworking.h>
#import <LUKeychainAccess/LUKeychainAccess.h>
#import <TestFlight/TestFlight.h>

@implementation HBAPAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// testflight
#if !DEBUG
#if kHBAPBuildIsBeta
	[TestFlight addCustomEnvironmentInformation:[UIDevice currentDevice].name forKey:@"devicename"]; // thanks rickye <4
#endif
	[TestFlight takeOff:@"e487899c-63ba-4f43-a718-96fd0c0faa02"];
#endif
	
	// defaults, keychain, caches
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"]) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"firstRun"];
		[[LUKeychainAccess standardKeychainAccess] deleteAll];
	}
	
	NSString *timelinesPath = [GET_DIR(NSCachesDirectory) stringByAppendingPathComponent:@"timelines"];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:timelinesPath]) {
		NSError *error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:timelinesPath withIntermediateDirectories:YES attributes:nil error:&error];
		
		if (error) {
			HBLogWarn(@"error creating timelines cache dir: %@", error);
		}
	}
	
	[HBAPTwitterConfiguration updateIfNeeded];
	[HBAPThemeManager sharedInstance];
	// notifications
	[[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		NSArray *childViewControllers = IS_IPAD ? _rootViewController.childViewControllers : _rootViewController.iphoneTabBarController.viewControllers;
		for (UINavigationController *navigationController in childViewControllers) {
			for (UITableViewController *viewController in navigationController.viewControllers) {
				if ([viewController respondsToSelector:@selector(tableView)]) {
					[viewController.tableView reloadData];
				}
			}
		}
	}];
	[AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
	
	// interface
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rootViewController = [[HBAPRootViewController alloc] init];
	_window.rootViewController = _rootViewController;
	[_window makeKeyAndVisible];
	
	if ([[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"] && ((NSDictionary *)[[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"]).count) {
		[_rootViewController initialSetup];
	} else {
		HBAPWelcomeViewController *welcomeViewController = [[[HBAPWelcomeViewController alloc] init] autorelease];
		
		if (IS_IPAD) {
			[_rootViewController pushViewController:welcomeViewController animated:YES doubleWidth:YES];
		} else {
			HBAPNavigationController *navigationController = [[[HBAPNavigationController alloc] initWithRootViewController:welcomeViewController] autorelease];
			[_rootViewController presentViewController:navigationController animated:NO completion:NULL];
		}
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
