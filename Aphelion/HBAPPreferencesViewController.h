//
//  HBAPPreferencesViewController.h
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewController.h"

@interface HBAPPreferencesViewController : HBAPTableViewController

+ (NSString *)specifierPlist;

- (instancetype)initWithPlistName:(NSString *)name;

@end
