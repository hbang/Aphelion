//
//  HBAPUserListViewController.h
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewController.h"

@interface HBAPUserListViewController : HBAPTableViewController

@property (nonatomic, retain) NSMutableArray *users;
@property (nonatomic, retain) NSString *noUsersString;

@end
