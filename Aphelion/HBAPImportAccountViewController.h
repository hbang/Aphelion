//
//  HBAPImportAccountViewController.h
//  Aphelion
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBAPWelcomeViewController.h"

@interface HBAPImportAccountViewController : UITableViewController {
	UIPopoverController *_importPopoverController;
	HBAPWelcomeViewController *_welcomeViewController;
}

@property (nonatomic, retain) UIPopoverController *importPopoverController;
@property (nonatomic, retain) HBAPWelcomeViewController *welcomeViewController;

@end
