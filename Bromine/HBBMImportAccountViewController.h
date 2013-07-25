//
//  HBBMImportAccountViewController.h
//  Bromine
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBBMWelcomeViewController.h"

@interface HBBMImportAccountViewController : UITableViewController {
	UIPopoverController *_importPopoverController;
	HBBMWelcomeViewController *_welcomeViewController;
}

@property (nonatomic, retain) UIPopoverController *importPopoverController;
@property (nonatomic, retain) HBBMWelcomeViewController *welcomeViewController;

@end
