//
//  HBAPTweetDetailViewController.h
//  Aphelion
//
//  Created by Adam D on 20/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBAPTimelineComposeViewController.h"

@class HBAPTweet;

@interface HBAPTweetDetailViewController : HBAPTimelineComposeViewController

- (instancetype)initWithTweet:(HBAPTweet *)tweet;

@property (nonatomic, retain) HBAPTweet *tweet;

@end
