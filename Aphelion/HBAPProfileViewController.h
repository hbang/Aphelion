//
//  HBAPProfileViewController.h
//  Aphelion
//
//  Created by Adam D on 1/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewController.h"

@class HBAPUser;

@interface HBAPProfileViewController : HBAPTableViewController

- (instancetype)initWithUser:(HBAPUser *)user;
- (instancetype)initWithUserID:(NSString *)userID;

@end
