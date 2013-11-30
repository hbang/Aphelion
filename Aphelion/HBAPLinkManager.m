//
//  HBAPLinkManager.m
//  Aphelion
//
//  Created by Adam D on 30/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPLinkManager.h"
#import "HBAPProfileViewController.h"
#import "HBAPTweetDetailViewController.h"
#import "HBAPTwitterAPISessionManager.h"
#import "HBAPTwitterConfiguration.h"
#import "NSString+HBAdditions.h"

static NSString *const HBAPBrowserKey = @"app_browser";
static NSString *const HBAPYouTubeAppKey = @"app_youtube";
static NSString *const HBAPMapsAppKey = @"app_maps";
static NSString *const HBAPGitHubAppKey = @"app_github";
static NSString *const HBAPIMDBAppKey = @"app_imdb";
static NSString *const HBAPEBayAppKey = @"app_ebay";

@implementation HBAPLinkManager

+ (instancetype)sharedInstance {
	static HBAPLinkManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self.class alloc] init];
	});
	
	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
		[self reloadPreferences];
	}
	
	return self;
}


#pragma mark - Preferences

- (void)reloadPreferences {
	_browserApp = [[[NSUserDefaults standardUserDefaults] objectForKey:HBAPBrowserKey] ?: HBAPBrowserSafari retain];
	_youTubeApp = [[[NSUserDefaults standardUserDefaults] objectForKey:HBAPYouTubeAppKey] ?: HBAPYouTubeApp retain];
	_mapsApp = [[[NSUserDefaults standardUserDefaults] objectForKey:HBAPMapsAppKey] ?: HBAPMapsApple retain];
	_gitHubApp = [[[NSUserDefaults standardUserDefaults] objectForKey:HBAPGitHubAppKey] ?: HBAPGitHubIOctocat retain];
	_imdbApp = [[[NSUserDefaults standardUserDefaults] objectForKey:HBAPIMDBAppKey] ?: HBAPIMDBApp retain];
	_ebayApp = [[[NSUserDefaults standardUserDefaults] objectForKey:HBAPEBayAppKey] ?: HBAPEBayApp retain];
}

#pragma mark - Open URL

- (void)openURL:(NSURL *)url navigationController:(UINavigationController *)navigationController {
	if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
		if (([url.host isEqualToString:@"twitter.com"] || [url.host isEqualToString:@"www.twitter.com"] || [url.host isEqualToString:@"mobile.twitter.com"]) && url.pathComponents.count > 1) {
			if (url.pathComponents.count == 2 && [url.pathComponents[1] isEqualToString:@"search"] && url.query) {
				HBLogInfo(@"openURL: opening search vc not implemented");
				return;
			} else if (url.pathComponents.count == 2 && ![[HBAPTwitterAPISessionManager sharedInstance].configuration.nonUsernamePaths containsObject:url.pathComponents[1]]) {
				HBAPProfileViewController *viewController = [[[HBAPProfileViewController alloc] initWithScreenName:url.pathComponents[1]] autorelease];
				[navigationController pushViewController:viewController animated:YES];
				return;
			} else if (url.pathComponents.count == 4 && ([url.pathComponents[2] isEqualToString:@"status"] || [url.pathComponents[2] isEqualToString:@"statuses"])) {
				HBAPTweetDetailViewController *viewController = [[[HBAPTweetDetailViewController alloc] init] autorelease];
				[navigationController pushViewController:viewController animated:YES];
				return;
			}
		} else if (([url.host isEqualToString:@"github.com"] || [url.host isEqualToString:@"gist.github.com"]) && [_gitHubApp isEqualToString:HBAPGitHubIOctocat] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ioc://"]]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"ioc://%@%@", url.host, url.path]]];
			return;
		} else if (([url.host isEqualToString:@"imdb.com"] || [url.host isEqualToString:@"www.imdb.com"]) && url.pathComponents.count == 3 && [_imdbApp isEqualToString:HBAPIMDBApp] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"imdb://"]]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"imdb:///title/" stringByAppendingString:((NSString *)url.pathComponents[2]).URLEncodedString]]];
			return;
		} else if (([url.host hasPrefix:@"ebay.co"] || [url.host hasPrefix:@"www.ebay.co"]) && url.pathComponents.count == 4 && [_ebayApp isEqualToString:HBAPEBayApp] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ebay://"]]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"ebay://launch?itm=" stringByAppendingString:((NSString *)url.pathComponents[3]).URLEncodedString]]];
			return;
		}
	}
	
	[self _openURLInBrowser:url];
}

- (void)_openURLInBrowser:(NSURL *)url {
	if ([_browserApp isEqualToString:HBAPBrowserChrome] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome-x-callback://"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"googlechrome-x-callback://x-callback-url/open/?x-source=Aphelion&x-success=ws.hbang.aphelion%3A%2F%2F&create-new-tab&url=" stringByAppendingString:url.absoluteString.URLEncodedString]]];
	} else if ([_browserApp isEqualToString:HBAPBrowserProcyon] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"procyon://"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"procyon://" stringByAppendingString:url.absoluteString.URLEncodedString]]];
	} else {
		[[UIApplication sharedApplication] openURL:url];
	}
}

#pragma mark - Action sheet

- (void)showActionSheetForURL:(NSURL *)url navigationController:(UINavigationController *)navigationController {
	NOIMP
}

@end
