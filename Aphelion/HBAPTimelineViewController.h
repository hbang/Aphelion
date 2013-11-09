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

- (void)insertTweetsFromArray:(NSArray *)array atIndex:(NSUInteger)index;
- (void)performRefresh;

@property (nonatomic, retain) NSString *apiPath;
@property (nonatomic, retain) HBAPAccount *account;

@end
