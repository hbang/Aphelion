//
//  HBAPAppDelegate.h
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HBAPRootViewController;

@interface HBAPAppDelegate : UIResponder <UIApplicationDelegate> {
	HBAPRootViewController *_rootViewController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HBAPRootViewController *rootViewController;

@end
