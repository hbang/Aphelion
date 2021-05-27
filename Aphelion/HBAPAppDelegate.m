//
//  HBAPAppDelegate.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPAppDelegate.h"
#import "HBAPRootViewControllerIPad.h"
#import "HBAPRootViewControllerIPhone.h"
#import "HBAPHomeTimelineViewController.h"
#import "HBAPWelcomeViewController.h"
#import "HBAPNavigationController.h"
#import "HBAPTwitterConfiguration.h"
#import "HBAPThemeManager.h"
#import "HBAPFontManager.h"
#import "HBAPAccountController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import <LUKeychainAccess/LUKeychainAccess.h>
//#import <TestFlightSDK/TestFlight.h>
#include <dlfcn.h>

@implementation HBAPAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// testflight
#if !DEBUG
#if kHBAPBuildIsBeta
//	[TestFlight addCustomEnvironmentInformation:[UIDevice currentDevice].name forKey:@"devicename"]; // thanks rickye <4
#endif
//	[TestFlight takeOff:@"e487899c-63ba-4f43-a718-96fd0c0faa02"];
#endif
	
	// defaults, keychain, caches
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"]) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"firstRun"];
		[[LUKeychainAccess standardKeychainAccess] deleteAll];
	}
	
	for (NSString *path in @[ @"timelines", @"avatars", @"banners", @"accounts" ]) {
		NSString *fullPath = [GET_DIR(NSCachesDirectory) stringByAppendingPathComponent:path];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
			NSError *error = nil;
			[[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&error];
			
			if (error) {
				HBLogWarn(@"error creating %@ cache dir: %@", path, error);
			}
		}
	}
	
	[HBAPAccountController sharedInstance];
	[HBAPTwitterConfiguration updateIfNeeded];
	[HBAPThemeManager sharedInstance];
	[HBAPFontManager sharedInstance];
	[AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
	
	// interface
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	if (IS_IPAD) {
		_rootViewControllerIPad = [[HBAPRootViewControllerIPad alloc] init];
		_rootViewController = _rootViewControllerIPad;
	} else {
		_rootViewControllerIPhone = [[HBAPRootViewControllerIPhone alloc] init];
		_rootViewController = _rootViewControllerIPhone;
	}
	
	_window.rootViewController = _rootViewController;
	[_window makeKeyAndVisible];
	
	if ([[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"] && ((NSDictionary *)[[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"]).count) {
		[(HBAPRootViewControllerIPad *)_rootViewController initialSetup];
	} else {
		HBAPWelcomeViewController *welcomeViewController = [[[HBAPWelcomeViewController alloc] init] autorelease];
		HBAPNavigationController *navigationController = [[[HBAPNavigationController alloc] initWithRootViewController:welcomeViewController] autorelease];
		[_rootViewController presentViewController:navigationController animated:NO completion:NULL];
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
