//
//  HBBMTimelineViewController.h
//  Bromine
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface HBBMTimelineViewController : UITableViewController {
	NSMutableArray *_tweets;
	ACAccount *_account;
}

- (void)loadTweetsFromPath:(NSString *)path;

@property (nonatomic, retain) ACAccount *account;

@end
