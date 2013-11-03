//
//  HBAPTimelineViewController.h
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewController.h"

@class HBAPAccount;

@interface HBAPTimelineViewController : HBAPTableViewController

- (void)loadTweetsFromArray:(NSArray *)array;
- (void)saveState;

@property (nonatomic, retain) NSString *apiPath;
@property (nonatomic, retain) HBAPAccount *account;

@end
