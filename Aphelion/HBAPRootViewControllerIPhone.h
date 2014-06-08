//
//  HBAPRootViewControllerIPhone.h
//  Aphelion
//
//  Created by Adam D on 6/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBAPViewController.h"

@class HBAPAccount;

@interface HBAPRootViewControllerIPhone : HBAPViewController

- (instancetype)initWithAccount:(HBAPAccount *)account;

- (void)initialSetup;

@property (nonatomic, retain) HBAPAccount *account;

@end
