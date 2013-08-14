//
//  HBAPTimelineViewController.h
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface HBAPTimelineViewController : UITableViewController {
	NSMutableArray *_tweets;
	ACAccount *_account;
}
- (void)_loadTweetsFromArray:(NSArray *)array;
- (void)loadTweetsFromPath:(NSString *)path;

@property (nonatomic, retain) ACAccount *account;

@end
