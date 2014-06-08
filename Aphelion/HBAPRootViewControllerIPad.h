//
//  HBAPRootViewControllerIPad.h
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPViewController.h"

@interface HBAPRootViewControllerIPad : HBAPViewController <UIScrollViewDelegate> {
	NSUInteger _currentPosition;
}

@property (nonatomic, retain, readonly) UITabBarController *iphoneTabBarController;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated doubleWidth:(BOOL)doubleWidth;
- (void)popViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)initialSetup;

@end
