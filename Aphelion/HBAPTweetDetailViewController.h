//
//  HBAPTweetDetailViewController.h
//  Aphelion
//
//  Created by Adam D on 20/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBAPTimelineViewController.h"

@class HBAPTweet;

@interface HBAPTweetDetailViewController : HBAPTimelineViewController {
	HBAPTweet *_tweet;
}

- (instancetype)initWithTweet:(HBAPTweet *)tweet;

@property (nonatomic, retain) HBAPTweet *tweet;

@end
