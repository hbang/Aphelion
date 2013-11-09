//
//  HBAPHomeTabBarController.m
//  Aphelion
//
//  Created by Adam D on 6/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPHomeTabBarController.h"
#import "HBAPNavigationController.h"
#import "HBAPHomeTimelineViewController.h"
#import "HBAPMentionsTimelineViewController.h"
#import "HBAPMessagesViewController.h"
#import "HBAPProfileViewController.h"
#import "HBAPSearchTimelineViewController.h"
#import "HBAPPreferencesViewController.h"
#import "HBAPAccountController.h"
#import "HBAPAccount.h"

@interface HBAPHomeTabBarController ()

@end

@implementation HBAPHomeTabBarController

- (instancetype)initWithAccount:(HBAPAccount *)account {
	self = [super init];
	
	if (self) {
		HBAPHomeTimelineViewController *homeViewController = [[[HBAPHomeTimelineViewController alloc] init] autorelease];
		HBAPNavigationController *homeNavigationController = [[[HBAPNavigationController alloc] initWithRootViewController:homeViewController] autorelease];
		homeNavigationController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:L18N(@"Home") image:[UIImage imageNamed:@"sidebar_home"] selectedImage:[UIImage imageNamed:@"sidebar_home_selected"]] autorelease];
		
		HBAPMentionsTimelineViewController *mentionsViewController = [[[HBAPMentionsTimelineViewController alloc] init] autorelease];
		HBAPNavigationController *mentionsNavigationController = [[[HBAPNavigationController alloc] initWithRootViewController:mentionsViewController] autorelease];
		mentionsNavigationController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:L18N(@"Mentions") image:[UIImage imageNamed:@"sidebar_mentions"] selectedImage:[UIImage imageNamed:@"sidebar_mentions_selected"]] autorelease];
		
		HBAPMessagesViewController *messagesViewController = [[[HBAPMessagesViewController alloc] init] autorelease];
		HBAPNavigationController *messagesNavigationController = [[[HBAPNavigationController alloc] initWithRootViewController:messagesViewController] autorelease];
		messagesNavigationController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:L18N(@"Messages") image:[UIImage imageNamed:@"sidebar_messages"] selectedImage:[UIImage imageNamed:@"sidebar_messages_selected"]] autorelease];
		
		HBAPProfileViewController *profileViewController = [[[HBAPProfileViewController alloc] initWithUser:[HBAPAccountController sharedInstance].accountForCurrentUser.user] autorelease];
		HBAPNavigationController *profileNavigationController = [[[HBAPNavigationController alloc] initWithRootViewController:profileViewController] autorelease];
		profileNavigationController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:L18N(@"Profile") image:[UIImage imageNamed:@"sidebar_user"] selectedImage:[UIImage imageNamed:@"sidebar_user_selected"]] autorelease];
		
		HBAPSearchTimelineViewController *searchViewController = [[[HBAPSearchTimelineViewController alloc] init] autorelease];
		HBAPNavigationController *searchNavigationController = [[[HBAPNavigationController alloc] initWithRootViewController:searchViewController] autorelease];
		searchNavigationController.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0] autorelease];
		
		HBAPPreferencesViewController *preferencesViewController = [[[HBAPPreferencesViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
		HBAPNavigationController *preferencesNavigationController = [[[HBAPNavigationController alloc] initWithRootViewController:preferencesViewController] autorelease];
		preferencesNavigationController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:L18N(@"Settings") image:[UIImage imageNamed:@"sidebar_settings"] selectedImage:[UIImage imageNamed:@"sidebar_settings_selected"]] autorelease];
		
		self.viewControllers = @[
			homeNavigationController,
			mentionsNavigationController,
			messagesNavigationController,
			profileNavigationController,
			searchNavigationController,
			preferencesNavigationController
		];
	}
	
	return self;
}

@end
