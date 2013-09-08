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
#import "AFNetworking/AFNetworking.h"
#import "AFOAuth1Client/AFOAuth1Client.h"
#import "LUKeychainAccess/LUKeychainAccess.h"

@implementation HBAPAppDelegate

@synthesize rootViewController = _rootViewController;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rootViewController = [[HBAPRootViewController alloc] init];
	_window.rootViewController = _rootViewController;
	[_window makeKeyAndVisible];
	
	if ([[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"]) {
		HBAPHomeTimelineViewController *homeViewController = [[[HBAPHomeTimelineViewController alloc] init] autorelease];
		[_rootViewController pushViewController:homeViewController animated:YES];
	} else {
		HBAPWelcomeViewController *welcomeViewController = [[[HBAPWelcomeViewController alloc] init] autorelease];
		[_rootViewController pushViewController:welcomeViewController animated:YES doubleWidth:YES];
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

#pragma mark - Memory management

- (void)dealloc {
	[_window release];
	[_rootViewController release];
	
	[super dealloc];
}

@end
