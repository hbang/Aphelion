//
//  HBAPRootViewController.h
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBAPRootViewController : UIViewController {
	unsigned _currentPosition;
}

- (void)pushViewController:(UIViewController *)viewController;
- (void)popViewController;

@end
