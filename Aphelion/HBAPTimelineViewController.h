//
//  HBAPTimelineViewController.h
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HBAPAccount, HBAPTweet, HBAPUser;

typedef enum {
	HBAPCanComposeNo,
	HBAPCanComposeYes,
	HBAPCanComposeReply,
} HBAPCanCompose;

@interface HBAPTimelineViewController : UITableViewController

- (void)loadTweetsFromArray:(NSArray *)array;
- (void)saveState;

@property (nonatomic, retain) NSString *apiPath;
@property (nonatomic, retain) HBAPAccount *account;

@property HBAPCanCompose canCompose;
@property (nonatomic, retain) HBAPTweet *composeInReplyToTweet;
@property (nonatomic, retain) HBAPUser *composeInReplyToUser;

@end
