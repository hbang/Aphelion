//
//  HBAPTimelineComposeViewController.h
//  Aphelion
//
//  Created by Adam D on 7/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTimelineViewController.h"

@class HBAPTweet, HBAPUser;

typedef NS_ENUM(NSUInteger, HBAPCanCompose) {
	HBAPCanComposeNo,
	HBAPCanComposeYes,
	HBAPCanComposeReply,
};

@interface HBAPTimelineComposeViewController : HBAPTimelineViewController <UIAlertViewDelegate>

@property HBAPCanCompose canCompose;
@property (nonatomic, retain) HBAPTweet *composeInReplyToTweet;
@property (nonatomic, retain) HBAPUser *composeInReplyToUser;

@end
