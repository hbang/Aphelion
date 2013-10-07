//
//  HBAPTimelineViewController.h
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HBAPAccount;

@interface HBAPTimelineViewController : UITableViewController

- (void)loadTweetsFromArray:(NSArray *)array;
- (void)saveState;

@property (nonatomic, retain) NSString *apiPath;
@property (nonatomic, retain) HBAPAccount *account;

@end
