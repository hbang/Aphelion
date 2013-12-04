//
//  HBAPTweetActivityViewController.h
//  Aphelion
//
//  Created by Adam D on 4/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPActivityViewController.h"

@class HBAPTweet;

@interface HBAPTweetActivityViewController : HBAPActivityViewController

- (instancetype)initWithTweet:(HBAPTweet *)tweet;

@end
